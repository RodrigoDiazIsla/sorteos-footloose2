import 'dart:io';
import 'package:external_path/external_path.dart';

Future<Directory> getDownloadDirectory() async {
  try {
    final path = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );
    final dir = Directory(path);

    // Verificamos que exista, si no, lo creamos
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  } catch (e) {
    throw Exception("Error al obtener el directorio de descargas: $e");
  }
}
