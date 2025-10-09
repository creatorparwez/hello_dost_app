// file: lib/repository/coin_deduction_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallSummary {
  final int seconds;
  final double totalCoinsDeducted;
  CallSummary({required this.seconds, required this.totalCoinsDeducted});
}

class CoinDeductionService {
  Timer? _timer;
  int _seconds = 0;
  double _coinsDeducted = 0.0;
  bool _isRunning = false;
  late bool _isVideo;

  // AdminUId
  static const String adminUid = 'tFe7ApxZkITW5M6bcvehZlEHSkg2';

  double _ratePerSecond(bool isVideo) => isVideo ? 1.0 : (20.0 / 60.0);

  /// Start per-second deduction. Provide onBalanceZero callback to hangup.
  void start({
    required String callerId,
    required String receiverId,
    required bool isVideo,
    Function()? onBalanceZero, // called when caller balance insufficient
  }) {
    if (_isRunning) return;
    _isRunning = true;
    _isVideo = isVideo;
    _seconds = 0;
    _coinsDeducted = 0.0;

    final double perSecond = _ratePerSecond(isVideo);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      // Using transaction to safely deduct and credit
      final callerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(callerId);
      final receiverRef = FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId);

      final success = await FirebaseFirestore.instance
          .runTransaction<bool>((tx) async {
            final callerSnap = await tx.get(callerRef);
            final receiverSnap = await tx.get(receiverRef);

            double callerBalance = 0;
            double receiverBalance = 0;
            if (callerSnap.exists &&
                callerSnap.data()!.containsKey('balance')) {
              final v = callerSnap.data()!['balance'];
              callerBalance = (v is int)
                  ? v.toDouble()
                  : (v is double ? v : double.tryParse(v.toString()) ?? 0);
            }
            if (receiverSnap.exists &&
                receiverSnap.data()!.containsKey('balance')) {
              final v = receiverSnap.data()!['balance'];
              receiverBalance = (v is int)
                  ? v.toDouble()
                  : (v is double ? v : double.tryParse(v.toString()) ?? 0);
            }

            if (callerBalance < perSecond) {
              // not enough to deduct this second -> end call
              return false;
            }

            final newCaller = callerBalance - perSecond;
            final newReceiver = receiverBalance + (perSecond / 2);

            tx.update(callerRef, {'balance': newCaller});
            tx.update(receiverRef, {'balance': newReceiver});
            return true;
          })
          .catchError((e) {
            // transaction failed
            return false;
          });

      if (success) {
        _seconds += 1;
        _coinsDeducted += perSecond;
      } else {
        // stop timer and notify
        stop();
        if (onBalanceZero != null) onBalanceZero();
      }
    });
  }

  /// Stop timer and write history (returns summary)
  /// This will also store history and distribute remaining half/admin split for totalCoinsDeducted.
  Future<CallSummary> stopAndSave({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required bool isVideo,
  }) async {
    stop();

    // total coins already deducted per second stored in _coinsDeducted
    final int totalSeconds = _seconds;
    final double totalCoins = _coinsDeducted;

    // Ensure atomic final distribution if you want to distribute again on end.
    // Note: In our per-second loop we already credited receiver half each second.
    // If you prefer to credit only at end, you must change above to only deduct from caller per-second
    // and credit neither; then distribute here. Below implementation assumes you DID credit per-second already,
    // so here we won't credit again. But we'll still write history and also send admin share if not credited.
    //
    // For simplicity: assume we already credited receiver each second (above). We'll credit admin final share here:
    // admin should get half of totalCoins. But receiver already received (totalCoins/2) in steps.
    // So we just credit admin (totalCoins/2) now.

    final double adminShare = totalCoins / 2.0;

    final adminRef = FirebaseFirestore.instance
        .collection('users')
        .doc(CoinDeductionService.adminUid);
    await FirebaseFirestore.instance
        .runTransaction((tx) async {
          final adminSnap = await tx.get(adminRef);
          double adminBalance = 0;
          if (adminSnap.exists && adminSnap.data()!.containsKey('balance')) {
            final v = adminSnap.data()!['balance'];
            adminBalance = (v is int)
                ? v.toDouble()
                : (v is double ? v : double.tryParse(v.toString()) ?? 0);
          }
          tx.update(adminRef, {'balance': adminBalance + adminShare});
        })
        .catchError((e) {
          // if admin update fails, continue but log in console
          print('admin credit failed: $e');
        });

    // Save call record to a general 'call_history' collection (optional)
    final callHistoryRef = FirebaseFirestore.instance
        .collection('call_history')
        .doc();
    await callHistoryRef.set({
      'callId': callHistoryRef.id,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'durationSeconds': totalSeconds,
      'coinsDeducted': totalCoins,
      'isVideo': isVideo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Save under receiver's doc -> subcollection "calls"
    final receiverCallsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('calls')
        .doc(callHistoryRef.id);

    await receiverCallsRef.set({
      'callId': callHistoryRef.id,
      'callerId': callerId,
      'callerName': callerName,
      'durationSeconds': totalSeconds,
      'coinsReceived': totalCoins / 2.0, // receiver got half in total
      'isVideo': isVideo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return CallSummary(seconds: totalSeconds, totalCoinsDeducted: totalCoins);
  }

  /// just stop timer (no DB)
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  bool get isRunning => _isRunning;
}
