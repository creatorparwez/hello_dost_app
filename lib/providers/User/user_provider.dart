import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/repository/auth_repository.dart';
import 'package:zee_goo/repository/users_repository.dart';

// Auth Repository Instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// To store Gender
final genderProvider = StateProvider<String?>((ref) {
  return null;
});
// To store Age
final ageProvider = StateProvider<int?>((ref) {
  return null;
});
// Loading
final isLoadingProvider = StateProvider<bool>((ref) => false);

// To store interests
final interestProvider = StateProvider<List<String>>((ref) {
  return [];
});

// To store languages
final languageProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Users Repository Instance
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

// To get All Users
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getAllUsers();
});

// To get userData by Id
final userDataProvider = StreamProvider.family<UserModel, String>((
  ref,
  userId,
) {
  final repo = ref.watch(usersRepositoryProvider);
  return repo.getUserDataById(userId);
});

// // StreamProvider for all users
// final allUserProvider = StreamProvider<List<UserModel>>((ref) {
//   return _db
//       .collection("users")
//       .snapshots()
//       .map((snapshot) {
//         return snapshot.docs
//             .map((doc) => UserModel.fromMap(doc.data(), doc.id))
//             .toList();
//       })
//       .handleError((error) {
//         print("Firestore error: $error");
//       });
// });
