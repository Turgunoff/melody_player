import 'package:flutter/material.dart';

class MainController extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isPlaying = false;

  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }
}
