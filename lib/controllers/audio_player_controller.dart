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
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

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

  Future<void> playSong(AudioModel song) async {
    try {
      _currentSong = song;
      _isLoading = true;
      notifyListeners();

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
    // TODO: Implement next song logic
    print('⏭️ Next song');
  }

  Future<void> previousSong() async {
    // TODO: Implement previous song logic
    print('⏮️ Previous song');
  }

  void toggleShuffle() {
    // TODO: Implement shuffle logic
    print('🔀 Toggle shuffle');
  }

  void toggleRepeat() {
    // TODO: Implement repeat logic
    print('🔁 Toggle repeat');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
