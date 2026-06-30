import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedDigitCode extends StatefulWidget {
  final String code;
  final Color color;
  const AnimatedDigitCode({super.key, required this.code, required this.color});

  @override
  State<AnimatedDigitCode> createState() => _AnimatedDigitCodeState();
}

class _AnimatedDigitCodeState extends State<AnimatedDigitCode> {
  String displayedCode = "";
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      if (currentIndex < widget.code.length) {
        setState(() {
          displayedCode += widget.code[currentIndex];
          currentIndex++;
        });
      } else {
        t.cancel();
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.code.length, (index) {
          bool isVisible = index < displayedCode.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isVisible ? widget.color : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isVisible ? widget.code[index] : "?",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isVisible ? Colors.white : widget.color.withOpacity(0.3),
              ),
            ),
          );
        }),
      ),
    );
  }
}
