import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/gift_overlay_manager.dart';
import 'package:zee_goo/main.dart';
import 'package:zee_goo/repository/send_call.dart';
import 'package:zee_goo/screens/home/call/call_screen.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoServices {
  static StreamSubscription<ZegoInRoomCommandReceivedData>?
  _giftCommandSubscription;

  // Permission
  static Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.systemAlertWindow, // For full-screen incoming calls
    ].request();

    // Request USE_FULL_SCREEN_INTENT permission (Android 14+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // Set up global gift command listener (works for both caller and callee)
  static void setupGlobalGiftListener(BuildContext context) {
    debugPrint('🎧 Setting up GLOBAL gift command listener...');

    _giftCommandSubscription?.cancel(); // Cancel any existing subscription

    _giftCommandSubscription = ZegoUIKit().getInRoomCommandReceivedStream().listen(
      (event) {
        debugPrint(
          '📨 GLOBAL: Received command from ${event.fromUser.id}: ${event.command}',
        );
        try {
          final commandData = jsonDecode(event.command);
          debugPrint('📦 GLOBAL: Parsed command data: $commandData');

          if (commandData['type'] == 'gift') {
            final imagePath = commandData['imagePath'] as String;
            debugPrint(
              '🎁 GLOBAL: Received gift: $imagePath from ${event.fromUser.name}',
            );

            // Use the global gift overlay manager
            GiftOverlayManager().showGift(imagePath);
          }
        } catch (e) {
          debugPrint('❌ GLOBAL: Error parsing gift command: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ GLOBAL: Stream error: $error');
      },
      onDone: () {
        debugPrint('🔴 GLOBAL: Gift command stream closed');
      },
    );

    debugPrint('✅ GLOBAL: Gift command listener set up successfully');
  }

  // Cancel global gift listener
  static void cancelGlobalGiftListener() {
    debugPrint('🔴 Cancelling GLOBAL gift listener');
    _giftCommandSubscription?.cancel();
    _giftCommandSubscription = null;
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
      ringtoneConfig: ZegoCallRingtoneConfig(
        incomingCallPath: 'assets/sounds/call_ringtone.mp3',
        outgoingCallPath: 'assets/sounds/call_ringtone.mp3',
      ),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showFullScreen: true,
        ),
      ),
      requireConfig: (ZegoCallInvitationData data) {
        return data.type == ZegoCallInvitationType.videoCall
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
      },

      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        // When an incoming call is received (CALLEE receives call notification)
        onIncomingCallReceived:
            (
              String callID,
              ZegoCallUser caller,
              ZegoCallInvitationType callType,
              List<ZegoCallUser> callees,
              String customData,
            ) {
              debugPrint(
                "📞 Incoming call received from ${caller.name} - callID: $callID, type: $callType",
              );
              // The default ZegoCloud incoming call page will automatically show in full screen
            },

        // When someone accepts our outgoing call (we are the CALLER)
        onOutgoingCallAccepted: (callID, callee) {
          debugPrint("📞 Call accepted by ${callee.name} - CALLER SIDE");
          final isVideo = ongoingCalls[callID] ?? false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              // Set up global gift listener for CALLER
              Future.delayed(const Duration(seconds: 2), () {
                if (navigatorKey.currentContext != null) {
                  setupGlobalGiftListener(navigatorKey.currentContext!);
                }
              });
            }

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
                  cancelGlobalGiftListener();
                  ongoingCalls.remove(callID);
                  debugPrint("✅ CallScreen closed for call: $callID");
                });
          });
        },
        // When we accept an incoming call (we are the CALLEE)
        onIncomingCallAcceptButtonPressed: () {
          debugPrint("📞 Incoming call accept button pressed - CALLEE SIDE");

          // Set up global gift listener for CALLEE
          Future.delayed(const Duration(seconds: 2), () {
            if (navigatorKey.currentContext != null) {
              setupGlobalGiftListener(navigatorKey.currentContext!);
              debugPrint("✅ CALLEE: Global gift listener set up");
            }
          });
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
        onIncomingCallTimeout: (callID, caller) {
          debugPrint("⏰ Incoming call timeout");
          cancelGlobalGiftListener();
        },
        onIncomingCallCanceled: (callID, caller, data) {
          debugPrint("❌ Incoming call canceled");
          cancelGlobalGiftListener();
        },
      ),
    );
  }
}
