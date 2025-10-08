import 'package:get/get.dart';
import '../models/audio_model.dart';
import '../services/audio_service.dart';

class HomeController extends GetxController {
  final AudioService _audioService = AudioService();

  int _selectedTab = 0;
  bool _isLoading = false;
  bool _isRefreshing = false; // Qo'shildi

  List<AudioModel> _songs = [];
  List<Map<String, dynamic>> _albums = [];
  List<Map<String, dynamic>> _artists = [];

  final List<String> tabs = [
    'Barcha qo\'shiqlar',
    'Artistlar',
    'Albumlar',
    'Pleylistlar',
  ];

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  List<AudioModel> get songs => _songs;
  List<Map<String, dynamic>> get albums => _albums;
  List<Map<String, dynamic>> get artists => _artists;

  Future<void> loadAllMusic() async {
    _isLoading = true;
    update();

    try {
      _songs = await _audioService.getAllSongs();
      _artists = _processArtists(_songs);
      _albums = _processAlbums(_songs);

      print(
        '✅ Yuklandi: ${_songs.length} qo\'shiq, ${_artists.length} artist, ${_albums.length} album',
      );
    } catch (e) {
      print('❌ Xatolik: $e');
    }

    _isLoading = false;
    update();
  }

  List<Map<String, dynamic>> _processArtists(List<AudioModel> songs) {
    final artistMap = <String, List<AudioModel>>{};

    for (var song in songs) {
      final artist = song.artist;
      if (!artistMap.containsKey(artist)) {
        artistMap[artist] = [];
      }
      artistMap[artist]!.add(song);
    }

    final artists = artistMap.entries
        .map(
          (e) => {
            'id': e.key.hashCode.toString(),
            'title': e.key,
            'songCount': '${e.value.length} qo\'shiq',
          },
        )
        .toList();

    artists.sort(
      (a, b) => (a['title'] as String).compareTo(b['title'] as String),
    );
    return artists;
  }

  List<Map<String, dynamic>> _processAlbums(List<AudioModel> songs) {
    final albumMap = <String, List<AudioModel>>{};

    for (var song in songs) {
      final album = song.album ?? 'Noma\'lum album';
      if (!albumMap.containsKey(album)) {
        albumMap[album] = [];
      }
      albumMap[album]!.add(song);
    }

    final albums = albumMap.entries
        .map(
          (e) => {
            'id': e.key.hashCode.toString(),
            'title': e.key,
            'artist': e.value.isNotEmpty ? e.value.first.artist : 'Noma\'lum',
            'songCount': '${e.value.length} qo\'shiq',
          },
        )
        .toList();

    albums.sort(
      (a, b) => (a['title'] as String).compareTo(b['title'] as String),
    );
    return albums;
  }

  void changeTab(int index) {
    _selectedTab = index;
    update();
  }

  Future<void> refresh() async {
    if (_isRefreshing) {
      print('⚠️ Refresh allaqachon jarayonda');
      return;
    }

    _isRefreshing = true;

    try {
      print('🔄 Yangilash boshlandi...');
      final newSongs = await _audioService.getAllSongs();
      _songs = newSongs;
      _artists = _processArtists(_songs);
      _albums = _processAlbums(_songs);
      update();
      print('✅ Yangilandi: ${_songs.length} qo\'shiq');
    } catch (e) {
      print('❌ Yangilashda xatolik: $e');
    } finally {
      _isRefreshing = false;
    }
  }
}
