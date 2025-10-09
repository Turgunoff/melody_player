import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../models/audio_model.dart';
import '../utils/app_theme.dart';
import '../widgets/full_player_sheet.dart';
import '../widgets/mini_player.dart';

class AlbumSongsScreen extends StatelessWidget {
  final String albumName;
  final String artistName;

  const AlbumSongsScreen({
    super.key,
    required this.albumName,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerController>(
      builder: (context, audioController, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(albumName, style: const TextStyle(fontSize: 18)),
                Text(
                  artistName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  // Play all songs
                  _playAllSongs(context);
                },
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Barcha qo\'shiqlarni o\'ynatish',
              ),
            ],
          ),
          body: Consumer<HomeController>(
            builder: (context, controller, child) {
              // Album qo'shiqlarini filtrlash
              final albumSongs = controller.songs
                  .where(
                    (song) => (song.album ?? 'Noma\'lum album') == albumName,
                  )
                  .toList();

              if (albumSongs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.album_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Album qo\'shiqlari topilmadi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: albumSongs.length,
                itemBuilder: (context, index) {
                  final song = albumSongs[index];
                  return _buildSongTile(context, song, albumSongs);
                },
              );
            },
          ),
          // Mini player
          bottomSheet: audioController.currentSong != null
              ? const MiniPlayer()
              : null,
        );
      },
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    AudioModel song,
    List<AudioModel> playlist,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Play song
            final audioController = Provider.of<AudioPlayerController>(
              context,
              listen: false,
            );
            await audioController.playSong(song, playlist: playlist);
            if (context.mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FullPlayerSheet(),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.music_copy,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Duration and Menu
                Consumer<HomeController>(
                  builder: (context, homeController, child) {
                    // Lazy loading - duration yo'q bo'lsa, yangilash
                    if (song.duration == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        homeController.updateSongDuration(song);
                      });
                    }

                    return Text(
                      song.durationString,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                Consumer<FavoritesController>(
                  builder: (context, favoritesController, child) {
                    return IconButton(
                      onPressed: () {
                        favoritesController.toggleFavorite(song);
                      },
                      icon: Icon(
                        favoritesController.isFavorite(song.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoritesController.isFavorite(song.id)
                            ? AppTheme.primaryColor
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      iconSize: 20,
                    );
                  },
                ),
                Consumer<AudioPlayerController>(
                  builder: (context, audioController, child) {
                    final isCurrentSong =
                        audioController.currentSong?.id == song.id;
                    final isPlaying =
                        isCurrentSong && audioController.isPlaying;

                    return IconButton(
                      onPressed: () async {
                        if (isCurrentSong) {
                          // Agar bu qo'shiq hozir o'ynatilayotgan bo'lsa, play/pause
                          if (audioController.isPlaying) {
                            audioController.pause();
                          } else {
                            audioController.resume();
                          }
                        } else {
                          // Agar boshqa qo'shiq bo'lsa, yangi qo'shiqni o'ynatish
                          await audioController.playSong(
                            song,
                            playlist: playlist,
                          );

                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const FullPlayerSheet(),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        isCurrentSong && isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isCurrentSong
                            ? AppTheme.primaryColor
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      iconSize: 20,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playAllSongs(BuildContext context) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final audioController = Provider.of<AudioPlayerController>(
      context,
      listen: false,
    );

    final albumSongs = homeController.songs
        .where((song) => (song.album ?? 'Noma\'lum album') == albumName)
        .toList();

    if (albumSongs.isNotEmpty) {
      audioController.playSong(albumSongs.first, playlist: albumSongs);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const FullPlayerSheet(),
      );
    }
  }
}
