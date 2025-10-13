import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/all_users_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/approval_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/female_users_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalUsersOption/male_users_widget.dart';

import 'package:zee_goo/constants/app_constants.dart';

class TotalUsersScreen extends StatefulWidget {
  const TotalUsersScreen({super.key});

  @override
  State<TotalUsersScreen> createState() => _TotalUsersSegmentedState();
}

class _TotalUsersSegmentedState extends State<TotalUsersScreen> {
  int selectedIndex = 0;

  final tabs = ["Users", "Male", "Female", "Pending"];

  final List<Widget> screens = [
    AllUsersWidget(), // Users screen
    MaleUsersWidget(), // Male screen
    FemaleUsersWidget(), // Female screen
    ApprovalWidget(), // Pending Approval
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.appsecondaryColor,
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF141D3C),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 10.w, right: 10.w),
            child: SizedBox(
              height: 50.h,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  bool isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 19.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20.sp),
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}
