import 'package:flutter/material.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/widgets/custom_button.dart';

class ErrorModal extends StatelessWidget {
  final VoidCallback? onClose;
  final String title;
  final String errorMessage;

  const ErrorModal({
    super.key,
    this.onClose,
    required this.title,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile();
    final double widthModal = mobile ? MediaQuery.of(context).size.width * 0.9 : 460;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Container(
          width: widthModal,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15, height: 1.35, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  title: 'ENTENDIDO',
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
