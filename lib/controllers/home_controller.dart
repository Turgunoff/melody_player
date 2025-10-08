import 'package:get/get.dart';

class HomeController extends GetxController {
  int _selectedTab = 0;

  final List<String> tabs = [
    'Barcha qo\'shiqlar',
    'Artistlar',
    'Albumlar',
    'Pleylistlar',
  ];

  int get selectedTab => _selectedTab;

  void changeTab(int index) {
    _selectedTab = index;
    update();
  }
}
