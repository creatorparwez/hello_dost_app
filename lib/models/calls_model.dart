import 'package:cloud_firestore/cloud_firestore.dart';

class CallsModel {
  final String id; // Firestore document ID
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final double coinsReceived;
  final double totalCoinsDeducted;
  final DateTime createdAt;
  final int durationSeconds;
  final bool isVideo;

  CallsModel({
    required this.id,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.coinsReceived,
    required this.totalCoinsDeducted,
    required this.createdAt,
    required this.durationSeconds,
    required this.isVideo,
  });

  factory CallsModel.fromMap(Map<String, dynamic> map, String id) {
    return CallsModel(
      id: id,
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      coinsReceived: (map['coinsReceived'] is int)
          ? (map['coinsReceived'] as int).toDouble()
          : (map['coinsReceived'] ?? 0.0).toDouble(),
      totalCoinsDeducted: (map['totalCoinsDeducted'] is int)
          ? (map['totalCoinsDeducted'] as int).toDouble()
          : (map['totalCoinsDeducted'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      durationSeconds: (map['durationSeconds'] is double)
          ? (map['durationSeconds'] as double).toInt()
          : (map['durationSeconds'] ?? 0),
      isVideo: map['isVideo'] ?? false,
    );
  }

  factory CallsModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CallsModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'coinsReceived': coinsReceived,
      'totalCoinsDeducted': totalCoinsDeducted,
      'createdAt': Timestamp.fromDate(createdAt),
      'durationSeconds': durationSeconds,
      'isVideo': isVideo,
    };
  }
}
