import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zee_goo/constants/app_constants.dart';

class CallSummary {
  final int seconds;
  final double totalCoinsDeducted;
  CallSummary({required this.seconds, required this.totalCoinsDeducted});
}

class CoinDeductionService {
  Timer? _timer;
  int _seconds = 0;
  double _coinsDeducted = 0.0;
  double _currentBalance = 0.0;
  bool _isRunning = false;
  late bool _isVideo;

  // Remove hardcoded admin UID - will be passed as parameter
  // static const String adminUid = 'Y17OPR8sdPCVJZebRQsC';

  double _ratePerSecond(bool isVideo) => isVideo
      ? AppConstants.videoCallRatePerSecond
      : AppConstants.voiceCallRatePerSecond;

  /// Start local deduction — no Firestore writes during call
  Future<void> start({
    required String callerId,
    required String receiverId,
    required bool isVideo,
    Function()? onBalanceZero,
  }) async {
    if (_isRunning) return;

    _isRunning = true;
    _isVideo = isVideo;
    _seconds = 0;
    _coinsDeducted = 0.0;

    try {
      // 1️⃣ Fetch caller balance once
      final callerSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(callerId)
          .get();
      _currentBalance = _safeToDouble(callerSnap.data()?['balance']);
    } catch (e) {
      print('❌ Failed to load user balance: $e');
      _isRunning = false;
      return;
    }

    final double perSecond = _ratePerSecond(isVideo);

    // 2️⃣ Start timer for local deduction
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) {
        _timer?.cancel();
        return;
      }

      if (_currentBalance >= perSecond) {
        _currentBalance -= perSecond;
        _coinsDeducted += perSecond;
        _seconds++;
        print(
          '💰 Coins deducted: $_coinsDeducted, Balance: $_currentBalance, Seconds: $_seconds',
        );
      } else {
        // Local balance is over
        print('⚠️ Balance exhausted - triggering onBalanceZero');
        stop();
        onBalanceZero?.call();
      }
    });
  }

  /// Stop timer and commit deduction to Firestore
  Future<CallSummary> stopAndSave({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required String adminUid,
    required bool isVideo,
    bool isCallCard = false,
  }) async {
    stop();

    final int totalSeconds = _seconds;
    final double totalCoins = _coinsDeducted;

    // Convert coins to rupees (1₹ = 3 coins)
    final double totalRupees = totalCoins / 3.0;

    // Calculate shares in rupees based on 30-second threshold
    double adminShareRupees;
    double receiverShareRupees;

    if (totalSeconds < 30) {
      // Less than 30 seconds: Admin gets 100%, receiver gets 0
      adminShareRupees = totalRupees;
      receiverShareRupees = 0.0;
      print(
        '⏱️ Call < 30s: Admin gets 100% (${totalRupees.toStringAsFixed(2)}₹)',
      );
    } else {
      // 30 seconds or more: Apply proper splits in rupees
      if (isVideo) {
        // Video call: Female gets 6.50₹/min, Admin gets 13.50₹/min
        // Calculate based on duration
        final double minutes = totalSeconds / 60.0;
        receiverShareRupees = 6.50 * minutes;
        adminShareRupees = totalRupees - receiverShareRupees;
      } else {
        // Voice call: Female gets 1.02₹/min, Admin gets 4.98₹/min
        // Calculate based on duration
        final double minutes = totalSeconds / 60.0;
        receiverShareRupees = 1.02 * minutes;
        adminShareRupees = totalRupees - receiverShareRupees;
      }
      print(
        '⏱️ Call ≥ 30s: Receiver gets ${receiverShareRupees.toStringAsFixed(2)}₹ (${(receiverShareRupees * 3).toStringAsFixed(2)} coins), Admin gets ${adminShareRupees.toStringAsFixed(2)}₹ (${(adminShareRupees * 3).toStringAsFixed(2)} coins)',
      );
    }

    // Store rupees directly in database (not coins)
    final double receiverShare = receiverShareRupees;
    final double adminShare = adminShareRupees;

    print(
      '💾 Stopping call - Duration: ${totalSeconds}s, Total: ${totalRupees.toStringAsFixed(2)}₹, Receiver: ${receiverShare.toStringAsFixed(2)}₹, Admin: ${adminShare.toStringAsFixed(2)}₹',
    );

    if (totalSeconds == 0 || totalCoins <= 0) {
      print('⏹ No coins deducted — skipping save.');
      return CallSummary(seconds: 0, totalCoinsDeducted: 0);
    }

    final callerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(callerId);
    final receiverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId);
    final adminRef = FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid);

    try {
      // 3️⃣ Single transaction for final deduction with timeout
      await FirebaseFirestore.instance
          .runTransaction((tx) async {
            final callerSnap = await tx.get(callerRef);
            final receiverSnap = await tx.get(receiverRef);
            final adminSnap = await tx.get(adminRef);

            double callerBalance = _safeToDouble(callerSnap.data()?['balance']);
            double receiverBalance = _safeToDouble(
              receiverSnap.data()?['balance'],
            );
            double adminBalance = _safeToDouble(adminSnap.data()?['balance']);

            // Prevent negative balances
            final newCaller = (callerBalance - totalCoins).clamp(
              0,
              double.infinity,
            );
            final newReceiver = receiverBalance + receiverShare;
            final newAdmin = adminBalance + adminShare;

            tx.update(callerRef, {'balance': newCaller});
            tx.update(receiverRef, {'balance': newReceiver});
            tx.update(adminRef, {'balance': newAdmin});
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Transaction timeout - continuing anyway');
              throw TimeoutException('Transaction timed out');
            },
          );
      print('✅ Balance updated successfully');
    } catch (e) {
      print('⚠️ Final deduction transaction failed: $e');
    }

    // 4️⃣ Save call history (non-blocking, fire and forget with timeout)
    _saveCallHistoryAsync(
      callHistoryRef: FirebaseFirestore.instance
          .collection('call_history')
          .doc(),
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverRef: receiverRef,
      totalSeconds: totalSeconds,
      totalCoins: totalCoins,
      receiverShare: receiverShare,
      adminShare: adminShare,
      isVideo: isVideo,
    );

    return CallSummary(seconds: totalSeconds, totalCoinsDeducted: totalCoins);
  }

  /// Save call history asynchronously (non-blocking)
  Future<void> _saveCallHistoryAsync({
    required DocumentReference callHistoryRef,
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required DocumentReference receiverRef,
    required int totalSeconds,
    required double totalCoins,
    required double receiverShare,
    required double adminShare,
    required bool isVideo,
  }) async {
    try {
      await callHistoryRef
          .set({
            'callId': callHistoryRef.id,
            'callerId': callerId,
            'callerName': callerName,
            'receiverId': receiverId,
            'receiverName': receiverName,
            'durationSeconds': totalSeconds,
            'totalCoins': totalCoins,
            'coinsDeducted': totalCoins, // Kept for backward compatibility
            'receiverShare': receiverShare,
            'adminShare': adminShare,
            'isVideo': isVideo,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 5));

      // Receiver's personal record
      await receiverRef
          .collection('calls')
          .doc(callHistoryRef.id)
          .set({
            'callId': callHistoryRef.id,
            'callerId': callerId,
            'callerName': callerName,
            'receiverId': receiverId,
            'receiverName': receiverName,
            'durationSeconds': totalSeconds,
            'coinsReceived': receiverShare,
            'receiverShare': receiverShare,
            'adminShare': adminShare,
            'totalCoins': totalCoins,
            'totalCoinsDeducted': totalCoins, // Kept for backward compatibility
            'isVideo': isVideo,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 5));

      // Caller's personal record
      final callerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(callerId);

      await callerRef
          .collection('calls')
          .doc(callHistoryRef.id)
          .set({
            'callId': callHistoryRef.id,
            'callerId': callerId,
            'callerName': callerName,
            'receiverId': receiverId,
            'receiverName': receiverName,
            'durationSeconds': totalSeconds,
            'coinsSpent': totalCoins,
            'receiverShare': receiverShare,
            'adminShare': adminShare,
            'totalCoins': totalCoins,
            'totalCoinsDeducted': totalCoins, // Kept for backward compatibility
            'isVideo': isVideo,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 5));

      print('✅ Call history saved successfully');
    } catch (e) {
      print('⚠️ Failed to save call history: $e');
    }
  }

  /// Stop only the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  // Handy getters
  double get currentLocalBalance => _currentBalance;
  bool get isRunning => _isRunning;

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
