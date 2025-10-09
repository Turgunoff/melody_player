import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../utils/app_theme.dart';

class FullPlayerSheet extends StatelessWidget {
  const FullPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Consumer2<AudioPlayerController, FavoritesController>(
        builder: (context, controller, favoritesController, child) {
          if (controller.currentSong == null) {
            return const Center(
              child: Text(
                'Hech qanday qo\'shiq o\'ynatilmayapti',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, controller, favoritesController),
                Expanded(flex: 3, child: _buildAlbumArt(context, controller)),
                _buildSongInfo(context, controller),
                // _buildLyrics(context, controller),
                _buildProgressBar(context, controller),
                _buildControls(context, controller),
                const SizedBox(height: 20),
              ],
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Iconsax.arrow_down_1_copy,
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
                  ? Iconsax.heart
                  : Iconsax.heart_copy,
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
                Iconsax.music_copy,
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
            controller.currentSong?.title ?? 'Noma\'lum',
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
            controller.currentSong?.artist ?? 'Noma\'lum Artist',
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
              value: controller.progress.clamp(0.0, 1.0), // Qo'shimcha himoya
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
          IconButton(
            onPressed: controller.toggleShuffle,
            icon: Icon(
              Iconsax.shuffle,
              color: controller.isShuffled
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          IconButton(
            onPressed: controller.previousSong,
            icon: const Icon(
              Iconsax.arrow_left_2_copy,
              color: Colors.white,
              size: 32,
            ),
          ),
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
                controller.isPlaying ? Iconsax.pause : Iconsax.play_copy,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.nextSong,
            icon: const Icon(
              Iconsax.arrow_right_3_copy,
              color: Colors.white,
              size: 32,
            ),
          ),
          IconButton(
            onPressed: controller.toggleRepeat,
            icon: Icon(
              controller.isRepeating ? Iconsax.repeat : Iconsax.repeat,
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
