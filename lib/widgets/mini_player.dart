import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../controllers/main_controller.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../utils/app_theme.dart';
import 'full_player_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MainController, AudioPlayerController>(
      builder: (context, mainController, audioController, child) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const FullPlayerSheet(),
            );
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Album art
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.music_copy,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          audioController.currentSong?.title ??
                              'Qo\'shiq tanlanmagan',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          audioController.currentSong?.artist ?? 'Artist',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          audioController.previousSong();
                        },
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 28,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (audioController.isPlaying) {
                              audioController.pause();
                            } else {
                              audioController.resume();
                            }
                          },
                          icon: Icon(
                            audioController.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          audioController.nextSong();
                        },
                        icon: const Icon(Icons.skip_next),
                        iconSize: 28,
                      ),
                      Consumer<FavoritesController>(
                        builder: (context, favoritesController, child) {
                          return IconButton(
                            onPressed: () {
                              if (audioController.currentSong != null) {
                                favoritesController.toggleFavorite(
                                  audioController.currentSong!,
                                );
                              }
                            },
                            icon: Icon(
                              audioController.currentSong != null &&
                                      favoritesController.isFavorite(
                                        audioController.currentSong!.id,
                                      )
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  audioController.currentSong != null &&
                                      favoritesController.isFavorite(
                                        audioController.currentSong!.id,
                                      )
                                  ? AppTheme.primaryColor
                                  : null,
                            ),
                            iconSize: 24,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
