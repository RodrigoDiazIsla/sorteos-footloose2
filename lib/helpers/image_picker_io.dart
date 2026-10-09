import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<String?> pickRaffleImageDataUrl() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );

  final file = result?.files.isNotEmpty == true ? result!.files.first : null;
  if (file == null) return null;

  final bytes = file.bytes ??
      (file.path != null ? await File(file.path!).readAsBytes() : null);
  if (bytes == null || bytes.isEmpty) return null;

  final mimeType = _mimeTypeFromName(file.name);
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

String _mimeTypeFromName(String name) {
  final lowerName = name.toLowerCase();
  if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lowerName.endsWith('.webp')) return 'image/webp';
  if (lowerName.endsWith('.gif')) return 'image/gif';
  if (lowerName.endsWith('.bmp')) return 'image/bmp';
  return 'image/png';
}
