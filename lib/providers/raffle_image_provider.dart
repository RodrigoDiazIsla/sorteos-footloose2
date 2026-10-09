import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raffle_footloose/services/storage_service.dart';

class RaffleImageController extends StateNotifier<String?> {
  RaffleImageController() : super(null);

  static const String _storageKey = 'raffle_image_url';

  Future<void> loadImage() async {
    try {
      final imageUrl = await StorageService.readFromPrefs<String>(_storageKey);
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        state = imageUrl.trim();
      }
    } catch (_) {
      state = null;
    }
  }

  Future<void> setImage(String imageUrl) async {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) return;

    state = cleanUrl;

    if (cleanUrl.startsWith('data:image/') && kIsWeb) return;

    try {
      await StorageService.saveToPrefs(_storageKey, cleanUrl);
    } catch (_) {}
  }

  Future<void> clearImage() async {
    try {
      await StorageService.deleteFromPrefs(_storageKey);
    } catch (_) {}
    state = null;
  }
}

final raffleImageProvider = StateNotifierProvider<RaffleImageController, String?>(
  (ref) => RaffleImageController(),
);


