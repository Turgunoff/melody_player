import 'package:get/get.dart';

class MainController extends GetxController {
  int _currentIndex = 0;
  bool _isPlaying = false;

  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;

  void changeTab(int index) {
    _currentIndex = index;
    update();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    update();
  }
}
