import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/auth_repository.dart';
import 'package:zee_goo/repository/auth_repository_account_delete.dart';
import 'package:zee_goo/repository/zego_services.dart';
import 'package:zee_goo/screens/Login/gender_screen.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

class VerifyOTPScreenForDelete extends ConsumerStatefulWidget {
  final String verificationId;

  const VerifyOTPScreenForDelete({super.key, required this.verificationId});

  @override
  ConsumerState<VerifyOTPScreenForDelete> createState() =>
      _VerifyOTPScreenForDeleteState();
}

class _VerifyOTPScreenForDeleteState
    extends ConsumerState<VerifyOTPScreenForDelete> {
  final AuthRepositoryDelete _authRepoDelete = AuthRepositoryDelete();
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
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "For Account Deletion",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                    backgroundColor: const Color.fromARGB(255, 245, 71, 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    // Verify OTP
                    if (_formKey.currentState!.validate()) {
                      final otp = _otpController.text.trim();
                      ref.read(isLoadingProvider.notifier).state = true;
                      try {
                        await _authRepoDelete.verifyOTPForDelete(
                          smsCode: otp,
                          verificationId: widget.verificationId,
                          context: context,
                        );
                      } catch (e) {
                        ref.read(isLoadingProvider.notifier).state = false;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      } finally {
                        ref.read(isLoadingProvider.notifier).state = false;
                      }
                    }
                  },
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
    );
  }
}
