import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/screens/home/home_tabs/call_history_screen.dart';

class EarningsScreen extends StatefulWidget {
  final String gender;
  const EarningsScreen({super.key, required this.gender});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.gender == "Male" ? "Sessions" : "Earnings History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: CallHistoryScreen(),
    );
  }
}
