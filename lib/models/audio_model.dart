class AudioModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String path;
  final int? duration;

  AudioModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.path,
    this.duration,
  });

  String get durationString {
    if (duration == null) return '0:00';
    final minutes = duration! ~/ 60000;
    final seconds = (duration! % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
