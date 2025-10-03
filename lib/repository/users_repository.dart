import 'package:cloud_firestore/cloud_firestore.dart';
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
}
