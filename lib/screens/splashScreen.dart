// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:zee_goo/constants/app_constants.dart';
// import 'package:zee_goo/main.dart';
// import 'package:zee_goo/screens/Login/login_page.dart';
// import 'package:zee_goo/screens/home/main_home.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLogin();
//   }

//   Future<void> _checkLogin() async {
//     await Future.delayed(const Duration(seconds: 2));
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _db = FirebaseFirestore.instance;

//     final user = _auth.currentUser;

//     if (user != null) {
//       // Get the user's name from Firestore
//       final doc = await _db.collection('users').doc(user.uid).get();
//       String userName;

//       if (doc.exists && doc.data()?['name'] != null) {
//         userName = doc.data()!['name'];
//       } else {
//         userName = 'Guest'; // fallback, but better to enforce Firestore name
//       }

//       // Request permissions
//       await _requestPermissions();

//       // Initialize Zego with proper userName
//       await _initZego(user.uid, userName);

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       }
//       return;
//     }

//     // User not logged in → go to LoginPage
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     }
//   }

//   // Request Permission
//   Future<void> _requestPermissions() async {
//     await [
//       Permission.camera,
//       Permission.microphone,
//       Permission.notification,
//     ].request();
//   }

//   // Zego All
//   Future<void> _initZego(String userId, String userName) async {
//     ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
//     await ZegoUIKitPrebuiltCallInvitationService()
//         .init(
//           appID: AppConstants.AAPID,
//           appSign: AppConstants.AAPSIGN,
//           userID: userId,
//           userName: userName,
//           plugins: [ZegoUIKitSignalingPlugin()],
//           invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
//         )
//         .catchError((error) {
//           print("Zego initialization error: $error");
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.deepOrange,
//       body: Center(
//         child: Text(
//           "Welcome to ZeeGoo",
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/screens/Login/login_page.dart';
import 'package:zee_goo/screens/Login/permission_waiting_screen.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

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
        if (gender.toLowerCase() == 'female') {
          // Female → check permission
          if (permission) {
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
