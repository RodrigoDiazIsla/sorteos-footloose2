import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';

class AlertNotification extends StatelessWidget {
  const AlertNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile();
    return Column(
      children: [
        SizedBox(height: mobile ? 20 : 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF5FF),
            border: Border.all(color: const Color(0xFF90CAF9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Activa las notificaciones para recibir alertas sobre el sorteo.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF464646)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF3D1452)),
                onPressed: () async => await openAppSettings(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
