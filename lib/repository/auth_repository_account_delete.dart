import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zee_goo/screens/Account_Deletetion/verify_otp_delete.dart';

import 'package:zee_goo/screens/Login/send_otp.dart'; // your login start screen

class AuthRepositoryDelete {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send OTP for deletion - now returns verificationId via callback
  Future<void> sendOTPForDeletion({
    required BuildContext context,
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException ex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${ex.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent successfully.")),
          );
          // Pass verificationId to caller via callback
          onCodeSent(verificationId);
          // Navigate after OTP is successfully sent
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VerifyOTPScreenForDelete(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout - no action needed
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending OTP: $e")));
    }
  }

  // Verify OTP and delete user
  Future<void> verifyOTPForDelete({
    required String smsCode,
    required String verificationId,
    required BuildContext context,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDocRef = _firestore.collection("users").doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          await userDocRef.delete();
        }

        // Delete Firebase Auth user
        await user.delete();

        // Ensure logout
        await _auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );

        // Navigate back to login/start screen
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const SendOTPScreen(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verification failed: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }
  }
}
