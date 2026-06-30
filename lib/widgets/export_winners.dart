import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';

class ExportWinners extends ConsumerWidget {
  const ExportWinners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      icon: Icons.table_view_rounded,
      title: "EXPORTAR (EXCEL)", // Texto más corto para evitar overflow
      onTap: () => exportWinnersDB(ref),
    );
  }

  Future<void> exportWinnersDB(WidgetRef ref) async {
    final QueryService query = QueryService();
    final nameAward = ref.read(raffleProvider).name;
    final nameFile = nameAward.isEmpty ? "reporte_ganadores_footloose" : "ganadores_$nameAward";
    await query.exportAndOpenExcel(nameFile);
  }
}
