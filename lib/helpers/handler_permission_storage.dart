import 'package:permission_handler/permission_handler.dart';
import 'package:raffle_footloose/helpers/logs.dart';

Future<bool> getHandlerPermissionStorage() async {
  final status = await Permission.storage.status;
  if (status.isGranted) {
    return true;
  }
  final request = await Permission.storage.request();
  infoLog("handler_permission_storage", request.isGranted.toString());
  return request.isGranted;
}
