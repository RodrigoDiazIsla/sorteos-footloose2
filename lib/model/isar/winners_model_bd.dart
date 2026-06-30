import 'package:isar/isar.dart';

part 'winners_model_bd.g.dart';

@collection
class Winner {
  Id id = Isar.autoIncrement;
  int? index;
  String? fullName;
  String? document;
  String? email;
  String? code;
  String? phone;
  String? premio;
}
