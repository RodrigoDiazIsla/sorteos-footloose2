import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/model/raffle_model.dart';
import 'package:raffle_footloose/providers/current_winner.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/widgets/casino_code_spinner.dart';
import 'package:raffle_footloose/widgets/modal_error.dart';
import 'package:raffle_footloose/widgets/user_information.dart';

class LoaderSequence extends ConsumerStatefulWidget {
  final int numberSpecWinners;

  const LoaderSequence({
    super.key,
    required this.numberSpecWinners,
  });

  @override
  LoaderSequenceState createState() => LoaderSequenceState();
}

class LoaderSequenceState extends ConsumerState<LoaderSequence> {
  List<Winner> winnersList = [];
  Winner winner = Winner();

  bool dataReady = false;
  bool showWinnerInfo = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final QueryService query = QueryService();
      final RaffleModel raffleData = ref.read(raffleProvider);
      final String nameAward = raffleData.name;

      final List<Winner> winners = await query.fetchWinner(nameAward, widget.numberSpecWinners);
      winnersList = winners;

      final int countWinners = winners.length;
      if (countWinners == 1) {
        winner = winners.first;
        ref.read(currentWinnerProvider.notifier).setCurrentWinner(winner);
      }
      ref.read(raffleProvider.notifier).setCountWinners(countWinners);

      setState(() {
        dataReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      await showDialog(
        context: context,
        builder: (context) => ErrorModal(
          title: 'No se pudo realizar el sorteo',
          errorMessage: 'Ocurrio un error al realizar el sorteo\n$errorMessage',
          onClose: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showWinnerInfo) {
      return UserInformation(
        winner: winner,
        winnersList: winnersList,
        numberSpecWinners: widget.numberSpecWinners,
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF4F0F9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: !dataReady
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6DDF0)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6F359C), strokeWidth: 3),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'PREPARANDO EL SORTEO',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF3B0764),
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estamos seleccionando los resultados.',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : CasinoCodeSpinner(
                targetCode: widget.numberSpecWinners == 1 ? (winner.code ?? '00000000') : 'GANADORES',
                onComplete: () {
                  setState(() {
                    showWinnerInfo = true;
                  });
                },
              ),
      ),
    );
  }
}
