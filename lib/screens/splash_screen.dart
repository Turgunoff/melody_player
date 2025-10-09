import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/permission_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/favorites_controller.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  String _statusText = '';

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Build tugagandan keyin initialize qilamiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (mounted) {
      setState(() {
        _statusText = 'Permission tekshirilmoqda...';
      });
    }

    // Permission tekshirish
    final permissionController = Provider.of<PermissionController>(
      context,
      listen: false,
    );
    await permissionController.checkPermission();

    if (mounted) {
      if (permissionController.hasPermission) {
        setState(() {
          _statusText = 'Musiqalar yuklanmoqda...';
        });

        // Musiqalarni yuklab olish
        final homeController = Provider.of<HomeController>(
          context,
          listen: false,
        );
        await homeController.loadAllMusic();

        // Favorites controller'ni initialize qilish
        final favoritesController = Provider.of<FavoritesController>(
          context,
          listen: false,
        );
        await favoritesController.loadFavorites();
        favoritesController.updateFavoriteSongs(homeController.songs);

        if (mounted) {
          setState(() {
            _statusText = '${homeController.songs.length} ta qo\'shiq topildi';
          });
        }
      } else {
        setState(() {
          _statusText = 'Permission kerak';
        });
      }
    }

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (permissionController.hasPermission) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        // Dialog bilan permission so'rash
        if (mounted) {
          _showPermissionDialog(context, permissionController);
        }
      }
    }
  }

  Future<void> _showPermissionDialog(
    BuildContext context,
    PermissionController controller,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // context o'rniga dialogContext
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Permission Kerak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          content: const Text(
            'Musiqalarni o\'qish uchun storage permission kerak. Bu permission faqat musiqalarni topish va o\'ynatish uchun ishlatiladi.',
            style: TextStyle(color: AppTheme.textSecondaryColor, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Avval dialog'ni yoping
                Navigator.of(dialogContext).pop(); // dialogContext ishlatamiz

                // Permission so'rang
                final granted = await controller.requestPermission();

                // Context hali active ekanligini tekshiring
                if (context.mounted && granted) {
                  // QUSHISH: Musiqalarni yuklash
                  setState(() {
                    _statusText = 'Musiqalar yuklanmoqda...';
                  });

                  final homeController = Provider.of<HomeController>(
                    context,
                    listen: false,
                  );
                  homeController.initialize(); // yoki loadAllMusic()
                  await homeController.loadAllMusic();

                  if (context.mounted) {
                    setState(() {
                      _statusText =
                          '${homeController.songs.length} ta qo\'shiq topildi';
                    });

                    await Future.delayed(const Duration(seconds: 1));

                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Permission Berish',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // dialogContext ishlatamiz
                // Ilovani yopish (optional)
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Bekor qilish'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            Text(
                              'Melody Player',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Musiqangizni tinglang',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          if (_statusText.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _statusText,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
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
}
