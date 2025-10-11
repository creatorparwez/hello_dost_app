import 'package:cloud_firestore/cloud_firestore.dart';

class CallHistoryModel {
  final String id; // Firestore document ID
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final num coinsDeducted;
  final int durationSeconds;
  final bool isVideo;
  final Timestamp createdAt;

  CallHistoryModel({
    required this.id,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.coinsDeducted,
    required this.durationSeconds,
    required this.isVideo,
    required this.createdAt,
  });

  /// Create a model from Firestore data + document ID
  factory CallHistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CallHistoryModel(
      id: docId,
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      coinsDeducted: map['coinsDeducted'] ?? 0,
      durationSeconds: map['durationSeconds'] ?? 0,
      isVideo: map['isVideo'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Convert model to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'coinsDeducted': coinsDeducted,
      'durationSeconds': durationSeconds,
      'isVideo': isVideo,
      'createdAt': createdAt,
    };
  }

  /// Optional: JSON conversion (for APIs or local storage)
  factory CallHistoryModel.fromJson(Map<String, dynamic> json) {
    return CallHistoryModel(
      id: json['id'] ?? '',
      callId: json['callId'] ?? '',
      callerId: json['callerId'] ?? '',
      callerName: json['callerName'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      coinsDeducted: json['coinsDeducted'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      isVideo: json['isVideo'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt']
          : Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'coinsDeducted': coinsDeducted,
      'durationSeconds': durationSeconds,
      'isVideo': isVideo,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
