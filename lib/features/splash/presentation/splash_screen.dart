import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/branding_assets.dart';

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
    _scale = Tween<double>(begin: .82, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF06152F),
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
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF478DFF).withValues(alpha: .24),
                      blurRadius: 42,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  BrandingAssets.splashLogo,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MindVault Archive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Your Thoughts. Your Archive.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
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
