import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/add_coins_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final String userId;
  const WalletScreen({super.key, required this.userId});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wallet Information",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: Container(
              height: 200.h,
              width: 1.sw,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 116, 5, 219)],
                ),

                borderRadius: BorderRadius.circular(20.sp),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Balance",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "₹",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Consumer(
                              builder: (context, ref, _) {
                                final userData = ref.watch(
                                  userDataProvider(widget.userId),
                                );
                                return userData.when(
                                  data: (data) {
                                    return Text(
                                      data.balance.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                  error: (err, _) => Text(err.toString()),
                                  loading: () => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              elevation: 3,
                              shadowColor: Colors.white,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            onPressed: () {
                              // Withdraw Logics Here
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                "Withdraw",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Iconsax.wallet_35, color: Colors.white, size: 80.sp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
