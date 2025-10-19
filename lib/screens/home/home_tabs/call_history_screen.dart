import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:zee_goo/providers/User/user_provider.dart';

class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  ConsumerState<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends ConsumerState<CallHistoryScreen> {
  // To Block User
  Future<void> blockUser(String callerId, String calleeId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(calleeId).update(
        {
          'blockedUsers': FieldValue.arrayUnion([callerId]),
        },
      );
      Fluttertoast.showToast(msg: "User blocked", backgroundColor: Colors.red);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDataAsync = ref.watch(userDataProvider(currentUser!.uid));
    final currentUserGender = userDataAsync.value?.gender;

    if (currentUserGender == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userCallsAsync = ref.watch(callsHistoryProvider(currentUser.uid));
    return userCallsAsync.when(
      data: (callsData) {
        return ListView.builder(
          itemCount: callsData.length,
          itemBuilder: (context, index) {
            var data = callsData[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              child: Card(
                elevation: 4,
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color.fromARGB(255, 43, 40, 40),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Row(
                          children: [
                            Card(
                              elevation: 6,
                              shadowColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              color: const Color.fromARGB(255, 37, 36, 36),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Text(
                              currentUserGender == "Male"
                                  ? data.receiverName
                                  : data.callerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            currentUserGender == "Female"
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        241,
                                        43,
                                        29,
                                      ),
                                    ),
                                    onPressed: () async {
                                      // Block User Logic
                                      await blockUser(
                                        data.callerId,
                                        data.receiverId,
                                      );
                                    },
                                    child: Text(
                                      "Block",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Container(
                          height: 2.h,
                          width: 1.sw,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Duration : ${data.durationSeconds} seconds",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              currentUserGender == "Male"
                                  ? "Coins Deducted : ${data.totalCoinsDeducted.toStringAsFixed(2)}"
                                  : "Earned : ₹ ${data.coinsReceived.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Mode : ${data.isVideo ? "Video" : "Voice"}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Date & Time : ${DateFormat('dd MMM yyyy, hh:mm a').format(data.createdAt)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (err, _) => Center(child: Text(err.toString())),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}
