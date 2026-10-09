import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
      final url = Uri.https(URLApis.domain, "${URLApis.url}/ejecutar");
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
        for (final winner in winners) {
          if (winner.premio == null || winner.premio!.trim().isEmpty) {
            winner.premio = nameAward;
          }
        }
        winners = _sortWinnerModels(winners);
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
                phoneRaw: _readString(item, ['celular', 'telefono', 'phone']),
                premio: _readString(item, ['premio', 'Premio', 'nombrePremio', 'nombrepremio', 'premioGanado', 'premio_ganado', 'descripcionPremio', 'descripcionpremio']),
                lote: _readInt(item, ['lote', 'Lote', 'idLote', 'idlote', 'id_lote']),
                ubicacion: _readString(item, ['ubicacion', 'Ubicacion', 'location']),
                tienda: _readString(item, ['tienda', 'Tienda', 'store']),
              ),
            )
            .toList();
        winnersList = _sortWinnerModels(winnersList);
        winners = winnersList;
      }

      return winners;
    } catch (e) {
      return [];
    }
  }


  String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }
  int? _readInt(Map<String, dynamic> json, List<String> keys) {
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

  List<WinnersModel> _sortWinnerModels(List<WinnersModel> winners) {
    final sorted = [...winners];
    sorted.sort((a, b) {
      final supplementCompare = (_isSupplementPrize(a.premio) ? 1 : 0) - (_isSupplementPrize(b.premio) ? 1 : 0);
      if (supplementCompare != 0) return supplementCompare;

      final loteA = a.lote ?? -1;
      final loteB = b.lote ?? -1;
      final loteCompare = loteA.compareTo(loteB);
      if (loteCompare != 0) return loteCompare;

      final indexA = a.index ?? -1;
      final indexB = b.index ?? -1;
      return indexA.compareTo(indexB);
    });
    return sorted;
  }

  bool _isSupplementPrize(String? prize) {
    if (prize == null) return false;
    return prize.toLowerCase().contains('suplente');
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



  Future<void> exportWinnersReport(String nameAward) async {
    try {
      final awardName = formatAwardName(nameAward);
      final winners = await fetchAllWinners();
      final rows = winners.map((winner) {
        return '''
          <tr>
            <td>${_escapeExcelValue(winner.index?.toString() ?? '')}</td>
            <td>${_escapeExcelValue(winner.fullName ?? '')}</td>
            <td style="mso-number-format:'\@';">${_escapeExcelValue(winner.document ?? '')}</td>
            <td>${_escapeExcelValue(winner.email ?? '')}</td>
            <td>${_escapeExcelValue(winner.phoneRaw ?? winner.phone ?? '')}</td>
            <td style="mso-number-format:'\@';">${_escapeExcelValue(winner.code ?? '')}</td>
            <td>${_escapeExcelValue(winner.premio ?? '')}</td>
            <td>${_escapeExcelValue(winner.lote?.toString() ?? '')}</td>
            <td>${_escapeExcelValue(winner.ubicacion ?? '')}</td>
            <td>${_escapeExcelValue(winner.tienda ?? '')}</td>
          </tr>
        ''';
      }).join();

      final html = '''
        <html>
          <head>
            <meta charset="UTF-8">
            <style>
              table { border-collapse: collapse; font-family: Arial, sans-serif; }
              th { background: #6F359C; color: #FFFFFF; font-weight: bold; }
              th, td { border: 1px solid #D9D9D9; padding: 8px 12px; }
            </style>
          </head>
          <body>
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Ganador</th>
                  <th>Documento</th>
                  <th>Email</th>
                  <th>Celular</th>
                  <th>Codigo</th>
                  <th>Premio</th>
                  <th>Lote</th>
                  <th>Ubicacion</th>
                  <th>Tienda</th>
                </tr>
              </thead>
              <tbody>$rows</tbody>
            </table>
          </body>
        </html>
      ''';

      final bytes = Uint8List.fromList(utf8.encode(html));
      final fileName = '${awardName}_sorteo_regalon.xls';

      if (kIsWeb) {
        downloadFileWeb(bytes, fileName);
        return;
      }

      final bool mobile = isMobile();
      final directory = !mobile ? await getApplicationDocumentsDirectory() : await getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      await Directory(directory.path).create(recursive: true);
      await File(filePath).writeAsBytes(bytes, flush: true);

      if (mobile) {
        final notificationService = NotificationService();
        await notificationService.showDownloadNotification('Descarga completada', 'Archivo guardado en Descargas');
      }
      await OpenFile.open(filePath);
    } catch (e) {
      errorLog('exportWinnersReport - ${e.toString()}');
    }
  }

  String _escapeExcelValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
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















