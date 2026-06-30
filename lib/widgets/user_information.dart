import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/helpers/hide_data.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/providers/current_winner.dart';
import 'package:raffle_footloose/providers/raffle_provider.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';
import 'package:raffle_footloose/widgets/animated_digit_code.dart';

class UserInformation extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool mobile = isMobile();
    final raffleData = ref.watch(raffleProvider);
    final winnerBD = ref.watch(currentWinnerProvider);
    final Winner currentWinner = isDetail ? winner : winnerBD;

    final nameAward = numberSpecWinners == 1 ? currentWinner.premio : raffleData.name;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: mobile ? 10 : 40),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Color(0xFFD4AF37)),
            Padding(
              padding: EdgeInsets.only(top: mobile ? 22 : 32, bottom: mobile ? 15 : 20),
              child: Column(
                children: [
                  Text(
                    numberSpecWinners == 1 ? "¡TENEMOS UN GANADOR!" : "¡TENEMOS ${winnersList?.length ?? numberSpecWinners} GANADORES!",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6F359C),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Premio: $nameAward",
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (numberSpecWinners == 1)
              _buildWinnerCard(context, currentWinner, mobile)
            else if (winnersList != null)
              ...winnersList!.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildWinnerCard(context, w, mobile),
              )),
            Padding(
              padding: EdgeInsets.symmetric(vertical: mobile ? 20 : 40),
              child: CustomButton(
                title: "CONTINUAR",
                onTap: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard(BuildContext context, Winner winner, bool mobile) {
    return Container(
      width: mobile ? MediaQuery.of(context).size.width * 0.85 : 450,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6F359C).withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            (winner.fullName ?? "-").toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          _buildInfoRow(Icons.badge, "DNI", hideData(winner.document ?? "-")),
          _buildInfoRow(Icons.email, "Email", hideData(winner.email ?? "-")),
          _buildInfoRow(Icons.phone, "Celular", hideData(winner.phone ?? "-")),
          const SizedBox(height: 20),
          Text(
            "CÓDIGO DE GANADOR:",
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6F359C)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6F359C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6F359C).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Text(
              winner.code ?? "-",
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6F359C)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF9CA3AF)),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}
