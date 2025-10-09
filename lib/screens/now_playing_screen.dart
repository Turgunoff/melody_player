import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../utils/app_theme.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<AudioPlayerController, FavoritesController>(
        builder: (context, controller, favoritesController, child) {
          if (controller.currentSong == null) {
            return const Center(
              child: Text(
                'Hech qanday qo\'shiq o\'ynatilmayapti',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.3),
                  Colors.black,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, controller, favoritesController),

                  // Album Art
                  Expanded(flex: 3, child: _buildAlbumArt(context, controller)),

                  // Song Info
                  _buildSongInfo(context, controller),

                  // Lyrics
                  _buildLyrics(context, controller),

                  // Progress Bar
                  _buildProgressBar(context, controller),

                  // Controls
                  _buildControls(context, controller),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AudioPlayerController controller,
    FavoritesController favoritesController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
          ),
          const Text(
            'Hozir O\'ynatilmoqda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              if (controller.currentSong != null) {
                favoritesController.toggleFavorite(controller.currentSong!);
              }
            },
            icon: Icon(
              controller.currentSong != null &&
                      favoritesController.isFavorite(controller.currentSong!.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  controller.currentSong != null &&
                      favoritesController.isFavorite(controller.currentSong!.id)
                  ? AppTheme.primaryColor
                  : Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            controller.currentSong?.title ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            controller.currentSong?.artist ?? 'Unknown Artist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLyrics(BuildContext context, AudioPlayerController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Whispers in the midnight breeze,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Carrying dreams across the seas,',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'I close my eyes, let go, and drift away.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppTheme.primaryColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: controller.progress,
              onChanged: (value) {
                final position = Duration(
                  milliseconds: (value * controller.duration.inMilliseconds)
                      .round(),
                );
                controller.seekTo(position);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(controller.position),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                _formatDuration(controller.duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    AudioPlayerController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            onPressed: controller.toggleShuffle,
            icon: Icon(
              Icons.shuffle,
              color: controller.isShuffled
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),

          // Previous
          IconButton(
            onPressed: controller.previousSong,
            icon: const Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 32,
            ),
          ),

          // Play/Pause
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                if (controller.isPlaying) {
                  controller.pause();
                } else {
                  controller.resume();
                }
              },
              icon: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Next
          IconButton(
            onPressed: controller.nextSong,
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
          ),

          // Repeat
          IconButton(
            onPressed: controller.toggleRepeat,
            icon: Icon(
              controller.isRepeating ? Icons.repeat : Icons.repeat_outlined,
              color: controller.isRepeating
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
