import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userId;
  final String name;
  final String email;
  final String? gender;
  final int? age;
  final List<String>? interests;
  final List<String>? languages;
  final double balance;
  final DateTime createdAt;
  final bool permission;
  final bool isOnline;
  final bool isAdmin;

  UserModel({
    required this.uid,
    this.userId = "",
    required this.name,
    required this.email,
    this.gender,
    this.age,
    this.interests,
    this.languages,
    this.balance = 100.0,
    DateTime? createdAt,
    this.permission = false,
    this.isOnline = false,
    this.isAdmin = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // 🔹 Convert Firestore map → UserModel
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
      balance: map['balance'] != null
          ? (map['balance'] is int
                ? (map['balance'] as int).toDouble()
                : map['balance'])
          : 100.0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      permission: map['permission'] ?? false,
      isOnline: map['isOnline'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  // 🔹 Convert UserModel → Firestore map
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
      "permission": permission,
      "isOnline": isOnline,
      "isAdmin": isAdmin,
    };
  }

  // 🔹 CopyWith method (for easy updates)
  UserModel copyWith({
    String? name,
    String? email,
    String? gender,
    int? age,
    List<String>? interests,
    List<String>? languages,
    double? balance,
    bool? permission,
    bool? isOnline,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid,
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      permission: permission ?? this.permission,
      isOnline: isOnline ?? this.isOnline,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
