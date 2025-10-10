import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/repository/zego_services.dart';
import 'package:zee_goo/screens/Login/permission_waiting_screen.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLogin(context);
  }

  // To check User Login
  Future<void> _checkLogin(BuildContext context) async {
    Timer(Duration(seconds: 3), () async {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch user document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = userDoc.data();
        final gender = data?['gender'] ?? '';
        final permission = data?['permission'] ?? false;
        final userName = data?['name'] ?? 'Guest';

        // ✅ Request permissions first
        await ZegoServices.requestPermissions();

        // ✅ Initialize Zego for this user
        await ZegoServices.initZego(user.uid, userName);

        if (gender.toLowerCase() == 'female') {
          // Female → check permission
          if (permission) {
            // To update isOnline field
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isOnline': true});
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PermissionWaitingScreen()),
            );
          }
        } else {
          // Male → go directly to HomeScreen
          // To update isOnline field
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'isOnline': true});
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SendOTPScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepOrange,
        height: 1.sh,
        width: 1.sw,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/applogo/APPLOGO2.png',
              height: 250.h,
              width: 220.w,
              fit: BoxFit.cover,
            ),
            Text(
              AppConstants.APP_NAME,
              style: TextStyle(
                fontSize: 40.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
