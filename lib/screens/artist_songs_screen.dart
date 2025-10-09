import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/audio_player_controller.dart';
import '../controllers/favorites_controller.dart';
import '../models/audio_model.dart';
import '../utils/app_theme.dart';
import '../widgets/full_player_sheet.dart';
import '../widgets/mini_player.dart';

class ArtistSongsScreen extends StatelessWidget {
  final String artistName;

  const ArtistSongsScreen({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerController>(
      builder: (context, audioController, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text(artistName),
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
          // Artist qo'shiqlarini filtrlash
          final artistSongs = controller.songs
              .where((song) => song.artist == artistName)
              .toList();

          if (artistSongs.isEmpty) {
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
                    child: const Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Artist qo\'shiqlari topilmadi',
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
            itemCount: artistSongs.length,
            itemBuilder: (context, index) {
              final song = artistSongs[index];
              return _buildSongTile(context, song, artistSongs);
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
                    child: const Icon(
                      Icons.music_note_rounded,
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
                        song.album ?? 'Noma\'lum album',
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
                Text(
                  song.durationString,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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
                IconButton(
                  onPressed: () {
                    // Menu functionality
                  },
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  iconSize: 20,
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

    final artistSongs = homeController.songs
        .where((song) => song.artist == artistName)
        .toList();

    if (artistSongs.isNotEmpty) {
      audioController.playSong(artistSongs.first, playlist: artistSongs);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const FullPlayerSheet(),
      );
    }
  }
}
