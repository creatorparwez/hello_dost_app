import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalCallsOption/all_calls_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalCallsOption/month_calls_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalCallsOption/today_calls_widget.dart';
import 'package:zee_goo/admin/dashboard/Drawer%20Options/TotalCallsOption/week_calls_widget.dart';

class TotalCallsScreen extends StatefulWidget {
  const TotalCallsScreen({super.key});

  @override
  State<TotalCallsScreen> createState() => _TotalCallsScreenState();
}

class _TotalCallsScreenState extends State<TotalCallsScreen> {
  int selectedIndex = 0;
  final tabs = ["Calls", "Today", "Week", "Month"];
  List<Widget> screens = [
    AllCallsWidget(), // Total Calls
    TodayCallsWidget(), // Today Calls
    WeekCallsWidget(), // Week Calls
    MonthCallsWidget(), // Month Calls
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calls",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF141D3C),
      ),
      body: Column(
        children: [
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabs.length, (index) {
              var data = tabs[index];
              bool isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  print(" 😤😤🫢😏Selected index : $selectedIndex");
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrange : Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 5.h,
                    ),
                    child: Text(
                      data,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20.sp),
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}
