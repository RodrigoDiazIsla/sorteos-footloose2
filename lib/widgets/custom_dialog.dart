import 'package:flutter/material.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/widgets/loader_sequence.dart';
import 'package:raffle_footloose/widgets/user_information.dart';

class CustomDialog extends StatefulWidget {
  final Winner? winner;
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
    final bool mobile = MediaQuery.sizeOf(context).width < 700;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: mobile ? 8 : 28, vertical: mobile ? 10 : 28),
        child: Container(
          constraints: BoxConstraints(
            minHeight: mobile ? MediaQuery.of(context).size.height * 0.62 : 620,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
            maxWidth: mobile ? MediaQuery.of(context).size.width - 16 : 1280,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.winner != null
              ? UserInformation(
                  winner: widget.winner!,
                  isDetail: true,
                )
              : LoaderSequence(numberSpecWinners: widget.numberSpecWinners),
        ),
      ),
    );
  }
}

