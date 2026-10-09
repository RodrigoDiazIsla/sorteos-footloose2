import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CasinoCodeSpinner extends StatefulWidget {
  final String targetCode;
  final VoidCallback onComplete;

  const CasinoCodeSpinner({
    super.key,
    required this.targetCode,
    required this.onComplete,
  });

  @override
  State<CasinoCodeSpinner> createState() => _CasinoCodeSpinnerState();
}

class _CasinoCodeSpinnerState extends State<CasinoCodeSpinner> {
  late List<String> currentDigits;
  late List<bool> isStopped;
  Timer? timer;
  int stoppedCount = 0;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    final int length = max(8, widget.targetCode.length);
    currentDigits = List.generate(length, (_) => random.nextInt(10).toString());
    isStopped = List.generate(length, (_) => false);
    _startSpinning();
  }

  void _startSpinning() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < currentDigits.length; i++) {
          if (!isStopped[i]) {
            currentDigits[i] = random.nextInt(10).toString();
          }
        }
      });
    });
    _stopDigit(0);
  }

  void _stopDigit(int index) {
    if (index >= currentDigits.length) {
      timer?.cancel();
      Future.delayed(const Duration(milliseconds: 700), widget.onComplete);
      return;
    }

    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) {
        setState(() {
          final String target = widget.targetCode.padLeft(currentDigits.length, '0');
          currentDigits[index] = target[index];
          isStopped[index] = true;
          stoppedCount++;
        });
        _stopDigit(index + 1);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 420;
        final double horizontalPadding = compact ? 10 : 20;
        final double availableWidth = max(180, constraints.maxWidth - (horizontalPadding * 2));
        final double gap = compact ? 4 : 8;
        final double rawDigitWidth = (availableWidth - (gap * (currentDigits.length - 1))) / currentDigits.length;
        final double digitWidth = rawDigitWidth.clamp(compact ? 22 : 38, compact ? 42 : 70).toDouble();
        final double digitHeight = digitWidth * 1.38;
        final double digitFont = digitWidth * 0.68;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: compact ? 24 : 34),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: availableWidth),
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18, vertical: compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B0764),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.65)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'DESCUBRIENDO GANADOR',
                  style: GoogleFonts.outfit(
                    fontSize: compact ? 11 : 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                      letterSpacing: compact ? 0.6 : 1.8,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 28 : 44),
              SizedBox(
                width: availableWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(currentDigits.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: index == currentDigits.length - 1 ? 0 : gap),
                      child: _buildDigitCard(
                        currentDigits[index],
                        isStopped[index],
                        digitWidth,
                        digitHeight,
                        digitFont,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: compact ? 24 : 34),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: stoppedCount / currentDigits.length,
                  backgroundColor: const Color(0xFFF4F0F9),
                  color: const Color(0xFFD4AF37),
                  minHeight: 9,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDigitCard(String digit, bool stopped, double width, double height, double fontSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: stopped ? [const Color(0xFF6F359C), const Color(0xFF3B0764)] : [Colors.white, const Color(0xFFF4F0F9)],
        ),
        borderRadius: BorderRadius.circular(width < 34 ? 8 : 12),
        border: Border.all(
          color: stopped ? const Color(0xFFD4AF37) : const Color(0xFF6F359C).withOpacity(0.35),
          width: width < 34 ? 1.2 : (stopped ? 3 : 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: stopped ? const Color(0xFFD4AF37).withOpacity(0.28) : Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: stopped ? Colors.white : const Color(0xFF6F359C),
          ),
        ),
      ),
    );
  }
}
