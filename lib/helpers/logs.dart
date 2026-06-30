import 'package:logger/logger.dart';
import 'package:raffle_footloose/config/environment.dart';

final Logger logger = Logger();

void infoLog(String event, String value) {
  if (Environment.current == Environments.dev) {
    logger.i("$event: $value", stackTrace: StackTrace.current);
  }
}

void errorLog(String message) {
  if (Environment.current == Environments.dev) {
    logger.e(message, stackTrace: StackTrace.current);
  }
}
