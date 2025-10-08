import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PermissionController extends GetxController {
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  Future<void> checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPermission = prefs.getBool('audio_permission') ?? false;

    if (savedPermission) {
      final hasActualPermission = await _checkActualPermission();
      if (hasActualPermission) {
        _hasPermission = true;
        update();
        return;
      }
    }

    final hasActualPermission = await _checkActualPermission();
    if (hasActualPermission) {
      _hasPermission = true;
      await prefs.setBool('audio_permission', true);
      update();
    }
  }

  Future<bool> _checkActualPermission() async {
    if (!Platform.isAndroid) return false;

    // Avval audio permission tekshiramiz (Android 13+)
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;

    // Agar audio yo'q bo'lsa storage tekshiramiz (Android 12-)
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    return false;
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;

    // Avval audio permission so'raymiz
    PermissionStatus audioStatus = await Permission.audio.request();

    // Agar audio granted bo'lsa
    if (audioStatus.isGranted) {
      _hasPermission = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_permission', true);
      update();
      return true;
    }

    // Agar audio denied bo'lsa, storage sinab ko'ramiz
    PermissionStatus storageStatus = await Permission.storage.request();

    if (storageStatus.isGranted) {
      _hasPermission = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_permission', true);
      update();
      return true;
    }

    // Agar permanently denied bo'lsa
    if (audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
