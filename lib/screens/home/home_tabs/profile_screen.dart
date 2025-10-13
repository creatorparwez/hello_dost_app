import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';
import 'package:zee_goo/screens/home/home_tabs/call_history_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/add_coins_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/earnings_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/wallet_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text("User not logged in"));
    }
    final userDatas = ref.watch(userDataProvider(currentUser.uid));
    final authRepo = ref.read(authRepositoryProvider);
    return SingleChildScrollView(
      child: userDatas.when(
        data: (datas) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              // Image Section
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(100.r),
                child: Image.asset(
                  datas.imagePath.toString(),
                  height: 200.h,
                  width: 200.w,
                  fit: BoxFit.cover,
                  alignment: AlignmentGeometry.topCenter,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                datas.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: datas.gender == "Female"
                    ? Column(
                        /////////////////////////////////////// For Female
                        children: [
                          // All Options
                          // Wallet
                          _buildSections(
                            icon: Icons.account_balance_wallet_outlined,
                            title: "Wallet",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WalletScreen(userId: datas.uid),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Earnings
                          _buildSections(
                            icon: Icons.paid,
                            title: "Earnings",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EarningsScreen(
                                  gender: datas.gender.toString(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Help & Support
                          _buildSections(
                            icon: Icons.help,
                            title: "Help & Support",
                            onTap: () {
                              // Help & Support Link
                            },
                          ),
                          SizedBox(height: 10.h),

                          SizedBox(height: 20.h),
                          Container(
                            height: 2.h,
                            width: 1.sw,
                            color: const Color.fromARGB(255, 194, 193, 193),
                          ),
                          SizedBox(height: 20.h),
                          // Logout
                          GestureDetector(
                            onTap: () async {
                              // Logout Logic
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .update({"isOnline": false});
                                await authRepo.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SendOTPScreen(),
                                  ),
                                );
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 60.w,
                                  top: 10.h,
                                  bottom: 10.h,
                                  right: 40.w,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, size: 32.sp),
                                    SizedBox(width: 15.w),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        /////////////////////////////////////// For Male
                        children: [
                          // All Options
                          // Wallet
                          _buildSections(
                            icon: Icons.account_balance_wallet_outlined,
                            title: "Add Coins",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddCoinsScreen(userId: datas.uid),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Earnings
                          _buildSections(
                            icon: Icons.call,
                            title: "Sessions",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EarningsScreen(
                                  gender: datas.gender.toString(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          // Help & Support
                          _buildSections(
                            icon: Icons.help,
                            title: "Help & Support",
                            onTap: () {
                              // Help & Support Link
                            },
                          ),
                          SizedBox(height: 10.h),

                          SizedBox(height: 20.h),
                          Container(
                            height: 2.h,
                            width: 1.sw,
                            color: const Color.fromARGB(255, 194, 193, 193),
                          ),
                          SizedBox(height: 20.h),
                          // Logout
                          GestureDetector(
                            onTap: () async {
                              // Logout Logic
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .update({"isOnline": false});
                                await authRepo.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SendOTPScreen(),
                                  ),
                                );
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 60.w,
                                  top: 10.h,
                                  bottom: 10.h,
                                  right: 40.w,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, size: 32.sp),
                                    SizedBox(width: 15.w),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
        error: (err, _) => Text(err.toString()),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _buildSections extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _buildSections({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 60.w,
            top: 10.h,
            bottom: 10.h,
            right: 40.w,
          ),
          child: Row(
            children: [
              Icon(icon, size: 33.sp),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text(
                ">",
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
