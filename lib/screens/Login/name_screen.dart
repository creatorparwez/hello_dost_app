import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/gender_screen.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _nameController = TextEditingController();
  // For Save Languages
  Future<void> saveName(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    ref.read(isLoadingProvider.notifier).state = true;
    final useruid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(useruid).update({
        "name": _nameController.text.trim(),
      });
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GenderScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
              "Enter Your Name",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.user),
                hintText: "Enter your name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            SizedBox(height: 30.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () async {
                // To save user Name
                await saveName(context, ref);
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
