import 'package:flutter/material.dart';

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
    final bool secondary = type != null;
    final bool enabled = onTap != null;
    final Color primary = const Color(0xFF6F359C);
    final Color disabled = const Color(0xFFD1D5DB);
    final Color background = !enabled ? disabled : (secondary ? Colors.white : primary);
    final Color foreground = !enabled ? const Color(0xFF6B7280) : (secondary ? primary : Colors.white);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      elevation: enabled && !secondary ? 5 : 0,
      shadowColor: primary.withOpacity(0.25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: secondary ? Border.all(color: primary.withOpacity(0.32), width: 1.3) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 20),
                const SizedBox(width: 9),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
