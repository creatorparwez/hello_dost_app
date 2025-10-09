import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// To store call type is video/voice call
Map<String, bool> ongoingCalls = {};

Future<void> sendCall({
  required bool isVideo,
  required String receiverId,
  required String receiverName,
  required WidgetRef ref,
  required BuildContext context,
}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final callId =
      "call_${currentUser.uid}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}";
  ongoingCalls[callId] = isVideo;
  await ZegoUIKitPrebuiltCallInvitationService().send(
    invitees: [ZegoCallUser(receiverId, receiverName)],
    isVideoCall: isVideo,
    callID: callId,
  );
}
