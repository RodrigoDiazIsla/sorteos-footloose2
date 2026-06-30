import 'package:flutter/material.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';

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
    final double widthModal = MediaQuery.of(context).size.width * (!mobile ? 0.5 : 0.9);
    final textStyles = Theme.of(context).textTheme;
    final theme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9, // ← importante
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sección superior con botón "X"
                Container(
                  width: widthModal,
                  padding: const EdgeInsets.only(bottom: 10),
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClose ?? () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.onSurfaceVariant,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'lib/assets/close.png',
                          width: 38,
                          height: 38,
                        ),
                      ),
                    ),
                  ),
                ),

                // Cuerpo del modal
                Container(
                  width: widthModal,
                  decoration: BoxDecoration(
                    color: theme.onSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textStyles.labelMedium,
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFC7C6C8)),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 100),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: textStyles.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
