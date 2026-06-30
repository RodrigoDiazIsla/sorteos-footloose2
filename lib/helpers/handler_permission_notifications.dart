import 'package:permission_handler/permission_handler.dart';
import 'package:raffle_footloose/helpers/logs.dart';

Future<bool> getHandlerPermissionNotifications() async {
  final status = await Permission.notification.status;
  if (status.isGranted) {
    return true;
  }
  final request = await Permission.notification.request();
  infoLog("handler_permission_notifications", request.isGranted.toString());
  return request.isGranted;
}
