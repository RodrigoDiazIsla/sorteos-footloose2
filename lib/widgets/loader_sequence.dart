import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/model/raffle_model.dart';
import 'package:raffle_footloose/providers/current_winner.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/widgets/modal_error.dart';
import 'package:raffle_footloose/widgets/user_information.dart';
import 'package:raffle_footloose/widgets/casino_code_spinner.dart';



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
  late bool loading;
  List<Winner> winnersList = [];
  Winner winner = Winner();

  bool dataReady = false;
  bool showWinnerInfo = false;

  @override
  void initState() {
    super.initState();
    loading = false;
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
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      await showDialog(
        context: context,
        builder: (context) => ErrorModal(
          title: "No se pudo realizar el sorteo",
          errorMessage: "Ocurrió un error al realizar el sorteo \n $errorMessage",
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


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!dataReady)
          Column(
            children: [
              const CircularProgressIndicator(color: Color(0xFF6F359C)),
              const SizedBox(height: 20),
              Text(
                "PREPARANDO EL SORTEO...",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF6F359C),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        if (dataReady)
          CasinoCodeSpinner(
            targetCode: widget.numberSpecWinners == 1 ? (winner.code ?? "0000000000") : "GANADORES",
            onComplete: () {
              setState(() {
                showWinnerInfo = true;
              });
            },
          ),

      ],
    );
  }
}

