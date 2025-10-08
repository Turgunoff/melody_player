import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class PermissionController extends ChangeNotifier {
  bool _hasPermission = false;
  bool _isChecking = false;
  String _statusMessage = '';

  bool get hasPermission => _hasPermission;
  bool get isChecking => _isChecking;
  String get statusMessage => _statusMessage;

  Future<void> checkPermission() async {
    _isChecking = true;
    _statusMessage = 'Permission tekshirilmoqda...';
    notifyListeners();

    try {
      // Storage permission tekshirish
      final storageStatus = await permission_handler.Permission.storage.status;

      if (storageStatus.isGranted) {
        _hasPermission = true;
        _statusMessage = 'Permission mavjud';
        print('✅ Storage permission mavjud');
      } else {
        _hasPermission = false;
        _statusMessage = 'Permission kerak';
        print('❌ Storage permission yo\'q');
      }
    } catch (e) {
      _hasPermission = false;
      _statusMessage = 'Permission tekshirishda xatolik: $e';
      print('❌ Permission tekshirishda xatolik: $e');
    }

    _isChecking = false;
    notifyListeners();
  }

  Future<bool> requestPermission() async {
    _isChecking = true;
    _statusMessage = 'Permission so\'ralmoqda...';
    notifyListeners();

    try {
      final status = await permission_handler.Permission.storage.request();

      if (status.isGranted) {
        _hasPermission = true;
        _statusMessage = 'Permission berildi';
        print('✅ Storage permission berildi');
        return true;
      } else {
        _hasPermission = false;
        _statusMessage = 'Permission rad etildi';
        print('❌ Storage permission rad etildi');
        return false;
      }
    } catch (e) {
      _hasPermission = false;
      _statusMessage = 'Permission so\'rashda xatolik: $e';
      print('❌ Permission so\'rashda xatolik: $e');
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    try {
      await permission_handler.openAppSettings();
      print('📱 App settings ochildi');
    } catch (e) {
      print('❌ App settings ochishda xatolik: $e');
    }
  }
}
