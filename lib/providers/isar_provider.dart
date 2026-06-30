import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:raffle_footloose/services/isar_service.dart';

final isarServiceProvider = Provider((ref) => IsarService());

final isarProvider = FutureProvider<Isar?>((ref) async {
  final isarService = ref.read(isarServiceProvider);
  return await isarService.getIsarInstance();
});

