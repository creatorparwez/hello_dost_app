import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/screens/Login/signup_screen.dart';
import 'package:zee_goo/screens/Login/verify_otp.dart';
import 'package:zee_goo/screens/home/home_tabs/home_screen.dart';

class SendOTPScreen extends ConsumerStatefulWidget {
  const SendOTPScreen({super.key});

  @override
  ConsumerState<SendOTPScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<SendOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();

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
              "Login",
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
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter phonr number',
                          prefixIcon: Icon(Icons.phone),
                          prefixText: "+91 ", // shows from start
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 10) {
                            return "Please enter valid 10 digit number";
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
                            // To send OTP
                            if (_formKey.currentState!.validate()) {
                              final phone =
                                  "+91${_phoneNumberController.text.trim()}";
                              final sendOTPProvider = ref.read(
                                authRepositoryProvider,
                              );
                              ref.read(isLoadingProvider.notifier).state = true;

                              try {
                                await sendOTPProvider.sendOTP(
                                  phoneNumber: phone,
                                  codeSent: (verificationId, resendToken) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("OTP Sent")),
                                    );
                                    // Navigate to Verify screen
                                    Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                        child: VerifyOTPScreen(),
                                        type: PageTransitionType.rightToLeft,
                                      ),
                                    );
                                    ref.read(isLoadingProvider.notifier).state =
                                        false;
                                  },
                                );
                              } catch (e) {
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
                                  "Send OTP",
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
