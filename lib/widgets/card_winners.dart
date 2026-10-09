import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/providers/winners_provider.dart';
import 'package:raffle_footloose/widgets/card_winning.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';
import 'package:raffle_footloose/widgets/export_winners.dart';

class CardWinners extends ConsumerStatefulWidget {
  final List<Winner> listWinners;

  const CardWinners({
    super.key,
    required this.listWinners,
  });

  @override
  ConsumerState<CardWinners> createState() => _CardWinnersState();
}

class _CardWinnersState extends ConsumerState<CardWinners> {
  String? selectedPrizeKey;

  @override
  void didUpdateWidget(covariant CardWinners oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prizeGroups = _getPrizeGroups(widget.listWinners);
    if (selectedPrizeKey != null &&
        !prizeGroups.any((group) => group.key == selectedPrizeKey)) {
      selectedPrizeKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 700;
    final prizeGroups = _getPrizeGroups(widget.listWinners);
    final selectedGroup = _selectedPrizeGroup(prizeGroups);
    final bool showingSupplements = selectedGroup?.isSupplement ?? false;
    final Color titleColor = showingSupplements ? const Color(0xFF92400E) : const Color(0xFF1F2937);
    final filteredWinners = selectedPrizeKey == null
        ? widget.listWinners
        : widget.listWinners
            .where((winner) => _prizeKey(winner) == selectedPrizeKey)
            .toList();

    return Container(
      padding: EdgeInsets.all(mobile ? 12 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B0764).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: showingSupplements ? const Color(0xFFFFFBEB) : const Color(0xFFF4F0F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  showingSupplements ? Icons.groups_2_rounded : MaterialCommunityIcons.trophy,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showingSupplements ? 'SUPLENTES' : (widget.listWinners.isEmpty ? 'Ganadores' : 'Lista de GANADORES'),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: mobile ? 22 : 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (prizeGroups.isNotEmpty) ...[
            const SizedBox(height: 14),
            _PrizeFilter(
              prizeGroups: prizeGroups,
              selectedPrizeKey: selectedPrizeKey,
              onChanged: (value) => setState(() => selectedPrizeKey = value),
            ),
          ],
          const SizedBox(height: 16),
          if (widget.listWinners.isEmpty)
            const _EmptyWinners()
          else if (filteredWinners.isEmpty)
            const _EmptyFilter()
          else ...[
            ...List.generate(
              filteredWinners.length,
              (index) => CardWinning(
                index: index,
                fullWinner: filteredWinners[index],
              ),
            ),
            const SizedBox(height: 10),
            if (mobile)
              Column(
                children: [
                  const SizedBox(width: double.infinity, child: ExportWinners()),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      type: 'secondary',
                      icon: Icons.delete_sweep_rounded,
                      title: 'LIMPIAR TODO',
                      onTap: () => _showCleanDialog(context, ref),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Expanded(child: ExportWinners()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      type: 'secondary',
                      icon: Icons.delete_sweep_rounded,
                      title: 'LIMPIAR TODO',
                      onTap: () => _showCleanDialog(context, ref),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  _PrizeGroup? _selectedPrizeGroup(List<_PrizeGroup> groups) {
    final key = selectedPrizeKey;
    if (key == null) return null;
    for (final group in groups) {
      if (group.key == key) return group;
    }
    return null;
  }

  List<_PrizeGroup> _getPrizeGroups(List<Winner> winners) {
    final groups = <String, _PrizeGroup>{};
    for (final winner in winners) {
      final prize = winner.premio?.trim();
      if (prize == null || prize.isEmpty) continue;
      final key = _prizeKey(winner);
      groups[key] = _PrizeGroup(key: key, label: _prizeLabel(winner), isSupplement: prize.toLowerCase().contains('suplente'));
    }

    final list = groups.values.toList();
    list.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }

  String _prizeKey(Winner winner) {
    final prize = winner.premio?.trim() ?? '';
    final lote = winner.lote?.toString() ?? '';
    return '$lote|$prize';
  }

  String _prizeLabel(Winner winner) {
    final prize = winner.premio?.trim() ?? '';
    final lote = winner.lote;
    if (prize.isEmpty) return '';
    return lote == null ? prize : '$prize - Lote $lote';
  }

  void _showCleanDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Limpiar todos los ganadores'),
        content: const Text(
          'Esta accion borrara el historial actual. Asegurate de haber exportado a Excel si necesitas los datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final query = QueryService();
              await query.cleanWinners();
              ref.read(raffleProvider.notifier).setCountWinners(-1);
              ref.invalidate(winnersStreamProvider);
            },
            child: const Text(
              'LIMPIAR',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeFilter extends StatelessWidget {
  final List<_PrizeGroup> prizeGroups;
  final String? selectedPrizeKey;
  final ValueChanged<String?> onChanged;

  const _PrizeFilter({
    required this.prizeGroups,
    required this.selectedPrizeKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DDF0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedPrizeKey,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6F359C)),
          hint: const Text(
            'Filtrar por premio',
            style: TextStyle(
              color: Color(0xFF6F359C),
              fontWeight: FontWeight.w800,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos los premios'),
            ),
            ...prizeGroups.map(
              (group) => DropdownMenuItem<String?>(
                value: group.key,
                child: Text(
                  group.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PrizeGroup {
  final String key;
  final String label;

  final bool isSupplement;

  const _PrizeGroup({required this.key, required this.label, this.isSupplement = false});
}

class _EmptyWinners extends StatelessWidget {
  const _EmptyWinners();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFF6F359C),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aun no hay ganadores',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ejecuta el sorteo para revelar los resultados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'No hay ganadores para este premio.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
      ),
    );
  }
}






