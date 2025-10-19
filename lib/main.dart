import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/admin/dashboard/AdminDashboard.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalCallsOption/total_calls_screen.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/total_users_screen.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/add_coins_item.dart';

import 'package:zee_goo/firebase_options.dart';
import 'package:zee_goo/paymentts.dart';
import 'package:zee_goo/screens/Login/gender_screen.dart';
import 'package:zee_goo/screens/Login/name_screen.dart';
import 'package:zee_goo/screens/splashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(432, 960),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Hello Dost',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Splashscreen(),
      ),
    );
  }
}
