import 'package:cloud_firestore/cloud_firestore.dart';

class BuyCoinsModel {
  final String id;
  final double coins;
  final int discountPrice;
  final int originalPrice;

  BuyCoinsModel({
    required this.id,
    required this.coins,
    required this.discountPrice,
    required this.originalPrice,
  });

  /// Create an instance from a Firestore DocumentSnapshot
  factory BuyCoinsModel.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return BuyCoinsModel(
      id: doc.id,
      coins: (map['coins'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toInt(),
      originalPrice: (map['originalPrice'] ?? 0).toInt(),
    );
  }

  /// Create an instance from a Map (optional if you have map data)
  factory BuyCoinsModel.fromMap(Map<String, dynamic> map, String id) {
    return BuyCoinsModel(
      id: id,
      coins: (map['coins'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toInt(),
      originalPrice: (map['originalPrice'] ?? 0).toInt(),
    );
  }

  /// Convert the model to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'coins': coins,
      'discountPrice': discountPrice,
      'originalPrice': originalPrice,
    };
  }
}
