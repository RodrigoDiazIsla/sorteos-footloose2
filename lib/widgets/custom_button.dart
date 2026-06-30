import 'package:flutter/material.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';

class CustomButton extends StatelessWidget {
  final String? type;
  final IconData? icon;
  final String title;
  final VoidCallback? onTap;
  const CustomButton({
    super.key,
    this.type,
    this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor = (type == null) ? const Color(0xFF6F359C) : Colors.transparent;
    Color textColor = (type == null) ? Colors.white : const Color(0xFF6F359C);

    BoxDecoration customDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: onTap == null ? Colors.grey : buttonColor,
      boxShadow: [
        if (onTap != null && type == null)
          BoxShadow(
            color: const Color(0xFF6F359C).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
      ],
    );

    if (type != null) {
      customDecoration = customDecoration.copyWith(
        border: Border.all(color: textColor.withOpacity(0.5), width: 1.5),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: customDecoration,
        // Eliminamos el ancho fijo para que sea flexible
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Tamaño base más profesional
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
