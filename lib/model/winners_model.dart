import 'package:raffle_footloose/helpers/hide_data.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';

class WinnersModel {
  int? index;
  String? fullName;
  String? document;
  String? email;
  String? code;
  String? phone;
  String? premio;

  WinnersModel({
    this.index,
    this.fullName,
    this.document,
    this.email,
    this.code,
    this.phone,
    this.premio,
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
      premio: json['premio'],
    );
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
      ..premio = premio;
  }

  /// Convertir lista de modelos a lista de modelos de BD
  static List<Winner> saveToBDList(List<WinnersModel> list) {
    return list.map((winner) => winner.toBD()).toList();
  }
}

