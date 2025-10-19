import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/coin_deduction_services.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String callID;
  final bool isVideo;

  /// Callback to notify parent that call ended
  // final Function()? onCallEnded;

  const CallScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
    required this.callerName,
    required this.callID,
    required this.isVideo,
    // this.onCallEnded,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final CoinDeductionService _coinService = CoinDeductionService();

  bool _isHangingUp = false;
  bool _isSavingCallHistory = false;

  @override
  void initState() {
    super.initState();
    // Start per-second coin deduction
    _coinService.start(
      callerId: widget.callerId,
      receiverId: widget.receiverId,
      isVideo: widget.isVideo,
      onBalanceZero: _handleBalanceZero, // auto end if coins run out
    );
  }

  /// Called when caller runs out of balance
  void _handleBalanceZero() {
    if (!mounted || _isHangingUp) return;
    debugPrint("⚠️ Balance zero - ending call");

    // Mark as hanging up to prevent duplicate hangup calls
    _isHangingUp = true;

    // Schedule immediate execution after current frame to avoid setState errors
    Future.microtask(() async {
      if (!mounted) return;

      debugPrint("🔴 Saving call data due to zero balance");

      // Save call data immediately (with timeout protection)
      await _safeEndCall();

      // Force close all screens aggressively
      if (mounted) {
        // Use popUntil to go back to home screen
        try {
          debugPrint("🔴 Force closing to home screen");
          Navigator.of(context).popUntil((route) => route.isFirst);
          debugPrint("✅ Successfully returned to home");
        } catch (e) {
          debugPrint("⚠️ Error with popUntil, trying manual pops: $e");
          // Fallback: manual pops
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            int poppedScreens = 0;
            while (mounted && Navigator.canPop(context) && poppedScreens < 5) {
              Navigator.of(context).pop();
              poppedScreens++;
              debugPrint("✅ Popped screen $poppedScreens");
            }
          });
        }
      }
    });
  }

  /// Stop coin deduction and save call history
  Future<void> _safeEndCall() async {
    if (_isSavingCallHistory) return;
    _isSavingCallHistory = true;

    try {
      // Get admin UID from provider
      final adminData = ref.read(adminDataProvider).value;
      final adminUid = adminData?.uid ?? 'Y17OPR8sdPCVJZebRQsC'; // Fallback to hardcoded if admin not found

      final summary = await _coinService.stopAndSave(
        callerId: widget.callerId,
        callerName: widget.callerName,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        adminUid: adminUid,
        isVideo: widget.isVideo,
      );
      debugPrint(
        "Call ended. Duration: ${summary.seconds}s, Coins deducted: ${summary.totalCoinsDeducted}",
      );
    } catch (e) {
      debugPrint("Error ending call: $e");
    }
  }

  @override
  void dispose() {
    _coinService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Ensure cleanup when back button is pressed
          await _safeEndCall();
        }
      },
      child: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: AppConstants.AAPID,
          appSign: AppConstants.AAPSIGN,
          userID: widget.callerId,
          userName: widget.callerName,
          callID: widget.callID,
          config: widget.isVideo
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),

          events: ZegoUIKitPrebuiltCallEvents(
            onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) async {
              debugPrint("📞 Call ended with reason: ${event.reason}");

              // Capture navigator before async operations
              final navigator = Navigator.of(context);

              // Save call history and stop coin deduction
              await _safeEndCall();

              // Call default action for cleanup
              defaultAction.call();

              // Navigate back when call ends - pop ALL screens to home
              if (mounted) {
                debugPrint("🔴 Normal call end - returning to home");
                debugPrint("📊 Can pop? ${navigator.canPop()}");

                try {
                  // Count routes before popping
                  int routeCount = 0;
                  navigator.popUntil((route) {
                    routeCount++;
                    debugPrint(
                      "📍 Route $routeCount: ${route.settings.name ?? 'unnamed'}, isFirst: ${route.isFirst}",
                    );
                    return route.isFirst;
                  });
                  debugPrint(
                    "✅ Popped $routeCount routes, returned to home after call",
                  );
                } catch (e) {
                  debugPrint("⚠️ Error with popUntil: $e");
                  // Fallback: manual pops
                  int poppedScreens = 0;
                  while (mounted && navigator.canPop() && poppedScreens < 5) {
                    navigator.pop();
                    poppedScreens++;
                    debugPrint("✅ Manual pop $poppedScreens");
                  }
                }
              }
            },
            user: ZegoCallUserEvents(
              onLeave: (user) {
                // When remote user leaves the call
                debugPrint("👋 User left the call: ${user.name}");

                if (!mounted || _isHangingUp) return;

                debugPrint(
                  "⚠️ Remote user disconnected - ending call for caller",
                );

                // Mark as hanging up to prevent duplicate calls
                _isHangingUp = true;

                // Capture context and navigator BEFORE any async operations
                final capturedContext = context;
                final navigator = Navigator.of(capturedContext);

                // Handle cleanup and navigation immediately
                Future.microtask(() async {
                  if (!mounted) return;

                  debugPrint("🔴 Saving call data after remote user left");

                  // Save call history and stop coin deduction
                  await _safeEndCall();

                  // Navigate back to home screen
                  if (mounted && navigator.canPop()) {
                    debugPrint("🔴 Remote user left - returning to home");

                    try {
                      // Pop all screens to return to home
                      navigator.popUntil((route) => route.isFirst);
                      debugPrint(
                        "✅ Successfully returned to home after remote user left",
                      );
                    } catch (e) {
                      debugPrint("⚠️ Error with popUntil: $e");
                      // Fallback: manual pops
                      int poppedScreens = 0;
                      while (mounted &&
                          navigator.canPop() &&
                          poppedScreens < 5) {
                        navigator.pop();
                        poppedScreens++;
                        debugPrint("✅ Manual pop $poppedScreens");
                      }
                    }
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
