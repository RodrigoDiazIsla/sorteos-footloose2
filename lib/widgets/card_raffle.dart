import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/config/environment.dart';
import 'package:raffle_footloose/config/special_days.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/count_current_winners.dart';
import 'package:raffle_footloose/providers/current_winner.dart';
import 'package:raffle_footloose/providers/focus_list_provider.dart';
import 'package:raffle_footloose/providers/raffle_image_provider.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/services/isar_service.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';
import 'package:raffle_footloose/widgets/custom_dialog.dart';
import 'package:raffle_footloose/widgets/modal_error.dart';

class CardRaffle extends ConsumerStatefulWidget {
  final int countParticipants;

  const CardRaffle({
    super.key,
    required this.countParticipants,
  });

  @override
  ConsumerState<CardRaffle> createState() => _CardRaffleState();
}

class _CardRaffleState extends ConsumerState<CardRaffle> {
  final TextEditingController numberSpecWinnersController = TextEditingController();
  final TextEditingController awardNameController = TextEditingController();
  bool _isRaffling = false;

  @override
  void initState() {
    super.initState();

    final FocusNode focusNodeAwardName = FocusNode();
    final FocusNode focusNodeNumberSpecWinners = FocusNode();

    Future.microtask(() {
      ref.read(focusListProvider.notifier).setFocusNodes(
            focusNodeAward: focusNodeAwardName,
            focusNodeNumberSpecWinners: focusNodeNumberSpecWinners,
          );
    });
  }

  @override
  void dispose() {
    numberSpecWinnersController.dispose();
    awardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nameImage = getFileImage(Environment.currentSpecialDay);
    final String? customImageUrl = ref.watch(raffleImageProvider);
    final TextTheme textStyle = Theme.of(context).textTheme;
    final focusList = ref.watch(focusListProvider);
    final bool mobile = MediaQuery.sizeOf(context).width < 700;
    final int countWinnersBD = ref.watch(winnersCountProvider).maybeWhen(
          data: (count) => count,
          orElse: () => 0,
        );

    Future<void> resetRaffleState() async {
      ref.read(raffleProvider.notifier).setCountWinners(-1);
      ref.read(currentWinnerProvider.notifier).setCurrentWinner(Winner());
    }

    Future<void> raffle(BuildContext context) async {
      if (_isRaffling) return;

      final String awardName = awardNameController.text.trim();
      final int numberSpecWinners = int.parse(
        numberSpecWinnersController.text.isNotEmpty ? numberSpecWinnersController.text : '0',
      );

      if (widget.countParticipants == 0) {
        await showDialog(
          context: context,
          builder: (context) => const ErrorModal(
            title: 'No se pudo realizar el sorteo',
            errorMessage: 'Actualmente no hay informacion disponible para completar esta accion. Intentalo nuevamente mas tarde.',
          ),
        );
        return;
      }

      if (awardName.isEmpty) {
        await showDialog(
          context: context,
          builder: (context) => ErrorModal(
            title: 'No se pudo realizar el sorteo',
            errorMessage: 'Ingrese un nombre para el premio',
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
            title: 'No se pudo realizar el sorteo',
            errorMessage: 'Ingrese un numero de ganadores',
            onClose: () {
              Navigator.pop(context);
              ref.read(focusListProvider.notifier).focusNumberSpec();
            },
          ),
        );
        return;
      }

      ref.read(raffleProvider.notifier).setRaffleName(awardName);
      setState(() => _isRaffling = true);

      try {
        await resetRaffleState();
        if (!context.mounted) return;

        await showDialog(
          context: context,
          builder: (context) => CustomDialog(numberSpecWinners: numberSpecWinners),
        );

        numberSpecWinnersController.clear();
        awardNameController.clear();
        ref.read(focusListProvider.notifier).unfocusAll();
      } finally {
        if (mounted) {
          setState(() => _isRaffling = false);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B0764).withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: _CampaignImage(nameImage: nameImage, customImageUrl: customImageUrl),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricTile(
                      icon: Icons.groups_rounded,
                      label: 'Participantes',
                      value: widget.countParticipants == -1 ? '...' : '${widget.countParticipants}',
                      featured: true,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: awardNameController,
                  style: textStyle.labelSmall,
                  decoration: const InputDecoration(
                    labelText: 'Premio',
                    prefixIcon: Icon(Icons.card_giftcard, color: Color(0xFF6F359C)),
                    hintText: 'Ej. Gift card Footloose',
                  ),
                  focusNode: focusList.focusNodeAward,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: numberSpecWinnersController,
                  style: textStyle.labelSmall,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de ganadores',
                    prefixIcon: Icon(Icons.people_alt_rounded, color: Color(0xFF6F359C)),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  focusNode: focusList.focusNodeNumberSpecWinners,
                  onSubmitted: (_) => raffle(context),
                ),
                const SizedBox(height: 20),
                if (!mobile)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          icon: Ionicons.flash,
                          title: _isRaffling ? 'SORTEANDO...' : 'SORTEAR',
                          onTap: _isRaffling ? null : () => raffle(context),
                        ),
                      ),
                      if (countWinnersBD > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            type: 'secondary',
                            icon: Icons.delete_outline,
                            title: 'LIMPIAR',
                            onTap: () => clean(ref),
                          ),
                        ),
                      ],
                    ],
                  )
                else ...[
                  CustomButton(
                    icon: Ionicons.flash,
                    title: _isRaffling ? 'SORTEANDO...' : 'SORTEAR',
                    onTap: _isRaffling ? null : () => raffle(context),
                  ),
                  if (countWinnersBD > 0) ...[
                    const SizedBox(height: 12),
                    CustomButton(
                      type: 'secondary',
                      icon: Icons.delete_outline,
                      title: 'LIMPIAR',
                      onTap: () => clean(ref),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void clean(WidgetRef ref) async {
    final QueryService query = QueryService();
    final isar = await IsarService().getIsarInstance();
    if (isar != null) {
      final int currentWinners = await isar.writeTxn(() async => isar.winners.count());
      if (currentWinners > 0) await query.exportAndOpenExcel('list_winners');
      await isar.writeTxn(() async => isar.winners.clear());
    }

    ref.read(raffleProvider.notifier).setCountWinners(-1);
    await query.cleanWinners();
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  final bool featured;

  const _MetricTile({required this.icon, required this.label, required this.value, this.featured = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width < 700 ? double.infinity : null,
      constraints: BoxConstraints(minWidth: featured ? 230 : 140),
      padding: EdgeInsets.symmetric(horizontal: featured ? 22 : 12, vertical: featured ? 18 : 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DDF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6F359C), size: featured ? 34 : 22),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: const Color(0xFF6B7280), fontSize: featured ? 15 : 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: const Color(0xFF3B0764), fontSize: featured ? 42 : 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignImage extends StatelessWidget {
  final String nameImage;
  final String? customImageUrl;

  const _CampaignImage({required this.nameImage, required this.customImageUrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        alignment: Alignment.topCenter,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = customImageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image/')) {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          return Image.memory(
            base64Decode(imageUrl.substring(commaIndex + 1)),
            width: double.infinity,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => _defaultImage(),
          );
        }
      }

      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _defaultImage(),
      );
    }

    return _defaultImage();
  }

  Widget _defaultImage() {
    return Image.asset(
      nameImage,
      width: double.infinity,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}









