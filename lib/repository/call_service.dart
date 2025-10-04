import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

Future<void> sendCall({
  required bool isVideo,
  required String receiverId,
  required String receiverName,
}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final callId =
      "call_${currentUser.uid}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}";
  await ZegoUIKitPrebuiltCallInvitationService().send(
    invitees: [ZegoCallUser(receiverId, receiverName)],
    isVideoCall: isVideo,
    callID: callId,
  );
}
