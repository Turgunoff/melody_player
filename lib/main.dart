import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/artist_songs_screen.dart';
import 'screens/album_songs_screen.dart';
import 'utils/app_theme.dart';
import 'controllers/home_controller.dart';
import 'controllers/main_controller.dart';
import 'controllers/permission_controller.dart';
import 'controllers/audio_player_controller.dart';
import 'controllers/favorites_controller.dart';

void main() {
  runApp(const MelodyPlayerApp());
}

class MelodyPlayerApp extends StatelessWidget {
  const MelodyPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PermissionController()),
        ChangeNotifierProvider(create: (_) => MainController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => AudioPlayerController()),
        ChangeNotifierProvider(create: (_) => FavoritesController()),
      ],
      child: MaterialApp(
        title: 'Melody Player',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
          // '/now-playing': (context) => const NowPlayingScreen(),
          '/artist-songs': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return ArtistSongsScreen(artistName: args['artistName']!);
          },
          '/album-songs': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return AlbumSongsScreen(
              albumName: args['albumName']!,
              artistName: args['artistName']!,
            );
          },
        },
      ),
    );
  }
}
