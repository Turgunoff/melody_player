import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/main_controller.dart';
import '../controllers/audio_player_controller.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MainController, AudioPlayerController>(
      builder: (context, mainController, audioController, child) {
        return Scaffold(
          body: IndexedStack(
            index: mainController.currentIndex,
            children: const [HomeScreen(), FavoritesScreen(), SettingsScreen()],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: mainController.currentIndex,
              onTap: (index) => mainController.changeTab(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Bosh sahifa',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Sevimlilar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Sozlamalar',
                ),
              ],
            ),
          ),
          // Mini player
          bottomSheet: audioController.currentSong != null
              ? const MiniPlayer()
              : null,
        );
      },
    );
  }
}
