import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';

class CurrentWinner extends StateNotifier<Winner> {
  CurrentWinner() : super(Winner());

  void setCurrentWinner(Winner winner) {
    state = winner;
  }
}

final currentWinnerProvider = StateNotifierProvider<CurrentWinner, Winner>((ref) => CurrentWinner());

