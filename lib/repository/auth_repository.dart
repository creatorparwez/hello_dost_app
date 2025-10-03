import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // With Email and Password
  // For Sign up User
  Future<User?> signupUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "gender": "",
          "age": null,
          "interests": [],
          "balance": 0, // default, will update later
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // To Login or Sign in user
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

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
        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final userDoc = await _firestore
              .collection("users")
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await _firestore.collection("users").doc(user.uid).set({
              "uid": user.uid,
              "UserId": "",
              "name": user.displayName ?? "",
              "phone": user.phoneNumber,
              "gender": "",
              "age": null,
              "interests": [],
              "languages": [],
              "balance": 0,
              "permission": false,
              "createdAt": FieldValue.serverTimestamp(),
            });
          }
        }
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
        final userDoc = await _firestore
            .collection("users")
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore.collection("users").doc(user.uid).set({
            "uid": user.uid,
            "UserId": "",
            "name": name ?? "",
            "phone": user.phoneNumber,
            "gender": "",
            "age": null,
            "interests": [],
            "languages": [],
            "balance": 0,
            "permission": false,
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

  // Get current user
  User? get currentUser => _auth.currentUser;
}
