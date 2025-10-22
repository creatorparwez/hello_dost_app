import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/send_call.dart';

class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final randomAsync = ref.watch(randomUserProvider);
    return Scaffold(
      body: randomAsync.when(
        data: (randomUserData) {
          if (randomUserData == null) return Text("No user available");
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(randomUserData.name),
              Text(randomUserData.uid),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    // Random UserId
                    ref.refresh(randomUserProvider);
                  },
                  child: Center(child: Text("Random User Id")),
                ),
              ),
              SizedBox(height: 100.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  onPressed: () {
                    ref.refresh(randomUserProvider);
                    sendCall(
                      isVideo: false,
                      receiverId: randomUserData.uid,
                      receiverName: randomUserData.name,
                      ref: ref,
                      context: context,
                    );
                  },
                  child: Center(
                    child: Text(
                      "Random Call",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
