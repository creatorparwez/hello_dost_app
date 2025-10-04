import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallScreen extends ConsumerWidget {
  final bool isVideo;
  final String callID;
  const VideoCallScreen(this.isVideo, {super.key, required this.callID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userDatas = ref.watch(userDataProvider(currentUserId));
    return userDatas.when(
      data: (data) {
        return ZegoUIKitPrebuiltCall(
          appID: AppConstants.AAPID,
          appSign: AppConstants.AAPSIGN,
          callID: callID,
          userID: data.uid,
          userName: data.name,
          config: isVideo
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
        );
      },
      error: (error, _) => Center(child: Text(error.toString())),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}
