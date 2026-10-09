import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/focus_list_provider.dart';
import 'package:raffle_footloose/widgets/custom_dialog.dart';

class CardWinning extends ConsumerWidget {
  final Winner fullWinner;
  final int index;
  final String fallbackPrize;

  const CardWinning({
    super.key,
    required this.fullWinner,
    required this.index,
    this.fallbackPrize = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool compact = MediaQuery.sizeOf(context).width < 380;
    final prize = _prizeLabel();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            ref.read(focusListProvider.notifier).unfocusAll();
            await showDialog(
              context: context,
              builder: (context) => CustomDialog(winner: _winnerWithPrize(prize)),
            );
          },
          child: Container(
            padding: EdgeInsets.all(compact ? 10 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 36 : 42,
                  height: compact ? 36 : 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF6F359C),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: compact ? MediaQuery.sizeOf(context).width * 0.46 : 220),
                            child: Text(
                              (fullWinner.fullName ?? '-').toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2937)),
                            ),
                          ),
                          _PrizeBadge(value: prize),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _TinyInfo(icon: Icons.confirmation_number_rounded, value: fullWinner.code ?? '-'),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFF6F359C)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _prizeLabel() {
    final prize = fullWinner.premio?.trim();
    if (prize != null && prize.isNotEmpty) {
      return fullWinner.lote == null ? prize : prize + ' - Lote ' + fullWinner.lote.toString();
    }
    final fallback = fallbackPrize.trim();
    return fallback.isNotEmpty ? fallback : 'Premio';
  }

  Winner _winnerWithPrize(String prize) {
    if (fullWinner.premio?.trim().isNotEmpty ?? false) return fullWinner;
    return Winner()
      ..id = fullWinner.id
      ..index = fullWinner.index
      ..fullName = fullWinner.fullName
      ..document = fullWinner.document
      ..email = fullWinner.email
      ..code = fullWinner.code
      ..phone = fullWinner.phone
      ..phoneRaw = fullWinner.phoneRaw
      ..premio = prize
      ..ubicacion = fullWinner.ubicacion
      ..tienda = fullWinner.tienda
      ..lote = fullWinner.lote;
  }
}

class _PrizeBadge extends StatelessWidget {
  final String value;

  const _PrizeBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final bool alternate = value.toLowerCase().contains('suplente');

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width < 380 ? 140 : 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: alternate ? const Color(0xFFFFFBEB) : const Color(0xFFF4F0F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: alternate ? const Color(0xFFD4AF37) : const Color(0xFFE6DDF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.card_giftcard_rounded, size: 13, color: alternate ? const Color(0xFFD4AF37) : const Color(0xFF6F359C)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: alternate ? const Color(0xFF92400E) : const Color(0xFF6F359C),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  final IconData icon;
  final String value;

  const _TinyInfo({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width < 380 ? MediaQuery.sizeOf(context).width * 0.58 : 180),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}




