import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String phone;
  final String gender;
  final String age;
  final String balance;
  final List<String> languages;
  final List<String> interests;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.gender,
    required this.phone,
    required this.balance,
    required this.age,
    required this.languages,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF141D3C),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 90,
                backgroundImage: gender == 'Female'
                    ? const AssetImage('assets/gender/female.png')
                    : const AssetImage('assets/gender/male_2.png'),
              ),
            ),
            SizedBox(height: 20.h),
            _buildSections(title: "Name", value: userName),
            _buildSections(title: "Phone", value: phone),
            _buildSections(title: "Gender", value: gender),
            _buildSections(title: "Age", value: age),
            _buildSections(title: "Balance", value: balance),
            SizedBox(height: 10.h),
            // Languages in one line
            _buildListSection(title: "Languages", values: languages),
            SizedBox(height: 10.h),
            // Interests in one line
            _buildListSection(title: "Interests", values: interests),
          ],
        ),
      ),
    );
  }

  Widget _buildSections({required String title, required String value}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          children: [
            Text("$title: ", style: TextStyle(fontSize: 20.sp)),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget to show list of values in one line
  Widget _buildListSection({
    required String title,
    required List<String> values,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title: ", style: TextStyle(fontSize: 20.sp)),
            Expanded(
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: values.map((val) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
