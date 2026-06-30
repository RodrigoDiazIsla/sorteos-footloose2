import 'dart:convert';
import 'dart:io';
import 'package:raffle_footloose/helpers/download_directory.dart';
import 'package:raffle_footloose/helpers/format_award_name.dart';
import 'package:raffle_footloose/helpers/logs.dart';
import 'package:raffle_footloose/helpers/validate_platform.dart';
import 'package:raffle_footloose/model/isar/winners_model_bd.dart';
import 'package:raffle_footloose/model/winners_model.dart';
import 'package:raffle_footloose/config/environment.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raffle_footloose/helpers/hide_data.dart';
import 'package:raffle_footloose/services/isar_service.dart';
import 'package:raffle_footloose/services/notification/notification_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:raffle_footloose/helpers/web_download_stub.dart'
    if (dart.library.html) 'package:raffle_footloose/helpers/web_download_web.dart';


class QueryService {
  Future<int> fetchCountParticipants() async {
    try {
      final url = Uri.https(URLApis.domain, "${URLApis.url}/cantidad");

      final resp = await http
          .get(url, headers: {"Authorization": "Basic ${Environment.credentials}", "Content-Type": "application/json"}).timeout(
        const Duration(seconds: 90),
        onTimeout: () => http.Response("Error", 408),
      );

      int count = 0;

      if (resp.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(resp.body); // Decodificar el cuerpo de la respuesta JSON
        int cantidad = responseBody['data']?[0]['cantidad'] ?? 0;
        count = cantidad;
      }

      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Winner>> fetchWinner(String nameAward, int countWinners) async {
    try {
      final url = Uri.https(URLApis.domain, "${URLApis.url}/ejecutar_v2");
      final Map<String, dynamic> data = {
        "premio": nameAward,
        "cantidad": countWinners,
      };
      final resp = await http
          .post(
            url,
            headers: {"Authorization": "Basic ${Environment.credentials}", "Content-Type": "application/json"},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () => http.Response("Error", 408),
          );

      if (resp.statusCode == 200) {
        List<dynamic> data = json.decode(resp.body)['data'] ?? [];
        List<WinnersModel> winners = WinnersModel.fromJsonList(data);
        List<Winner> winnersBD = WinnersModel.saveToBDList(winners);
        final isar = await IsarService().getIsarInstance();
        if (isar != null) {
          await isar.writeTxn(() async => await isar.winners.putAll(winnersBD));
        }
        return winnersBD;

      } else {

        throw Exception("No se pudo obtener el ganador - StatusCode: ${resp.statusCode}");
      }
    } catch (e) {
      final String error = e.toString().replaceAll("Exception: ", "");
      errorLog("fetchWinner - $error");
      throw Exception("fetchWinner - $error");
    }
  }

  Future<List<WinnersModel>> fetchAllWinners() async {
    try {
      final url = Uri.https(URLApis.domain, "${URLApis.url}/list");

      final resp = await http
          .get(url, headers: {"Authorization": "Basic ${Environment.credentials}", "Content-Type": "application/json"}).timeout(
              const Duration(seconds: 90), onTimeout: () {
        return http.Response("Error", 408);
      });

      List<WinnersModel> winners = [];

      if (resp.statusCode == 200) {
        List<dynamic> data = json.decode(resp.body)['data'] ?? [];

        // Mapear la lista de datos a una lista de WinnersModel
        List<WinnersModel> winnersList = data
            .map(
              (item) => WinnersModel(
                index: item['id'],
                fullName: item['personaRegistrado'],
                document: item['numeroid'],
                email: item['email'],
                code: item['codigoregalon'],
                phone: hideData(item['celular']),
                premio: item['premio'],
              ),
            )
            .toList();
        winnersList.sort((a, b) => a.index!.compareTo(b.index!)); // Ordenar lista por ID
        winners = winnersList;
      }

      return winners;
    } catch (e) {
      return [];
    }
  }

  Future<List<Winner>> fetchWinnersList() async {
    try {
      final List<WinnersModel> winnersModels = await fetchAllWinners();
      return WinnersModel.saveToBDList(winnersModels);
    } catch (e) {
      return [];
    }
  }

  Future<bool> cleanWinners() async {
    try {
      final url = Uri.https(URLApis.domain, "${URLApis.url}/clean");

      final resp = await http.get(url, headers: {
        "Authorization": "Basic ${Environment.credentials}",
        "Content-Type": "application/json"
      }).timeout(const Duration(seconds: 90), onTimeout: () {
        return http.Response("Error", 408);
      });

      if (resp.statusCode == 200) {
        // También limpiar localmente
        final isar = await IsarService().getIsarInstance();
        if (isar != null) {
          await isar.writeTxn(() async => await isar.winners.clear());
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }


  Future<void> exportAndOpenExcel(String nameAward) async {
    try {
      final url = Uri.https(URLApis.domain, "${URLApis.url}/exportList");
      final awardName = formatAwardName(nameAward);

      final response = await http.get(
        url,
        headers: {"Authorization": "Basic ${Environment.credentials}", "Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 90), onTimeout: () {
        return http.Response("Error", 408);
      });

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (kIsWeb) {
          // Lógica especial para descargar en Navegador
          downloadFileWeb(bytes, "${awardName}_sorteo_regalon.xlsx");
        } else {

          // Lógica para Móvil/Escritorio
          final bool mobile = isMobile();
          final directory = !mobile ? await getApplicationDocumentsDirectory() : await getDownloadDirectory();
          final filePath = '${directory.path}/${awardName}_sorteo_regalon.xlsx';
          await Directory(directory.path).create(recursive: true);
          await File(filePath).writeAsBytes(bytes, flush: true);

          if (mobile) {
            final notificationService = NotificationService();
            await notificationService.showDownloadNotification("Descarga completada", "Archivo guardado en Descargas");
          }
          await OpenFile.open(filePath);
        }
      }
    } catch (e) {
      errorLog("exportAndOpenExcel - ${e.toString()}");
    }
  }
}

