import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/model/raffle_model.dart';
import 'package:raffle_footloose/services/storage_service.dart';

class RaffleProvider extends StateNotifier<RaffleModel> {
  RaffleProvider() : super(RaffleModel(name: "", numberSpecWinners: 0, countWinners: -1));

  void setRaffleName(String raffleName) {
    StorageService.saveToPrefs("raffle_name", raffleName);
    state = state.copyWith(name: raffleName);
  }

  Future<void> getRaffle() async {
    final name = await StorageService.readFromPrefs<String>("raffle_name");
    state = RaffleModel(name: name ?? state.name, numberSpecWinners: 0, countWinners: state.countWinners);
  }

  Future<void> setCountWinners(int countWinners) async {
    state = RaffleModel(name: state.name, numberSpecWinners: state.numberSpecWinners, countWinners: countWinners);
  }
}

final raffleProvider = StateNotifierProvider<RaffleProvider, RaffleModel>((ref) => RaffleProvider());
