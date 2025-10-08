import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/main_controller.dart';
import '../utils/app_theme.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, controller, child) {
        return Container(
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
                    Icons.music_note,
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
                        'Qo\'shiq nomi',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Artist nomi',
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
                        // Previous song
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
                          controller.setPlaying(!controller.isPlaying);
                        },
                        icon: Icon(
                          controller.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        iconSize: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Next song
                      },
                      icon: const Icon(Icons.skip_next),
                      iconSize: 28,
                    ),
                    IconButton(
                      onPressed: () {
                        // Like/Unlike
                      },
                      icon: const Icon(Icons.favorite_border),
                      iconSize: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
