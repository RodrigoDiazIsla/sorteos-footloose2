import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/config/app_theme.dart';
import 'package:raffle_footloose/helpers/handler_permission_notifications.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/pages/home.dart';
import 'package:raffle_footloose/services/notification/notification_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool mobile = isMobile();

  if (mobile && Platform.isAndroid) {
    // Soporte solo Android en móvil de momento
    await getHandlerPermissionNotifications();

    final notificationService = NotificationService();
    await notificationService.init();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeLight(),
      title: 'Sorteo Regalón - Footloose',
      home: const Scaffold(
        body: Home(),
      ),
    );
  }
}

// TODO: Cambiar icono de la app
// REVIEW: Testear en device físico +android 14
