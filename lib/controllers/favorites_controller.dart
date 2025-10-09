import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_model.dart';

class FavoritesController extends ChangeNotifier {
  List<String> _favoriteIds = [];
  List<AudioModel> _favoriteSongs = [];

  List<String> get favoriteIds => _favoriteIds;
  List<AudioModel> get favoriteSongs => _favoriteSongs;

  bool isFavorite(String songId) {
    return _favoriteIds.contains(songId);
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIdsJson = prefs.getStringList('favorite_song_ids') ?? [];
      _favoriteIds = favoriteIdsJson;
      notifyListeners();
    } catch (e) {
      print('❌ Favorites yuklashda xatolik: $e');
    }
  }

  Future<void> toggleFavorite(AudioModel song) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_favoriteIds.contains(song.id)) {
        // Sevimlilardan olib tashlash
        _favoriteIds.remove(song.id);
        _favoriteSongs.removeWhere((s) => s.id == song.id);
        print('💔 Sevimlilardan olib tashlandi: ${song.title}');
      } else {
        // Sevimlilarga qo'shish
        _favoriteIds.add(song.id);
        _favoriteSongs.add(song);
        print('❤️ Sevimlilarga qoshildi: ${song.title}');
      }

      // SharedPreferences'ga saqlash
      await prefs.setStringList('favorite_song_ids', _favoriteIds);
      notifyListeners();
    } catch (e) {
      print('❌ Sevimli ozgartirishda xatolik: $e');
    }
  }

  void updateFavoriteSongs(List<AudioModel> allSongs) {
    _favoriteSongs = allSongs
        .where((song) => _favoriteIds.contains(song.id))
        .toList();
    notifyListeners();
  }

  Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorite_song_ids');
      _favoriteIds.clear();
      _favoriteSongs.clear();
      notifyListeners();
      print('🗑️ Barcha sevimlilar tozalandi');
    } catch (e) {
      print('❌ Sevimlilarni tozalashda xatolik: $e');
    }
  }
}
