import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zee_goo/models/calls_model.dart';
import 'package:zee_goo/models/user_model.dart';

class UsersRepository {
  final _firestore = FirebaseFirestore.instance;

  // Get All Users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get Users Data by Id
  Stream<UserModel> getUserDataById(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, snapshot.id);
      } else {
        throw Exception("User not found");
      }
    });
  }

  // Get Admin Data
  Stream<UserModel?> getAdminData() {
    return _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            return UserModel.fromMap(doc.data(), doc.id);
          } else {
            return null;
          }
        });
  }

  // Get User Call History by their Id
  Stream<List<CallsModel>> getCallsHistoryByUserId(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('calls') // ✅ fixed typo
        .orderBy('createdAt', descending: true) // optional, for recent first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallsModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
