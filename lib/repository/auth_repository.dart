import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zee_goo/main.dart';
import 'package:zee_goo/screens/Login/send_otp.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To Login with Phone Number
  String? _verificationId;

  // Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException ex) {
        throw Exception("Verification failed: ${ex.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Verify OTP
  Future<User?> verifyOTP(String smsCode, {String? name}) async {
    try {
      if (_verificationId == null) {
        throw Exception("No verification ID found");
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDocRef = _firestore.collection("users").doc(user.uid);
        final userDoc = await userDocRef.get();
        if (userDoc.exists) {
          // ✅ User already exists → set isOnline to true
          await userDocRef.update({
            "isOnline": true,
            "name":
                name ?? userDoc.data()?['name'] ?? "", // optionally update name
          });
        } else {
          await _firestore.collection("users").doc(user.uid).set({
            "uid": user.uid,
            "UserId": "",
            "name": name ?? "",
            "phone": user.phoneNumber,
            "gender": "",
            "imagePath": "",
            "age": null,
            "interests": [],
            "languages": [],
            "balance": 100,
            "permission": false,
            "isOnline": false,
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception("OTP verification failed: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Account Delete
  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user logged in")),
          );
        }
        return;
      }

      final uid = user.uid;

      await _auth.verifyPhoneNumber(
        phoneNumber: user.phoneNumber!,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // Show loading indicator
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            }

            await user.reauthenticateWithCredential(credential);
            // ignore: use_build_context_synchronously
            await _performAccountDeletion(uid, user, context);
          } catch (e) {
            debugPrint("Error in verificationCompleted: $e");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to delete account: $e")),
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Verification failed: ${e.message}");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.message}")),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          debugPrint("🔔 codeSent callback triggered!");

          // Small delay to allow app to return from reCAPTCHA
          await Future.delayed(const Duration(milliseconds: 500));

          try {
            debugPrint("✅ About to show OTP dialog using global navigator");
            // Use global navigator key instead of local context
            final globalContext = navigatorKey.currentContext;

            if (globalContext == null) {
              debugPrint("❌ Global context is null");
              return;
            }

            String? smsCode = await _getOtpFromUser(globalContext);
            debugPrint("📱 OTP entered: ${smsCode ?? 'null or empty'}");

            // Check if user cancelled OTP entry
            if (smsCode == null || smsCode.isEmpty) {
              debugPrint("❌ OTP cancelled or empty");
              if (globalContext.mounted) {
                ScaffoldMessenger.of(globalContext).showSnackBar(
                  const SnackBar(content: Text("Account deletion cancelled")),
                );
              }
              return;
            }

            debugPrint("⏳ Showing loading dialog");
            // Show loading during deletion
            if (globalContext.mounted) {
              showDialog(
                context: globalContext,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            }

            debugPrint("🔐 Creating credential with OTP");
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            debugPrint("🔑 Reauthenticating user");
            await user.reauthenticateWithCredential(credential);

            debugPrint("🗑️ Starting account deletion");
            await _performAccountDeletion(uid, user, globalContext);
            debugPrint("✅ Account deletion completed");
          } catch (e) {
            debugPrint("Error in codeSent: $e");
            final globalContext = navigatorKey.currentContext;
            if (globalContext != null && globalContext.mounted) {
              Navigator.of(globalContext).pop(); // Close loading dialog
              ScaffoldMessenger.of(globalContext).showSnackBar(
                SnackBar(
                  content: Text("Failed to delete account: ${e.toString()}"),
                ),
              );
            }
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("Code auto retrieval timeout");
        },
      );
    } catch (e) {
      debugPrint("Error deleting account: $e");
      if (context.mounted) {
        // Try to close any open dialogs
        Navigator.of(context, rootNavigator: true).popUntil((route) {
          return route.isFirst || !route.willHandlePopInternally;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")),
        );
      }
    }
  }

  // Helper method to perform actual account deletion
  Future<void> _performAccountDeletion(
    String uid,
    User user,
    BuildContext context,
  ) async {
    try {
      debugPrint("🗑️ _performAccountDeletion: Starting");
      debugPrint("🗑️ UID: $uid");

      // Delete from Firestore (only if exists)
      debugPrint("🗑️ Checking Firestore document");
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists) {
        debugPrint("🗑️ Deleting Firestore document");
        await docRef.delete();
        debugPrint("✅ Firestore document deleted");
      } else {
        debugPrint("⚠️ No Firestore document found");
      }

      // Delete from Authentication
      debugPrint("🗑️ Deleting Firebase Auth user");
      await user.delete();
      debugPrint("✅ Firebase Auth user deleted");

      debugPrint("🗑️ Signing out");
      await _auth.signOut();
      debugPrint("✅ Signed out");

      debugPrint("🗑️ Checking context.mounted: ${context.mounted}");
      if (context.mounted) {
        debugPrint("🗑️ Closing loading dialog");
        Navigator.of(context).pop();

        debugPrint("🗑️ Showing success message");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );

        debugPrint("🗑️ Navigating to login screen");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SendOTPScreen()),
          (route) => false,
        );
        debugPrint("✅ Navigation complete");
      } else {
        debugPrint("❌ Context not mounted, cannot navigate");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error in _performAccountDeletion: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // Helper Class
  Future<String?> _getOtpFromUser(BuildContext context) async {
    debugPrint("📞 _getOtpFromUser called");
    final TextEditingController otpController = TextEditingController();
    String? smsCode;

    debugPrint("📞 Showing OTP dialog now...");
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        debugPrint("📞 OTP dialog builder called");
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter the 6-digit OTP",
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint("📞 Cancel button pressed");
                Navigator.of(dialogContext).pop(); // close dialog without OTP
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                smsCode = otpController.text.trim();
                debugPrint("📞 Confirm button pressed, OTP: $smsCode");
                Navigator.of(dialogContext).pop(); // close dialog with OTP
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    debugPrint("📞 Dialog closed, disposing controller");
    otpController.dispose();
    debugPrint("📞 Returning smsCode: $smsCode");
    return smsCode;
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
