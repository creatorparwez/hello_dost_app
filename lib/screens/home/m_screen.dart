import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/constants/app_constants.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/profile_screen.dart';

class MScreen extends StatefulWidget {
  const MScreen({super.key});

  @override
  State<MScreen> createState() => _MScreenState();
}

class _MScreenState extends State<MScreen> {
  int isSelectedIndex = 0;
  List<Widget> isSelected = [
    HomeScreen(),
    Center(child: Text("History")),
    ProfileScreen(),
  ];

  void onTaped(int index) {
    setState(() {
      isSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
      appBar: AppBar(
        title: Text(
          AppConstants.APP_NAME,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border.all(color: Colors.grey, width: 2.w),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/dollar.png',
                    height: 23.h,
                    width: 23.w,
                  ),
                  SizedBox(width: 5.w),
                  Text("0"),
                  SizedBox(width: 5.w),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: isSelected[isSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isSelectedIndex,
        onTap: onTaped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.transaction_minus5),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle5),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
