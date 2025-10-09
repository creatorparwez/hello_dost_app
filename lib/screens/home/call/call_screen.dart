import 'package:flutter/material.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/repository/coin_deduction_services.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatefulWidget {
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
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CoinDeductionService _coinService = CoinDeductionService();
  bool _isCallEnded = false;

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
    if (!mounted || _isCallEnded) return;
    debugPrint("Balance zero - ending call");
    _safeEndCall();
    // Force navigation back
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Stop coin deduction and save call history
  Future<void> _safeEndCall() async {
    if (_isCallEnded) return;
    _isCallEnded = true;

    try {
      final summary = await _coinService.stopAndSave(
        callerId: widget.callerId,
        callerName: widget.callerName,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
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
    return SafeArea(
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
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            debugPrint("Call ended with reason: ${event.reason}");
            // Save call history and stop coin deduction
            _safeEndCall();
            // Call default action for cleanup
            defaultAction.call();
            // Navigate back when call ends
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
