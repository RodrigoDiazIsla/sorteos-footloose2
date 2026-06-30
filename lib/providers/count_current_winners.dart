import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/services/isar_service.dart';

final winnersCountProvider = StreamProvider<int>((ref) async* {
  final isar = await IsarService().getIsarInstance();

  if (isar == null) {
    yield 0;
    return;
  }

  // Emitimos el valor actual
  final initialCount = await isar.winners.count();
  yield initialCount;

  // Luego seguimos escuchando los cambios
  yield* isar.winners.watchLazy().asyncMap((_) async {
    return await isar.winners.count();
  });
});

