import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raffle_footloose/helpers/logs.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  Isar? _isar;

  factory IsarService() {
    return _instance;
  }

  IsarService._internal();

  Future<Isar?> getIsarInstance() async {
    if (_isar == null) {
      try {
        if (kIsWeb) return null;
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open([WinnerSchema], directory: dir.path);
      } catch (e) {
        errorLog("Error al abrir Isar ${e.toString()}");
      }
    }
    return _isar;
  }
}
