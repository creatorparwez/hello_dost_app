import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/permission_waiting_screen.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';

class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  final _ageController = TextEditingController();
  // List for interest
  final List<String> availableInterests = [
    "Dance",
    "Sports",
    "Music",
    "Travel",
    "Cooking",
    "Movies",
  ];
  // For Age and interest method
  Future<void> saveAge(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    ref.read(isLoadingProvider.notifier).state = true;
    final ageValue = ref.read(ageProvider);
    final selectedInterests = ref.read(interestProvider);
    if (ageValue == null || ageValue <= 0 || ageValue > 100) {
      ref.read(isLoadingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid age (1–100)")),
      );
      return;
    }
    if (selectedInterests.isEmpty) {
      ref.read(isLoadingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one interest")),
      );
      return;
    }
    final useruid = await FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(useruid).set({
        "age": ageValue,
        "interests": selectedInterests,
      }, SetOptions(merge: true));
      // Fetch updated user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(useruid)
          .get();
      final permission = userDoc.data()?['permission'] ?? false;

      // Navigate based on permission
      if (permission) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PermissionWaitingScreen()),
        );
      }
      ref.read(isLoadingProvider.notifier).state = false;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final age = ref.watch(ageProvider);
    final loading = ref.watch(isLoadingProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                hintText: "Enter Age",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17.r),
                ),
              ),
              keyboardType: TextInputType.number,

              onChanged: (value) {
                final intAge = int.tryParse(value);
                ref.read(ageProvider.notifier).state = intAge;
              },
            ),
            SizedBox(height: 25.h),
            // Interests Section
            Wrap(
              spacing: 10.w,
              runSpacing: 10,
              children: availableInterests.map((data) {
                final selectedInterests = ref.watch(interestProvider);
                final isSelected = selectedInterests.contains(data);
                return GestureDetector(
                  onTap: () {
                    ref.read(interestProvider.notifier).update((state) {
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
              onPressed: () async {
                // Navigate to Home Screen
                await saveAge(context, ref);
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
