import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zee_goo/models/call_history_model.dart';
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

  // Get All Calls
  Stream<List<CallHistoryModel>> getAllCalls() {
    return _firestore
        .collection('call_history')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallHistoryModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get Today Calls
  Stream<List<CallHistoryModel>> getTodayCalls() {
    final now = DateTime.now();
    final startOfDay = Timestamp.fromDate(
      DateTime(now.year, now.month, now.day, 0, 0, 0),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    return _firestore
        .collection('call_history')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallHistoryModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get Week Calls
  Stream<List<CallHistoryModel>> getWeekCalls() {
    final now = DateTime.now();

    // Start of week (Monday)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    // End of week (Sunday 23:59:59)
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return _firestore
        .collection('call_history')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallHistoryModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get Month Calls
  Stream<List<CallHistoryModel>> getMonthCalls() {
    final now = DateTime.now();

    // Start of current month
    final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);

    // End of month (last day of this month)
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection('call_history')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallHistoryModel.fromMap(doc.data(), doc.id))
              .toList();
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

  // To get Top 10 Females based on Balance
  Stream<List<UserModel>> getTopFemales() {
    return _firestore
        .collection('users')
        .where('gender', isEqualTo: "Female")
        .orderBy('balance', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
