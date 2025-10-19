import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? gender;
  final int? age;
  final List<String> interests;
  final List<String> languages;
  final double balance;
  final DateTime createdAt;
  final bool permission;
  final bool isOnline;
  final bool isAdmin;
  final String? imagePath;
  final List<String> blockedUsers; // ✅ NEW FIELD

  UserModel({
    required this.uid,
    this.userId = "",
    required this.name,
    this.email,
    this.phone,
    this.gender,
    this.age,
    this.interests = const [],
    this.languages = const [],
    this.balance = 100.0,
    DateTime? createdAt,
    this.permission = false,
    this.isOnline = false,
    this.isAdmin = false,
    this.imagePath,
    this.blockedUsers = const [], // ✅ default empty list
  }) : createdAt = createdAt ?? DateTime.now();

  /// 🔹 Convert Firestore map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      userId: map['UserId'] ?? "",
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      gender: map['gender'],
      age: map['age'] is int ? map['age'] : null,
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : [],
      languages: map['languages'] != null
          ? List<String>.from(map['languages'])
          : [],
      blockedUsers:
          map['blockedUsers'] !=
              null // ✅ added
          ? List<String>.from(map['blockedUsers'])
          : [],
      balance: map['balance'] != null
          ? (map['balance'] is int
                ? (map['balance'] as int).toDouble()
                : map['balance'])
          : 100.0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      permission: map['permission'] ?? false,
      isOnline: map['isOnline'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      imagePath: map['imagePath'],
    );
  }

  /// 🔹 Convert UserModel → Firestore map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "UserId": userId,
      "name": name,
      "email": email,
      "phone": phone,
      "gender": gender,
      "age": age,
      "interests": interests,
      "languages": languages,
      "blockedUsers": blockedUsers, // ✅ added
      "balance": balance,
      "createdAt": createdAt,
      "permission": permission,
      "isOnline": isOnline,
      "isAdmin": isAdmin,
      "imagePath": imagePath,
    };
  }

  /// 🔹 CopyWith method for updates
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    int? age,
    List<String>? interests,
    List<String>? languages,
    List<String>? blockedUsers, // ✅ added
    double? balance,
    bool? permission,
    bool? isOnline,
    bool? isAdmin,
    String? imagePath,
  }) {
    return UserModel(
      uid: uid,
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      blockedUsers: blockedUsers ?? this.blockedUsers, // ✅ added
      balance: balance ?? this.balance,
      createdAt: createdAt,
      permission: permission ?? this.permission,
      isOnline: isOnline ?? this.isOnline,
      isAdmin: isAdmin ?? this.isAdmin,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
