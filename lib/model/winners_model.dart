import 'package:raffle_footloose/helpers/hide_data.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';

class WinnersModel {
  int? index;
  String? fullName;
  String? document;
  String? email;
  String? code;
  String? phone;
  String? phoneRaw;
  String? premio;
  String? ubicacion;
  String? tienda;
  int? lote;

  WinnersModel({
    this.index,
    this.fullName,
    this.document,
    this.email,
    this.code,
    this.phone,
    this.phoneRaw,
    this.premio,
    this.ubicacion,
    this.tienda,
    this.lote,
  });

  /// Constructor desde JSON individual
  factory WinnersModel.fromJson(Map<String, dynamic> json) {
    return WinnersModel(
      index: json['id'],
      fullName: json['personaRegistrado'],
      document: hideData(json['numeroid']),
      email: hideData(json['email']),
      code: json['codigoregalon'],
      phone: hideData(json['celular']),
      phoneRaw: _readString(json, ['celular', 'telefono', 'phone']),
      premio: _readString(json, ['premio', 'Premio', 'nombrePremio', 'nombrepremio', 'premioGanado', 'premio_ganado', 'descripcionPremio', 'descripcionpremio']),
      lote: _readInt(json, ['lote', 'Lote', 'idLote', 'idlote', 'id_lote']),
      ubicacion: _readString(json, ['ubicacion', 'Ubicacion', 'location']),
      tienda: _readString(json, ['tienda', 'Tienda', 'store']),
    );
  }


  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
  /// Método para mapear lista de JSON a lista de WinnersModel
  static List<WinnersModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => WinnersModel.fromJson(e)).toList();
  }

  /// Convertir modelo a modelo de BD
  Winner toBD() {
    return Winner()
      ..index = index
      ..fullName = fullName
      ..document = document
      ..email = email
      ..code = code
      ..phone = phone
      ..phoneRaw = phoneRaw
      ..premio = premio
      ..ubicacion = ubicacion
      ..tienda = tienda
      ..lote = lote;
  }

  /// Convertir lista de modelos a lista de modelos de BD
  static List<Winner> saveToBDList(List<WinnersModel> list) {
    return list.map((winner) => winner.toBD()).toList();
  }
}




