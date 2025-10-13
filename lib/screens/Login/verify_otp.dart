import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/zego_services.dart';
import 'package:zee_goo/screens/Login/gender_screen.dart';
import 'package:zee_goo/screens/Login/select_languages_screen.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  const VerifyOTPScreen({super.key});

  @override
  ConsumerState<VerifyOTPScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<VerifyOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 300.h,
              width: double.infinity,
              color: const Color.fromARGB(255, 245, 71, 18), // Coral-like color
              child: const Center(
                child: SizedBox(), // Optionally add logo or design here
              ),
            ),
          ),
          Positioned(
            top: 220.h,
            right: 50.w,
            child: Text(
              "Verify",
              style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w600),
            ),
          ),
          // 📝 Login Form
          Padding(
            padding: EdgeInsets.only(top: 300.h),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Please enter valid 6 digit otp";
                          }

                          return null; // ✅ valid case
                        },
                      ),
                      SizedBox(height: 25.h),

                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              245,
                              71,
                              18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () async {
                            // Verify OTP
                            if (_formKey.currentState!.validate()) {
                              final otp = _otpController.text.trim();

                              final verifyOTPProvider = ref.read(
                                authRepositoryProvider,
                              );
                              ref.read(isLoadingProvider.notifier).state = true;

                              try {
                                final user = await verifyOTPProvider.verifyOTP(
                                  otp,
                                );
                                if (user == null) {
                                  throw Exception(
                                    "User not found after OTP verification",
                                  );
                                }
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                                final userData = UserModel.fromMap(
                                  userDoc.data()!,
                                  userDoc.id,
                                );

                                if (userData.name.isNotEmpty) {
                                  await ZegoServices.requestPermissions();
                                  // // ✅ Initialize Zego for first-time user
                                  await ZegoServices.initZego(
                                    user.uid,
                                    userData.name,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                      child: MScreen(),
                                      type: PageTransitionType.rightToLeft,
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                      child: GenderScreen(),
                                      type: PageTransitionType.rightToLeft,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ref.read(isLoadingProvider.notifier).state =
                                    false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              } finally {
                                ref.read(isLoadingProvider.notifier).state =
                                    false;
                              }
                            }
                          },
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
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

// Custom clipper for smooth wave
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60); // start bottom left
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 60,
    ); // first curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 130,
      size.width,
      size.height - 80,
    ); // second curve
    path.lineTo(size.width, 0); // top right
    path.close(); // close path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
