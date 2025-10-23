import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/age_screen.dart';

class SelectLanguagesScreen extends ConsumerStatefulWidget {
  final String gender;
  const SelectLanguagesScreen({super.key, required this.gender});

  @override
  ConsumerState<SelectLanguagesScreen> createState() =>
      _SelectLanguagesScreenState();
}

class _SelectLanguagesScreenState extends ConsumerState<SelectLanguagesScreen> {
  // List for interest
  final List<String> availableLanguages = [
    "English",
    "Hindi",
    "Marathi ",
    "Gujarati ",
    "Tamil",
    "Telugu",
    "Kannada",
    "Malayalam",
    "Bengali",
    "Punjabi",
    "Urdu",
    "Odia",
  ];
  // For Save Languages
  Future<void> saveLanguages(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    ref.read(isLoadingProvider.notifier).state = true;

    final selectedLanguages = ref.read(languageProvider);
    if (selectedLanguages.isEmpty || selectedLanguages.length < 3) {
      ref.read(isLoadingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least two language")),
      );
      return;
    }

    final useruid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(useruid).set({
        "languages": selectedLanguages,
      }, SetOptions(merge: true));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AgeScreen(gender: widget.gender)),
      );
      ref.read(isLoadingProvider.notifier).state = false;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(isLoadingProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Your Languages",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 50),
            // Languages Section
            Wrap(
              spacing: 10.w,
              runSpacing: 10,
              children: availableLanguages.map((data) {
                final selectedLanguages = ref.watch(languageProvider);
                final isSelected = selectedLanguages.contains(data);
                return GestureDetector(
                  onTap: () {
                    ref.read(languageProvider.notifier).update((state) {
                      final newState = List<String>.from(state);
                      if (isSelected) {
                        newState.remove(data); // deselect
                      } else {
                        newState.add(data); // select
                      }
                      return newState;
                    });
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    color: isSelected ? Colors.deepOrange : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      child: isSelected
                          ? Text(
                              data,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              data,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 30.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: loading
                  ? null
                  : () async {
                      // Navigate to Home Screen
                      await saveLanguages(context, ref);
                    },
              child: Center(
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 20.sp),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
