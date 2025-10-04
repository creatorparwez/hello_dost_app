import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/call_service.dart';
import 'package:zee_goo/screens/Login/login_page.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final allUsers = ref.watch(allUsersProvider);

        return allUsers.when(
          error: (error, _) {
            return Text("err $error");
          },
          loading: () => Center(child: CircularProgressIndicator()),
          data: (allUsersData) {
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;

            // Filter out logged-in user
            final otherUsers = allUsersData
                .where(
                  (user) => user.uid != currentUserId && user.isOnline == true,
                )
                .toList();
            return ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                var data = otherUsers[index];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 3.h,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20.r),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 173, 150, 150),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          child: Image.asset(
                            data.gender == "Male"
                                ? 'assets/gender/male_22.png'
                                : 'assets/gender/female_3.png',
                            height: 150.h,
                            width: 1.sw,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Name Section
                        Padding(
                          padding: EdgeInsets.only(left: 17.w),
                          child: Text(
                            data.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        // Interest Section
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 4.h,
                          children: List.generate(data.interests!.length, (
                            index,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                margin: EdgeInsets.only(bottom: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                  ),
                                  child: Text(
                                    data.interests![index],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ////
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    sendCall(
                                      isVideo: false,
                                      receiverId: data.uid,
                                      receiverName: data.name,
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      "Voice Call",
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    sendCall(
                                      isVideo: true,
                                      receiverId: data.uid,
                                      receiverName: data.name,
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      "Video Call",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
