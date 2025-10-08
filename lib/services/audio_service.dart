import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/audio_model.dart';

class AudioService {
  Future<List<AudioModel>> getAllSongs() async {
    try {
      List<AudioModel> songs = [];

      final musicDirs = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Telegram',
      ];

      for (String dirPath in musicDirs) {
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;

        try {
          final entities = await dir.list(recursive: true).toList();

          for (var entity in entities) {
            if (entity is File) {
              final ext = path.extension(entity.path).toLowerCase();
              if (['.mp3', '.m4a', '.wav', '.flac', '.aac'].contains(ext)) {
                final fileName = path.basenameWithoutExtension(entity.path);

                String title = fileName;
                String artist = 'Noma\'lum artist';

                if (fileName.contains(' - ')) {
                  final parts = fileName.split(' - ');
                  if (parts.length >= 2) {
                    artist = parts[0].trim();
                    title = parts.sublist(1).join(' - ').trim();
                  }
                }

                songs.add(
                  AudioModel(
                    id: entity.path.hashCode.toString(),
                    title: title,
                    artist: artist,
                    album: path.basename(path.dirname(entity.path)),
                    path: entity.path,
                    duration: null,
                  ),
                );
              }
            }
          }
        } catch (e) {
          print('Papkani o\'qishda xatolik ($dirPath): $e');
        }
      }

      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      print('Jami ${songs.length} ta qo\'shiq topildi');
      return songs;
    } catch (e) {
      print('Qo\'shiqlarni yuklashda xatolik: $e');
      return [];
    }
  }
}
