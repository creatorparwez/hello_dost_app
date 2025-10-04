import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Returns a Zego call invitation button (audio/video) with Firebase-safe checks
ZegoSendCallInvitationButton actionButton({
  required bool isVideo,
  required String receiverId,
  required String receiverName,
}) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null || receiverId.isEmpty || receiverName.isEmpty) {
    // Safety fallback: prevent call if invalid data
    return ZegoSendCallInvitationButton(
      invitees: [],
      isVideoCall: isVideo,
      iconSize: const Size(40, 40),
      buttonSize: const Size(70, 40),
      onPressed: (code, msg, errorInvitees) {
        print("Cannot call. Invalid user data.");
      },
    );
  }

  final callId =
      "call_${currentUser.uid}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}";

  return ZegoSendCallInvitationButton(
    invitees: [ZegoUIKitUser(id: receiverId, name: receiverName)],
    isVideoCall: isVideo,
    callID: callId,
    iconSize: const Size(28, 28),
    buttonSize: const Size(double.infinity, 45),

    onPressed: (code, message, errorInvitees) {
      if (code != 0) {
        print("Failed to send invitation: $message");
      } else {
        print("Invitation sent to $receiverName (callId: $callId)");
      }
    },
  );
}
