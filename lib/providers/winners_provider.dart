import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';

final winnersStreamProvider = StreamProvider<List<Winner>>((ref) async* {
  final query = QueryService();
  
  // Emitir el primer resultado de inmediato
  yield await query.fetchWinnersList();

  // Crear un timer para actualizar cada 5 segundos (opcional, pero útil)
  final controller = StreamController<List<Winner>>();
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      final winners = await query.fetchWinnersList();
      if (!controller.isClosed) {
        controller.add(winners);
      }
    } catch (e) {
      // Ignorar errores de red temporales
    }
  });

  ref.onDispose(() {
    controller.close();
  });

  yield* controller.stream;
});
