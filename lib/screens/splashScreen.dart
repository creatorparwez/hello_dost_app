import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/main.dart';
import 'package:zee_goo/screens/Login/permission_waiting_screen.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';
import 'package:zee_goo/screens/home/m_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLogin(context);
  }

  // To check User Login
  Future<void> _checkLogin(BuildContext context) async {
    Timer(Duration(seconds: 3), () async {
      final user = await _auth.currentUser;
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
        await _requestPermissions();
        // Initialize Zego for this user
        await _initZego(user.uid, userName);
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
              MaterialPageRoute(
                builder: (_) => const PermissionWaitingScreen(),
              ),
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

  // To initialize Zego
  Future<void> _initZego(String userId, String userName) async {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    await ZegoUIKitPrebuiltCallInvitationService()
        .init(
          appID: AppConstants.AAPID,
          appSign: AppConstants.AAPSIGN,
          userID: userId,
          userName: userName,
          plugins: [ZegoUIKitSignalingPlugin()],
          invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
        )
        .catchError((error) {
          print("Zego initialization error: $error");
        });
  }

  // Permission request function
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepOrange,
        height: 1.sh,
        width: 1.sw,
        child: Center(
          child: Text(
            AppConstants.APP_NAME,
            style: TextStyle(fontSize: 45.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
