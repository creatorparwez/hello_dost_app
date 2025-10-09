import 'package:cloud_firestore/cloud_firestore.dart';

class CallsModel {
  final String id;
  final String callerId;
  final String callerName;
  final double coinsReceived;
  final DateTime createdAt;
  final int durationSeconds;
  final bool isVideo;

  CallsModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.coinsReceived,
    required this.createdAt,
    required this.durationSeconds,
    required this.isVideo,
  });

  factory CallsModel.fromMap(Map<String, dynamic> map, String id) {
    return CallsModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      coinsReceived: (map['coinsReceived'] is int)
          ? (map['coinsReceived'] as int).toDouble()
          : (map['coinsReceived'] ?? 0.0).toDouble(), // ✅ safe conversion
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      durationSeconds: (map['durationSeconds'] is double)
          ? (map['durationSeconds'] as double).toInt()
          : (map['durationSeconds'] ?? 0),
      isVideo: map['isVideo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'coinsReceived': coinsReceived,
      'createdAt': createdAt,
      'durationSeconds': durationSeconds,
      'isVideo': isVideo,
    };
  }
}
