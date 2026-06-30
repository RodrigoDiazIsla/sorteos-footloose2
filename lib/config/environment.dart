import 'package:raffle_footloose/config/special_days.dart';

class URLApis {
  static String development = "PROD";
  static String domainDEV = "apistest.footloose.pe";
  static String domainPROD = "apis.footloose.pe";
  static String url = "/api-rest/icq01/sorteo";

  static String get domain => development == "DEV" ? domainDEV : domainPROD;
}

enum Environments { dev, test }

class Environment {
  static const current = Environments.dev;
  static String credentials = "c29ydGVvOlhNNipaREF5TQ==";
  static SpecialDays currentSpecialDay = SpecialDays.cyberWow;

}
