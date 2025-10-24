import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/auth_repository.dart';
import 'package:zee_goo/repository/auth_repository_account_delete.dart';
import 'package:zee_goo/screens/Login/verify_otp.dart';

class SendOTPScreenForDelete extends ConsumerStatefulWidget {
  const SendOTPScreenForDelete({super.key});

  @override
  ConsumerState<SendOTPScreenForDelete> createState() =>
      _SendOTPScreenForDeleteState();
}

class _SendOTPScreenForDeleteState
    extends ConsumerState<SendOTPScreenForDelete> {
  final AuthRepositoryDelete _authRepoDelete = AuthRepositoryDelete();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _verificationId;

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
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: "+91 ", // shows from start
                  prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
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
                    backgroundColor: const Color.fromARGB(255, 245, 71, 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () async {
                    // To send OTP
                    if (_formKey.currentState!.validate()) {
                      final phone = "+91${_phoneNumberController.text.trim()}";
                      ref.read(isLoadingProvider.notifier).state = true;
                      try {
                        await _authRepoDelete.sendOTPForDeletion(
                          context: context,
                          phoneNumber: phone,
                          onCodeSent: (verificationId) {
                            _verificationId = verificationId;
                          },
                        );
                        ref.read(isLoadingProvider.notifier).state = false;
                      } catch (e) {
                        ref.read(isLoadingProvider.notifier).state = false;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
    );
  }
}
