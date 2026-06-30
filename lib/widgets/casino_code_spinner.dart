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
    int length = max(10, widget.targetCode.length);
    currentDigits = List.generate(length, (_) => random.nextInt(10).toString());
    isStopped = List.generate(length, (_) => false);
    _startSpinning();
  }

  void _startSpinning() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
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
      Future.delayed(const Duration(milliseconds: 800), widget.onComplete);
      return;
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          String target = widget.targetCode.padLeft(currentDigits.length, '0');
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF6F359C),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6F359C).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Text(
              "DESCUBRIENDO GANADOR",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 60),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(currentDigits.length, (index) {
                return _buildDigitCard(currentDigits[index], isStopped[index]);
              }),
            ),
          ),
          const SizedBox(height: 40),
          LinearProgressIndicator(
            value: stoppedCount / currentDigits.length,
            backgroundColor: const Color(0xFFF4F0F9),
            color: const Color(0xFF6F359C),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitCard(String digit, bool stopped) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 80, // Mucho más ancho
      height: 120, // Mucho más alto
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: stopped 
            ? [const Color(0xFF6F359C), const Color(0xFF3B0764)] 
            : [Colors.white, const Color(0xFFF4F0F9)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: stopped ? const Color(0xFFD4AF37) : const Color(0xFF6F359C).withOpacity(0.5),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: stopped ? const Color(0xFFD4AF37).withOpacity(0.4) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: GoogleFonts.outfit(
            fontSize: 65, // Fuente gigante
            fontWeight: FontWeight.bold,
            color: stopped ? Colors.white : const Color(0xFF6F359C),
          ),
        ),
      ),
    );
  }
}

