import 'package:flutter/material.dart';

class ImageLogo extends StatelessWidget {
  const ImageLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Image(
            image: AssetImage("lib/assets/logo_purple.png"),
            height: 60.0,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
