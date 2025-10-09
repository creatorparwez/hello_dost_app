import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/age_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

class GenderScreen extends ConsumerWidget {
  const GenderScreen({super.key});

  Future<void> saveGender(BuildContext context, WidgetRef ref) async {
    final selectedGender = ref.read(genderProvider);
    if (selectedGender == null) return;

    try {
      String useruid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(useruid).set({
        "gender": selectedGender,
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGender = ref.watch(genderProvider);
    final isLoading = ref.watch(isLoadingProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Select Your Gender",
              style: TextStyle(fontSize: 30.sp),
            ),
          ),
          SizedBox(height: 40.h),

          _genderImages(
            imagepath: 'assets/gender/male_2.png',
            title: "Male",
            selectedGender: selectedGender,
            ref: ref,
          ),
          SizedBox(height: 10.h),
          _genderImages(
            imagepath: 'assets/gender/female.png',
            title: "Female",
            selectedGender: selectedGender,
            ref: ref,
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedGender == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a gender"),
                          ),
                        );
                        return;
                      }
                      ref.read(isLoadingProvider.notifier).state = true;
                      await saveGender(context, ref);
                      ref.read(isLoadingProvider.notifier).state = false;
                      if (selectedGender == "Female") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AgeScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MScreen()),
                        );
                      }
                    },
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: isLoading
                      ? SizedBox(
                          height: 25.h,
                          width: 25.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _genderImages extends StatelessWidget {
  final String imagepath;
  final String title;
  final String? selectedGender;
  final WidgetRef ref;
  const _genderImages({
    required this.imagepath,
    required this.title,
    this.selectedGender,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedGender == title;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(genderProvider.notifier).state = title;
          },
          child: Container(
            height: 170.h,
            width: 170.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.deepOrange : Colors.grey,
                width: 5.w,
              ),
            ),
            child: ClipOval(child: Image.asset(imagepath, fit: BoxFit.cover)),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepOrange : Colors.black,
          ),
        ),
      ],
    );
  }
}
