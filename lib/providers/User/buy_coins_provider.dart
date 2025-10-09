import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zee_goo/models/buy_coins_model.dart';
import 'package:zee_goo/repository/buy_coins_repository.dart';

final buyCoinsRepositoryProvider = Provider<BuyCoinsRepository>((ref) {
  return BuyCoinsRepository();
});

// Get all Buy Coins Offers
final buyCoinsProvider = StreamProvider<List<BuyCoinsModel>>((ref) {
  final repo = ref.read(buyCoinsRepositoryProvider);
  return repo.getBuyCoinsList();
});
