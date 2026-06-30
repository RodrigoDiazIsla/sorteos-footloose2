import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/config/environment.dart';
import 'package:raffle_footloose/config/special_days.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/model/winners_model.dart';
import 'package:raffle_footloose/providers/count_current_winners.dart';
import 'package:raffle_footloose/providers/focus_list_provider.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/services/isar_service.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';
import 'package:raffle_footloose/widgets/custom_dialog.dart';
import 'package:raffle_footloose/widgets/modal_error.dart';

class CardRaffle extends ConsumerStatefulWidget {
  final int countParticipants;
  final WinnersModel winnerBD = WinnersModel();

  CardRaffle({
    super.key,
    required this.countParticipants,
  });

  @override
  ConsumerState<CardRaffle> createState() => _CardRaffleState();
}

class _CardRaffleState extends ConsumerState<CardRaffle> {
  TextEditingController numberSpecWinnersController = TextEditingController();
  TextEditingController awardNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FocusNode focusNodeAwardName = FocusNode();
    FocusNode focusNodeNumberSpecWinners = FocusNode();

    Future.microtask(() {
      ref.read(focusListProvider.notifier).setFocusNodes(
            focusNodeAward: focusNodeAwardName,
            focusNodeNumberSpecWinners: focusNodeNumberSpecWinners,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameImage = getFileImage(Environment.currentSpecialDay);
    final textStyle = Theme.of(context).textTheme;
    final focusList = ref.watch(focusListProvider);

    Future<void> resetLocalWinners() async {
      final isar = await IsarService().getIsarInstance();
      if (isar != null) {
        await isar.writeTxn(() async => await isar.winners.clear());
      }
    }



    void raffle(BuildContext context) async {
      String awardName = awardNameController.text;
      int numberSpecWinners = int.parse(numberSpecWinnersController.text.isNotEmpty ? numberSpecWinnersController.text : "0");

      if (widget.countParticipants == 0) {
        await showDialog(
          context: context,
          builder: (context) => const ErrorModal(
            title: "No se pudo realizar el sorteo",
            errorMessage: "Actualmente no hay información disponible para completar esta acción. Inténtalo nuevamente más tarde.",
          ),
        );
        return;
      }

      if (awardName == "") {
        await showDialog(
          context: context,
          builder: (context) => ErrorModal(
            title: "No se pudo realizar el sorteo",
            errorMessage: "Ingrese un nombre para el premio",
            onClose: () {
              Navigator.pop(context);
              ref.read(focusListProvider.notifier).focusAward();
            },
          ),
        );
        return;
      }

      if (numberSpecWinners == 0) {
        await showDialog(
          context: context,
          builder: (context) => ErrorModal(
            title: "No se pudo realizar el sorteo",
            errorMessage: "Ingrese un número de ganadores",
            onClose: () {
              Navigator.pop(context);
              // focusNodeNumberSpecWinners.requestFocus();
              ref.read(focusListProvider.notifier).focusNumberSpec();
            },
          ),
        );
        return;
      }
      ref.read(raffleProvider.notifier).setRaffleName(awardName);

      await resetLocalWinners(); // Limpiar lista de ganadores local

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => CustomDialog(numberSpecWinners: numberSpecWinners),
      );

      numberSpecWinnersController.text = "";
      awardNameController.text = "";

      // focusNodeAwardName.unfocus();
      // focusNodeNumberSpecWinners.unfocus();
      ref.read(focusListProvider.notifier).unfocusAll();
    }

    final countWinnersBD = ref.watch(winnersCountProvider).maybeWhen(
          data: (count) => count,
          orElse: () => 0,
        );

    final bool mobile = isMobile();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 32 : 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6F359C).withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Sección del Banner más grande con Morado Profundo
                Container(
                  width: double.infinity,
                  color: const Color(0xFF3B0764), // Morado Profundo oficial
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      nameImage,
                      fit: BoxFit.contain, // Para que se vea la imagen completa
                      width: double.infinity,
                    ),

                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    spacing: 24,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("N° de Participantes: ", style: textStyle.labelMedium),
                          widget.countParticipants == -1
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6F359C)),
                                )
                              : Text("${widget.countParticipants}", style: textStyle.titleMedium)
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F0F9), // Lavanda Suave
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          spacing: 16,
                          children: [
                            TextField(
                              controller: awardNameController,
                              style: textStyle.labelSmall,
                              decoration: InputDecoration(
                                labelText: "Premio",
                                labelStyle: const TextStyle(color: Color(0xFF6F359C)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF6F359C)),
                                ),
                                prefixIcon: const Icon(Icons.card_giftcard, color: Color(0xFF6F359C)),
                                hintText: "Ej. Laptop Gamer",
                              ),
                              focusNode: focusList.focusNodeAward,
                            ),
                            TextField(
                              controller: numberSpecWinnersController,
                              style: textStyle.labelSmall,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Ganadores",
                                labelStyle: const TextStyle(color: Color(0xFF6F359C)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF6F359C)),
                                ),
                                prefixIcon: const Icon(Icons.people, color: Color(0xFF6F359C)),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3)
                              ],
                              focusNode: focusList.focusNodeNumberSpecWinners,
                              onSubmitted: (_) => raffle(context),
                            )
                          ],
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: !mobile
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      icon: Ionicons.flash,
                                      title: "SORTEAR",
                                      onTap: () => raffle(context),
                                    ),
                                  ),
                                  if (countWinnersBD > 0) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomButton(
                                        type: "secondary",
                                        icon: Icons.delete_outline,
                                        title: "LIMPIAR",
                                        onTap: () => clean(ref),
                                      ),
                                    ),
                                  ]
                                ],
                              )
                            : Column(
                                children: [
                                  CustomButton(
                                    icon: Ionicons.flash,
                                    title: "SORTEAR",
                                    onTap: () => raffle(context),
                                  ),
                                  if (countWinnersBD > 0) ...[
                                    const SizedBox(height: 16),
                                    CustomButton(
                                      type: "secondary",
                                      icon: Icons.delete_outline,
                                      title: "LIMPIAR",
                                      onTap: () => clean(ref),
                                    ),
                                  ]
                                ],
                              ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

  }

  void clean(WidgetRef ref) async {
    final QueryService query = QueryService();
    final isar = await IsarService().getIsarInstance();
    if (isar != null) {
      final int currentWinners = await isar.writeTxn(() async => await isar.winners.count());
      if (currentWinners > 0) await query.exportAndOpenExcel("list_winners");
      await isar.writeTxn(() async => await isar.winners.clear());
    }

    ref.read(raffleProvider.notifier).setCountWinners(-1);
    await query.cleanWinners();
  }

}

// TODO: Migrar a StatefulWidget
