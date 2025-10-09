import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_options/buy_coins_screen.dart';
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
    return userDatas.when(
      data: (datas) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 100,
                child: Image.asset(
                  datas.gender == "Male"
                      ? 'assets/gender/male_22.png'
                      : 'assets/gender/female_3.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              datas.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      // To see Wallet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WalletScreen(userId: datas.uid),
                        ),
                      );
                    },
                    child: Center(
                      child: Text("Wallet", style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      // To see Buy Coins
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BuyCoinsScreen()),
                      );
                    },
                    child: Center(
                      child: Text("Buy Coins", style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {},
                    child: Center(
                      child: Text(
                        "Help & Support",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    height: 2.h,
                    width: 1.sw,
                    color: const Color.fromARGB(255, 194, 193, 193),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .update({"isOnline": false});
                        await authRepo.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SendOTPScreen()),
                        );
                      } catch (e) {}
                    },
                    child: Center(
                      child: Text("Logout", style: TextStyle(fontSize: 20)),
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
    );
  }
}
