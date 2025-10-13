import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/send_call.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _refreshTimer;
  int _shuffleTrigger = 0;

  @override
  void initState() {
    super.initState();
    // Set up a timer to shuffle and refresh online users every 2 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _shuffleTrigger++;
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser;
    final currentUserData = ref.watch(userDataProvider(currentUserId!.uid));

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

            // Filter out logged-in user and shuffle the list
            final otherUsers = allUsersData
                .where(
                  (user) => user.uid != currentUserId && user.isOnline == true,
                )
                .toList();

            // Shuffle the list to randomize user positions
            // Using _shuffleTrigger to trigger re-shuffle on timer
            otherUsers.shuffle(Random(_shuffleTrigger));

            return ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                var data = otherUsers[index];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
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
                        _buildImageSection(data: data),
                        SizedBox(height: 8.h),
                        // Name Section
                        _buildNameSection(data: data),
                        SizedBox(height: 5.h),
                        // Language Section
                        _buildLanguagesSection(data: data),
                        SizedBox(height: 8.h),
                        // Interest Section
                        _buildInterestsSection(data: data),

                        SizedBox(height: 8.h),

                        // Voice and Video Section
                        currentUserData.when(
                          data: (datass) {
                            return datass.gender == "Female"
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Voice call
                                        Expanded(
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (datass.balance <
                                                  AppConstants
                                                      .voiceCallRatePerSecond) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Insufficient coins! Please add coins to make call.",
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                sendCall(
                                                  isVideo: false,
                                                  receiverId: data.uid,
                                                  receiverName: data.name,
                                                  ref: ref,
                                                  context: context,
                                                );
                                              }
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  'assets/images/dollar.png',
                                                  height: 20.h,
                                                  width: 20.w,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  "18",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "/min",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                Icon(
                                                  Iconsax.call5,
                                                  color: Colors.white,
                                                  size: 25.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        // Video Call
                                        Expanded(
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepOrange,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (datass.balance <
                                                  AppConstants
                                                      .videoCallRatePerSecond) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Insufficient coins! Please add coins to make call.",
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                sendCall(
                                                  isVideo: true,
                                                  receiverId: data.uid,
                                                  receiverName: data.name,
                                                  ref: ref,
                                                  context: context,
                                                );
                                              }
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  'assets/images/dollar.png',
                                                  height: 20.h,
                                                  width: 20.w,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  "60",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "/min",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                Icon(
                                                  Iconsax.video5,
                                                  color: Colors.white,
                                                  size: 25.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                          error: (error, stackTrace) => Text(error.toString()),
                          loading: () =>
                              Center(child: CircularProgressIndicator()),
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

  //
}

// Image
class _buildImageSection extends StatelessWidget {
  const _buildImageSection({required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 173, 150, 150),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: Image.asset(
          data.imagePath.toString(),
          height: 180.h,
          width: 1.sw,
          fit: BoxFit.cover, // 👈 fills full width
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

// Name

class _buildNameSection extends StatelessWidget {
  const _buildNameSection({required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 17.w),
      child: Text(
        data.name,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// Languages
class _buildLanguagesSection extends StatelessWidget {
  const _buildLanguagesSection({required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Wrap(
        runSpacing: 4.h,
        children: List.generate(data.languages.length, (index) {
          return Text(
            "${data.languages[index]}, ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        }),
      ),
    );
  }
}

// Interests
class _buildInterestsSection extends StatelessWidget {
  const _buildInterestsSection({required this.data});

  final UserModel data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 4.h,
      children: List.generate(data.interests.length, (index) {
        return Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            margin: EdgeInsets.only(bottom: 5.h),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                data.interests[index],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
