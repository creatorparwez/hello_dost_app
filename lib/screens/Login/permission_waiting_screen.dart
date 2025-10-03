import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionWaitingScreen extends StatelessWidget {
  const PermissionWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon or illustration
              Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  color: Colors.deepOrange,
                  size: 80.sp,
                ),
              ),
              SizedBox(height: 40.h),

              Text(
                "Permission Pending",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Your account is currently awaiting admin approval.\n"
                "Please wait at least 24 hours for your permission to be approved.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp, color: Colors.black54),
              ),
              SizedBox(height: 30.h),
              CircularProgressIndicator(color: Colors.deepOrange),
              SizedBox(height: 20.h),
              Text(
                "Thank you for your patience!",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontStyle: FontStyle.italic,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
