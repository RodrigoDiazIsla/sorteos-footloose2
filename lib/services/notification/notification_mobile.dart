// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final _plugin = FlutterLocalNotificationsPlugin();

// class NotificationService {
//   Future<void> init() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
//     await _plugin.initialize(initSettings);
//   }

//   Future<void> show(String title, String body) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails details = NotificationDetails(android: androidDetails);
//     await _plugin.show(0, title, body, details);
//   }

//   Future<void> showDownloadNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'download_channel',
//       'Descargas',
//       channelDescription: 'Notificaciones de descargas',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const notifDetails = NotificationDetails(android: androidDetails);

//     await _plugin.show(0, title, body, notifDetails);
//   }
// }
