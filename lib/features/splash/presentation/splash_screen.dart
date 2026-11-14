import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/branding_assets.dart';
import 'package:mindvault_archive/app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(
      begin: .82,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) context.go('/home');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Uint8List _logoBytes() {
    try {
      return BrandingAssets.splashLogo;
    } on FormatException catch (error) {
      debugPrint(
        'Splash logo data is invalid; using the main app logo: $error',
      );
      return BrandingAssets.appLogo;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.lightBackground,
    body: Center(
      child: FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.ink, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.ink,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  _logoBytes(),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MindVault Archive',
                style: TextStyle(
                  color: Color(0xFF171719),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Your Thoughts. Your Archive.',
                style: TextStyle(
                  color: const Color(0xFF171719).withValues(alpha: .68),
                  fontSize: 14,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
