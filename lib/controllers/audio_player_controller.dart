import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioModel? _currentSong;
  List<AudioModel> _playlist = [];
  int _currentIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isShuffled = false;
  bool _isRepeating = false;

  // Getters
  AudioModel? get currentSong => _currentSong;
  List<AudioModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _isRepeating;

  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  AudioPlayerController() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      _isLoading = playerState.processingState == ProcessingState.loading;
      notifyListeners();
    });
  }

  Future<void> playSong(AudioModel song, {List<AudioModel>? playlist}) async {
    try {
      _currentSong = song;
      _isLoading = true;
      notifyListeners();

      // Playlist qo'shish
      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = playlist.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) _currentIndex = 0;
      }

      await _audioPlayer.setFilePath(song.path);
      await _audioPlayer.play();

      print('🎵 Playing: ${song.title} - ${song.artist}');
    } catch (e) {
      print('❌ Error playing song: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> nextSong() async {
    if (_playlist.isEmpty) {
      print('❌ Playlist bo\'sh');
      return;
    }

    if (_isShuffled) {
      // Random song
      final random = DateTime.now().millisecondsSinceEpoch % _playlist.length;
      _currentIndex = random;
    } else {
      // Keyingi qo'shiq
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    await _playCurrentSong();
    print('⏭️ Next song: ${_currentSong?.title}');
  }

  Future<void> previousSong() async {
    if (_playlist.isEmpty) {
      print('❌ Playlist bo\'sh');
      return;
    }

    if (_isShuffled) {
      // Random song
      final random = DateTime.now().millisecondsSinceEpoch % _playlist.length;
      _currentIndex = random;
    } else {
      // Oldingi qo'shiq
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    }

    await _playCurrentSong();
    print('⏮️ Previous song: ${_currentSong?.title}');
  }

  Future<void> _playCurrentSong() async {
    if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
      final song = _playlist[_currentIndex];
      await playSong(song);
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
    print('🔀 Shuffle: ${_isShuffled ? "ON" : "OFF"}');
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
    print('🔁 Repeat: ${_isRepeating ? "ON" : "OFF"}');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
