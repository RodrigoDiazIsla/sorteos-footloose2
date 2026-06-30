import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/providers/winners_provider.dart';
import 'package:raffle_footloose/widgets/card_winning.dart';
import 'package:raffle_footloose/widgets/export_winners.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';


class CardWinners extends ConsumerWidget {
  final List<Winner> listWinners;

  const CardWinners({
    super.key,
    required this.listWinners,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raffleData = ref.watch(raffleProvider);

    return listWinners.isNotEmpty
        ? Column(
            children: [
              // 🟣 Header dinámico morado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B0764),
                      Color(0xFF6F359C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      MaterialCommunityIcons.trophy,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Lista de ganadores - ${raffleData.name} (total: ${listWinners.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🟦 Contenedor blanco con sombra
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffEDEDED)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      offset: Offset(0, 4),
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: List.generate(
                    listWinners.length,
                    (index) {
                      final winner = listWinners[index];
                      return CardWinning(
                        index: index,
                        fullWinner: winner,
                      );
                    },
                  ),
                ),
              ),

              // 📤 Exportar y Limpiar (Responsivo)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: isMobile() 
                  ? Column(
                      children: [
                        const SizedBox(width: double.infinity, child: ExportWinners()),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            type: "secondary",
                            icon: Icons.delete_sweep_rounded,
                            title: "LIMPIAR TODO",
                            onTap: () => _showCleanDialog(context, ref),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Expanded(child: ExportWinners()),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustomButton(
                            type: "secondary",
                            icon: Icons.delete_sweep_rounded,
                            title: "LIMPIAR TODO",
                            onTap: () => _showCleanDialog(context, ref),
                          ),
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 40),
            ],
          )
        : const SizedBox.shrink();
  }

  void _showCleanDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Limpiar todos los ganadores?"),
        content: const Text(
            "Esta acción borrará el historial actual. Asegúrate de haber exportado a Excel si necesitas los datos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final query = QueryService();
              await query.cleanWinners();
              ref.read(raffleProvider.notifier).setCountWinners(-1);
              ref.invalidate(winnersStreamProvider);
            },
            child: const Text("LIMPIAR",
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
