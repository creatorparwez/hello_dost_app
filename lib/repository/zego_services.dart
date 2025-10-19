import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/main.dart';
import 'package:zee_goo/repository/send_call.dart';
import 'package:zee_goo/screens/home/call/call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoServices {
  // Permission
  static Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ].request();
  }

  // Initialize Zego
  static Future<void> initZego(String userId, String userName) async {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppConstants.AAPID,
      appSign: AppConstants.AAPSIGN,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        return data.type == ZegoCallInvitationType.videoCall
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
      },

      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        // When someone accepts our outgoing call (we are the CALLER)
        onOutgoingCallAccepted: (callID, callee) {
          debugPrint("📞 Call accepted by ${callee.name} - CALLER SIDE");
          final isVideo = ongoingCalls[callID] ?? false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState
                ?.push(
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      callerId: userId,
                      receiverId: callee.id,
                      receiverName: callee.name,
                      callerName: userName,
                      callID: callID,
                      isVideo: isVideo,
                    ),
                  ),
                )
                .then((_) {
                  // Clean up when CallScreen is popped
                  ongoingCalls.remove(callID);
                  debugPrint("✅ CallScreen closed for call: $callID");
                });
          });
        },
        // When we accept an incoming call (we are the CALLEE)
        onIncomingCallAcceptButtonPressed: () {
          debugPrint("📞 Incoming call accept button pressed - CALLEE SIDE");
        },
        onOutgoingCallDeclined: (callID, callee, data) {
          debugPrint("📵 Call declined by ${callee.name}");
          ongoingCalls.remove(callID);
        },
        onOutgoingCallCancelButtonPressed: () {
          debugPrint("❌ Outgoing call cancelled by caller");
        },
        onIncomingCallDeclineButtonPressed: () {
          debugPrint("📵 Incoming call declined");
        },
      ),
    );
  }
}
