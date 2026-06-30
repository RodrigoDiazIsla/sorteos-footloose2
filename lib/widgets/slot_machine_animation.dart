import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlotMachineAnimation extends StatefulWidget {
  final String targetText;
  final VoidCallback onComplete;

  const SlotMachineAnimation({
    super.key,
    required this.targetText,
    required this.onComplete,
  });

  @override
  State<SlotMachineAnimation> createState() => _SlotMachineAnimationState();
}

class _SlotMachineAnimationState extends State<SlotMachineAnimation> {
  late List<String> currentChars;
  bool isSpinning = true;
  Timer? timer;
  final Random random = Random();
  final String chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  @override
  void initState() {
    super.initState();
    currentChars = List.generate(widget.targetText.length, (index) => chars[random.nextInt(chars.length)]);
    startSpinning();
  }

  void startSpinning() {
    int duration = 0;
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        for (int i = 0; i < currentChars.length; i++) {
          if (random.nextDouble() > 0.1) {
            currentChars[i] = chars[random.nextInt(chars.length)];
          }
        }
      });

      duration += 50;
      if (duration > 3000) {
        stopSpinning();
      }
    });
  }

  void stopSpinning() async {
    timer?.cancel();
    for (int i = 0; i < widget.targetText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        currentChars[i] = widget.targetText[i];
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    widget.onComplete();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF53240), width: 3), // Rojo Footloose
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF53240).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: currentChars.map((char) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: Text(
                char,
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

  }
}
