import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userId; // new
  final String name;
  final String email;
  final String? gender;
  final int? age;
  final List<String>? interests;
  final List<String>? languages; // new
  final int balance;
  final DateTime createdAt;
  final bool permission; // <-- NEW FIELD
  final bool isOnline;

  UserModel({
    required this.uid,
    this.userId = "",
    required this.name,
    required this.email,
    this.gender,
    this.age,
    this.interests,
    this.languages,
    this.balance = 100,
    required this.createdAt,
    this.permission = false, // default false
    this.isOnline = false,
  });

  // From Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      userId: map['UserId'] ?? "",
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'],
      age: map['age'],
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : [],
      languages: map['languages'] != null
          ? List<String>.from(map['languages'])
          : [],
      balance: map['balance'] ?? 100,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      permission: map['permission'] ?? false, // <-- NEW
      isOnline: map['isOnline'] ?? false,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "UserId": userId,
      "name": name,
      "email": email,
      "gender": gender,
      "age": age,
      "interests": interests,
      "languages": languages,
      "balance": balance,
      "createdAt": createdAt,
      "permission": permission, // <-- NEW
      "isOnline": isOnline,
    };
  }
}
