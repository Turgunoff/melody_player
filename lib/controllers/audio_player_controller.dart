import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random(); // QO'SHISH

  AudioModel? _currentSong;
  List<AudioModel> _playlist = [];
  int _currentIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isShuffled = false;
  bool _isRepeating = false;

  List<int> _shuffledIndices = []; // QO'SHISH: Shuffle tartib
  int _shufflePosition = 0; // QO'SHISH: Shuffle pozitsiya

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

  // TUZATISH: Progress qiymatini cheklash
  double get progress {
    if (_duration.inMilliseconds <= 0) return 0.0;
    final value = _position.inMilliseconds / _duration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

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

      if (playerState.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }

      notifyListeners();
    });
  }

  Future<void> _onSongCompleted() async {
    print('✅ Qo\'shiq tugadi');

    if (_isRepeating) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      print('🔁 Qayta o\'ynatilmoqda');
    } else {
      await nextSong();
    }
  }

  Future<void> playSong(AudioModel song, {List<AudioModel>? playlist}) async {
    try {
      _currentSong = song;
      _isLoading = true;
      notifyListeners();

      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = playlist.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) _currentIndex = 0;

        // Shuffle list yaratish
        if (_isShuffled) {
          _createShuffleList();
        }
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

  // YANGI: Shuffle list yaratish
  void _createShuffleList() {
    _shuffledIndices = List.generate(_playlist.length, (index) => index);
    _shuffledIndices.shuffle(_random);

    // Hozirgi qo'shiqni birinchi o'ringa qo'yish
    final currentPos = _shuffledIndices.indexOf(_currentIndex);
    if (currentPos != -1) {
      _shuffledIndices.removeAt(currentPos);
      _shuffledIndices.insert(0, _currentIndex);
    }

    _shufflePosition = 0;
    print('🔀 Shuffle list yaratildi: ${_shuffledIndices.length} ta qo\'shiq');
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
      // Shuffle rejimida keyingi qo'shiq
      _shufflePosition++;

      // Agar oxirigacha yetgan bo'lsa, qaytadan aralashtirish
      if (_shufflePosition >= _shuffledIndices.length) {
        _createShuffleList();
        _shufflePosition = 1; // 0 hozirgi qo'shiq
      }

      _currentIndex = _shuffledIndices[_shufflePosition];
      print('🔀 Shuffle: ${_shufflePosition}/${_shuffledIndices.length}');
    } else {
      // Oddiy rejimda ketma-ket
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

    // Agar qo'shiq 3 sekunddan ko'proq o'ynagan bo'lsa, boshidan boshlash
    if (_position.inSeconds > 3) {
      await seekTo(Duration.zero);
      print('🔄 Qo\'shiq boshidan boshlandi');
      return;
    }

    if (_isShuffled) {
      // Shuffle rejimida oldingi qo'shiq
      _shufflePosition--;

      // Agar boshiga yetgan bo'lsa
      if (_shufflePosition < 0) {
        _shufflePosition = _shuffledIndices.length - 1;
      }

      _currentIndex = _shuffledIndices[_shufflePosition];
      print('🔀 Shuffle: ${_shufflePosition}/${_shuffledIndices.length}');
    } else {
      // Oddiy rejimda
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

    if (_isShuffled) {
      // Shuffle yoqilganda list yaratish
      _createShuffleList();
    } else {
      // Shuffle o'chirilganda tozalash
      _shuffledIndices.clear();
      _shufflePosition = 0;
    }

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
