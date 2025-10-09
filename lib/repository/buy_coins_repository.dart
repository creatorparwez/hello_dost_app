import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zee_goo/models/buy_coins_model.dart';

class BuyCoinsRepository {
  final _firebase = FirebaseFirestore.instance;

  Stream<List<BuyCoinsModel>> getBuyCoinsList() {
    return _firebase.collection('buy_coins').snapshots().map((snapshots) {
      return snapshots.docs
          .map((doc) => BuyCoinsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
