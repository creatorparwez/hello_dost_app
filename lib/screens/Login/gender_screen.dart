import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/screens/Login/name_screen.dart';
import 'package:zee_goo/screens/Login/select_languages_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<GenderScreen> {
  List<String> genderList = ["Male", "Female"];
  String selectedGender = "Male";
  int currentIndex = 0;

  final PageController _pageController = PageController(viewportFraction: 0.5);

  List<String> maleImages = [
    'assets/males/male_1.png',
    'assets/males/male_2.png',
    'assets/males/male_3.png',
    'assets/males/male_4.png',
    'assets/males/male_5.png',
    'assets/males/male_6.png',
    'assets/males/male_7.png',
    'assets/males/male_8.png',
  ];

  List<String> femaleImages = [
    'assets/females/female_1.png',
    'assets/females/female_2.png',
    'assets/females/female_3.png',
    'assets/females/female_4.png',
    'assets/females/female_5.png',
    'assets/females/female_6.png',
    'assets/females/female_7.png',
    'assets/females/female_8.png',
  ];

  bool isLoading = false;

  // 🔥 Save User gender and image to Firestore
  Future<void> saveUserGenderAndImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Determine the selected image
    List<String> currentImages = selectedGender == "Male"
        ? maleImages
        : selectedGender == "Female"
        ? femaleImages
        : [];

    String selectedImagePath = currentImages.isNotEmpty
        ? currentImages[currentIndex]
        : "";

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({"gender": selectedGender, "imagePath": selectedImagePath});
      if (selectedGender == "Male") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NameScreen(gender: selectedGender)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SelectLanguagesScreen(gender: selectedGender),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Failed to save: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentImages = selectedGender == "Male"
        ? maleImages
        : selectedGender == "Female"
        ? femaleImages
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select Your Gender",
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 30.h),

          // 👇 Gender selector
          Container(
            height: 45.h,
            width: 300.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(width: 2.w, color: Colors.black),
            ),
            child: Row(
              children: List.generate(genderList.length, (index) {
                String gender = genderList[index];
                bool isSelected = gender == selectedGender;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = gender;
                        currentIndex = 0;
                        _pageController.jumpToPage(0);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepOrange : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: isSelected
                            ? Border.all(color: Colors.deepOrange, width: 3)
                            : Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          gender,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 40.h),

          // 👇 Image slider
          if (selectedGender.isNotEmpty)
            SizedBox(
              height: 200.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: currentImages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  bool isSelected = index == currentIndex;
                  return AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepOrange
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage(currentImages[index]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Text("No Images"),
          SizedBox(height: 30.h),

          // 👇 Continue button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                minimumSize: Size(double.infinity, 50.h),
              ),
              onPressed: () async {
                // Save imagePath and Gender
                setState(() {
                  isLoading = true;
                });

                await saveUserGenderAndImage();

                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },

              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
