import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/focus_list_provider.dart';
import 'package:raffle_footloose/widgets/custom_dialog.dart';

class CardWinning extends ConsumerWidget {
  final Winner fullWinner;

  final int index;

  const CardWinning({
    super.key,
    required this.fullWinner,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        ref.read(focusListProvider.notifier).unfocusAll();
        await showDialog(
          context: context,
          builder: (context) => CustomDialog(winner: fullWinner),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    ("${index + 1}. ${fullWinner.fullName} ").toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1F2937)),
                  )),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF6F359C),
                  )

                ],
              ),
            ),
            const Divider(height: 10)
          ],
        ),
      ),
    );
  }
}
