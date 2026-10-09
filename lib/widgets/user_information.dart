import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raffle_footloose/api/query_service.dart';
import 'package:raffle_footloose/helpers/hide_data.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/current_winner.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';

class UserInformation extends ConsumerStatefulWidget {
  final Winner winner;
  final List<Winner>? winnersList;
  final bool isDetail;
  final int numberSpecWinners;

  const UserInformation({
    super.key,
    required this.winner,
    this.winnersList,
    this.isDetail = false,
    this.numberSpecWinners = 1,
  });

  @override
  ConsumerState<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends ConsumerState<UserInformation> {
  late Winner _winner;
  late List<Winner>? _winnersList;
  bool _loadingAlternates = false;
  String? _currentPrize;
  late final PageController _carouselController;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _winner = widget.winner;
    _winnersList = widget.winnersList;
    _carouselController = PageController(viewportFraction: 0.86);
  }


  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 700;
    final raffleData = ref.watch(raffleProvider);
    final Winner providerWinner = ref.watch(currentWinnerProvider);
    final Winner currentWinner = widget.isDetail ? _winner : _winnerWithFallback(providerWinner);
    final Winner prizeSourceWinner = widget.numberSpecWinners > 1 && (_winnersList?.isNotEmpty ?? false)
        ? _winnersList!.first
        : currentWinner;
    final String nameAward = _resolvePrize(prizeSourceWinner, raffleData.name);
    final bool isSupplement = _isSupplementPrize(nameAward);
    final String resultLabel = isSupplement ? 'SUPLENTES' : 'GANADORES';
    final String singularLabel = isSupplement ? 'SUPLENTE' : 'GANADOR';
    final Color headerIconColor = const Color(0xFFD4AF37);
    final Color accentColor = isSupplement ? const Color(0xFFD4AF37) : const Color(0xFF6F359C);
    final Color darkColor = isSupplement ? const Color(0xFF7C2D12) : const Color(0xFF3B0764);
    final int totalWinners = _winnersList?.length ?? widget.numberSpecWinners;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(mobile ? 16 : 36, mobile ? 20 : 34, mobile ? 16 : 36, mobile ? 20 : 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSupplement ? const [Color(0xFF7C2D12), Color(0xFFD4AF37)] : const [Color(0xFF3B0764), Color(0xFF6F359C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: mobile ? 68 : 86,
                  height: mobile ? 68 : 86,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: headerIconColor, width: 2),
                  ),
                  child: Icon(isSupplement ? Icons.groups_2_rounded : Icons.emoji_events_rounded, size: mobile ? 40 : 50, color: headerIconColor),
                ),
                const SizedBox(height: 18),
                Text(
                  totalWinners == 1 ? 'Tenemos 1 ' + singularLabel : 'Tenemos ' + totalWinners.toString() + ' ' + resultLabel,
                  style: GoogleFonts.outfit(
                    fontSize: mobile ? 24 : 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Premio: ' + _displayPrize(nameAward),
                  style: GoogleFonts.outfit(fontSize: mobile ? 16 : 22, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.92)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 10 : 28),
            child: Column(
              children: [
                if (_loadingAlternates)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: CircularProgressIndicator(color: Color(0xFF6F359C)),
                  )
                else if (widget.numberSpecWinners == 1)
                  _buildWinnerCard(context, currentWinner, mobile, singularLabel, accentColor, darkColor)
                else if (_winnersList != null)
                  _buildWinnersCarousel(context, _winnersList!, mobile),
                Padding(
                  padding: EdgeInsets.only(top: mobile ? 18 : 26),
                  child: mobile
                      ? Column(
                          children: [
                            if (!widget.isDetail && !isSupplement) ...[
                              CustomButton(
                                type: 'secondary',
                                icon: Icons.group_add_rounded,
                                title: _loadingAlternates ? 'SORTEANDO...' : 'SORTEAR SUPLENTES',
                                onTap: _loadingAlternates ? null : () => _drawAlternates(nameAward),
                              ),
                              const SizedBox(height: 12),
                            ],
                            CustomButton(
                              title: 'CONTINUAR',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!widget.isDetail && !isSupplement) ...[
                              SizedBox(
                                width: 240,
                                child: CustomButton(
                                  type: 'secondary',
                                  icon: Icons.group_add_rounded,
                                  title: _loadingAlternates ? 'SORTEANDO...' : 'SORTEAR SUPLENTES',
                                  onTap: _loadingAlternates ? null : () => _drawAlternates(nameAward),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            SizedBox(
                              width: 240,
                              child: CustomButton(
                                title: 'CONTINUAR',
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Winner _winnerWithFallback(Winner providerWinner) {
    final hasLocalWinner = (_winner.fullName?.isNotEmpty ?? false) || (_winner.code?.isNotEmpty ?? false);
    return hasLocalWinner ? _winner : providerWinner;
  }

  String _resolvePrize(Winner currentWinner, String raffleName) {
    final explicitPrize = _currentPrize ?? currentWinner.premio?.trim();
    if (explicitPrize != null && explicitPrize.isNotEmpty) return explicitPrize;
    if (raffleName.trim().isNotEmpty) return raffleName.trim();
    return '-';
  }

  bool _isSupplementPrize(String prize) {
    return prize.toLowerCase().contains('suplente');
  }

  String _displayPrize(String prize) {
    return prize.replaceAll(RegExp(r'\s*\(suplente\)\s*$', caseSensitive: false), '').trim();
  }

  String _supplementPrizeName(String prize) {
    final cleanPrize = prize.replaceAll(RegExp(r'\s*\(suplente\)\s*$', caseSensitive: false), '').trim();
    return '$cleanPrize (suplente)';
  }

  Future<void> _drawAlternates(String currentPrize) async {
    final prize = _supplementPrizeName(currentPrize == '-' ? ref.read(raffleProvider).name : currentPrize);
    if (prize.trim().isEmpty) return;

    setState(() => _loadingAlternates = true);

    try {
      final winners = await QueryService().fetchWinner(prize, widget.numberSpecWinners);
      if (!mounted) return;

      if (winners.length == 1) {
        _winner = winners.first;
        ref.read(currentWinnerProvider.notifier).setCurrentWinner(_winner);
      }

      setState(() {
        _currentPrize = prize;
        _winnersList = winners;
        _carouselIndex = 0;
        _loadingAlternates = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingAlternates = false);
    }
  }

  Widget _buildWinnersCarousel(BuildContext context, List<Winner> winners, bool mobile) {
    final prize = _resolvePrize(winners.first, _currentPrize ?? ref.read(raffleProvider).name);
    final isSupplement = _isSupplementPrize(prize);
    final singularLabel = isSupplement ? 'SUPLENTE' : 'GANADOR';
    final accentColor = isSupplement ? const Color(0xFFD4AF37) : const Color(0xFF6F359C);
    final darkColor = isSupplement ? const Color(0xFF7C2D12) : const Color(0xFF3B0764);
    final visibleWinner = winners[_carouselIndex.clamp(0, winners.length - 1)];
    final hasStoreData = _hasStoreData(visibleWinner);
    final height = hasStoreData ? (mobile ? 440.0 : 472.0) : (mobile ? 360.0 : 392.0);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScrollConfiguration(
                  behavior: const _CarouselScrollBehavior(),
                  child: PageView.builder(
                    controller: _carouselController,
                    physics: const PageScrollPhysics(),
                    padEnds: true,
                    itemCount: winners.length,
                    onPageChanged: (index) => setState(() => _carouselIndex = index),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildWinnerCard(context, winners[index], mobile, singularLabel, accentColor, darkColor),
                    ),
                  ),
                ),
                if (!mobile && winners.length > 1) ...[
                  if (_carouselIndex > 0)
                    Positioned(left: 8, child: _CarouselButton(icon: Icons.chevron_left_rounded, onTap: () => _moveCarousel(-1, winners.length))),
                  if (_carouselIndex < winners.length - 1)
                    Positioned(right: 8, child: _CarouselButton(icon: Icons.chevron_right_rounded, onTap: () => _moveCarousel(1, winners.length))),
                ],
              ],
            ),
          ),
          if (winners.length > 1) ...[
            const SizedBox(height: 6),
            Text('Resultado ' + (_carouselIndex + 1).toString() + ' de ' + winners.length.toString(), style: GoogleFonts.outfit(fontSize: mobile ? 13 : 15, fontWeight: FontWeight.w800, color: const Color(0xFF6B7280))),
          ],
        ],
      ),
    );
  }

  void _moveCarousel(int direction, int total) {
    if (total <= 1) return;
    final rawIndex = _carouselIndex + direction;
    final int nextIndex = rawIndex < 0 ? 0 : (rawIndex >= total ? total - 1 : rawIndex);
    _carouselController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildWinnerCard(BuildContext context, Winner winner, bool mobile, String codeLabel, Color accentColor, Color darkColor) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 620),
      padding: EdgeInsets.all(mobile ? 12 : 18),
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
        children: [
          Text(
            (winner.fullName ?? '-').toUpperCase(),
            style: GoogleFonts.outfit(fontSize: mobile ? 19 : 28, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoPill(context, Icons.badge_rounded, 'DNI', hideData(winner.document ?? '-'), mobile),
              _buildInfoPill(context, Icons.email_rounded, 'Email', hideData(winner.email ?? '-'), mobile),
              _buildInfoPill(context, Icons.phone_rounded, 'Celular', hideData(winner.phone ?? '-'), mobile),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: mobile ? 10 : 16, vertical: mobile ? 12 : 14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor, width: 1.7),
            ),
            child: Column(
              children: [
                Text(
                  'CODIGO DE ' + codeLabel,
                  style: GoogleFonts.outfit(fontSize: mobile ? 13 : 15, fontWeight: FontWeight.w900, color: accentColor),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    winner.code ?? '-',
                    style: GoogleFonts.outfit(
                      fontSize: mobile ? 34 : 44,
                      fontWeight: FontWeight.w900,
                      color: darkColor,
                      letterSpacing: mobile ? 1.5 : 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_hasStoreData(winner)) ...[
            const SizedBox(height: 10),
            _buildStoreInfoStack(context, winner, mobile),
          ],
        ],
      ),
    );
  }

  bool _hasStoreData(Winner winner) {
    return (winner.ubicacion ?? '').trim().isNotEmpty ||
        (winner.tienda ?? '').trim().isNotEmpty;
  }

  Widget _buildStoreInfoStack(BuildContext context, Winner winner, bool mobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((winner.ubicacion ?? '').trim().isNotEmpty)
            _buildInfoPill(
              context,
              Icons.location_on_rounded,
              'Ubicacion',
              winner.ubicacion!.trim(),
              mobile,
              expanded: true,
            ),
          if ((winner.ubicacion ?? '').trim().isNotEmpty &&
              (winner.tienda ?? '').trim().isNotEmpty)
            const SizedBox(height: 10),
          if ((winner.tienda ?? '').trim().isNotEmpty)
            _buildInfoPill(
              context,
              Icons.storefront_rounded,
              'Tienda',
              winner.tienda!.trim(),
              mobile,
              expanded: true,
            ),
        ],
      ),
    );
  }
  Widget _buildInfoPill(BuildContext context, IconData icon, String label, String value, bool mobile, {bool expanded = false}) {
    final double maxWidth = expanded ? (mobile ? MediaQuery.sizeOf(context).width - 48 : 520) : (mobile ? MediaQuery.sizeOf(context).width - 56 : 460);

    return Container(
      width: expanded ? double.infinity : null,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 14, vertical: mobile ? 8 : 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(expanded ? 12 : 999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: mobile ? 18 : 20, color: const Color(0xFF6F359C)),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.outfit(fontSize: mobile ? 14 : 15, color: const Color(0xFF6B7280), fontWeight: FontWeight.w700)),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: mobile ? 14 : 15, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }
}
class _CarouselButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: const Color(0xFF3B0764).withOpacity(0.24),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE6DDF0)),
          ),
          child: Icon(icon, color: const Color(0xFF6F359C), size: 34),
        ),
      ),
    );
  }
}
class _CarouselScrollBehavior extends MaterialScrollBehavior {
  const _CarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}









