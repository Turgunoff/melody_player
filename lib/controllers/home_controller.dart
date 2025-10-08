import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeController extends GetxController {
  int _selectedTab = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> _songs = [];
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
  List<Map<String, dynamic>> get songs => _songs;
  List<Map<String, dynamic>> get albums => _albums;
  List<Map<String, dynamic>> get artists => _artists;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void loadMockData() {
    _isLoading = true;
    update();

    // Mock data
    _songs = List.generate(
      20,
      (index) => {
        'title': 'Qo\'shiq ${index + 1}',
        'artist': 'Artist ${index + 1}',
        'duration':
            '${(index + 2)}:${(index * 3 + 15).toString().padLeft(2, '0')}',
        'albumArt': null,
      },
    );

    _albums = List.generate(
      8,
      (index) => {
        'title': 'Album ${index + 1}',
        'artist': 'Artist ${index + 1}',
        'songCount': '${index + 8} qo\'shiq',
      },
    );

    _artists = List.generate(
      10,
      (index) => {
        'title': 'Artist ${index + 1}',
        'artist': 'Artist ${index + 1}',
        'songCount': '${index + 5} qo\'shiq',
      },
    );

    _isLoading = false;
    update();
  }

  void changeTab(int index) {
    _selectedTab = index;
    update();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    loadMockData();
  }

  Future<void> pickMusicFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        // Handle picked files
        print('Picked ${result.files.length} files');
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }
}
