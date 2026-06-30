import 'package:flutter/material.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/widgets/loader_sequence.dart';
import 'package:raffle_footloose/widgets/user_information.dart';

class CustomDialog extends StatefulWidget {
  final Winner? winner;

  final bool loadingWinner = false;
  final int numberSpecWinners;

  const CustomDialog({
    super.key,
    this.winner,
    this.numberSpecWinners = 1,
  });

  @override
  CustomDialogState createState() => CustomDialogState();
}

class CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile();
    return PopScope(
      canPop: false,
      child: Dialog(
        child: SizedBox(
          height: mobile ? MediaQuery.of(context).size.height * 0.75 : 750,
          width: mobile ? MediaQuery.of(context).size.width : 1100,

          child: Center(
              child: widget.winner != null
                  ? UserInformation(
                      // Detail winner
                      winner: widget.winner!,
                      isDetail: true,
                    )
                  : LoaderSequence(
                      // Winner in progress
                      numberSpecWinners: widget.numberSpecWinners,
                    )),
        ),
      ),
    );
  }
}
