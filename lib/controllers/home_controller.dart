import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';
import '../services/audio_service.dart';

class HomeController extends ChangeNotifier {
  final AudioService _audioService = AudioService();

  int _selectedTab = 0;
  bool _isLoading = false;
  bool _isRefreshing = false; // Qo'shildi
  bool _isSearching = false;
  String _searchQuery = '';

  List<AudioModel> _songs = [];
  List<Map<String, dynamic>> _albums = [];
  List<Map<String, dynamic>> _artists = [];
  List<AudioModel> _filteredSongs = [];

  final List<String> tabs = ['Barcha qo\'shiqlar', 'Artistlar', 'Albumlar'];

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<AudioModel> get songs => _isSearching ? _filteredSongs : _songs;
  List<Map<String, dynamic>> get albums => _albums;
  List<Map<String, dynamic>> get artists => _artists;

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() {
    if (_songs.isEmpty) {
      // Faqat bo'sh bo'lsa yuklash
      loadAllMusic();
    }
  }

  Future<void> loadAllMusic() async {
    _isLoading = true;
    notifyListeners();

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
    notifyListeners();
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
    notifyListeners();
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
      notifyListeners();
      print('✅ Yangilandi: ${_songs.length} qo\'shiq');
    } catch (e) {
      print('❌ Yangilashda xatolik: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // Search methods
  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _searchQuery = '';
    _filteredSongs.clear();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSongs.clear();
    } else {
      _filteredSongs = _songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase()) ||
            (song.album ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Duration lazy loading
  Future<void> updateSongDuration(AudioModel song) async {
    if (song.duration != null) return; // Agar duration bor bo'lsa, qaytaramiz

    try {
      final player = AudioPlayer();
      await player.setFilePath(song.path);
      final duration = player.duration;
      await player.dispose();

      if (duration != null) {
        final newSong = AudioModel(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          path: song.path,
          duration: duration.inMilliseconds,
        );

        // Songs ro'yxatida yangilash
        final index = _songs.indexWhere((s) => s.id == song.id);
        if (index != -1) {
          _songs[index] = newSong;
        }

        // Filtered songs ro'yxatida yangilash
        final filteredIndex = _filteredSongs.indexWhere((s) => s.id == song.id);
        if (filteredIndex != -1) {
          _filteredSongs[filteredIndex] = newSong;
        }

        notifyListeners();
      }
    } catch (e) {
      print('Duration yangilashda xatolik: $e');
    }
  }
}
