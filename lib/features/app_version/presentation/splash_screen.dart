import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../models/app_version_info.dart';
import 'force_update_dialog.dart';
import 'maintenance_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _performVersionCheckAndProceed();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _performVersionCheckAndProceed() async {
    // Check app remote config + initialize auth status from local storage
    final results = await Future.wait([
      ApiClient.checkAppVersion(),
      AuthService.init(),
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);

    if (!mounted) return;

    final configJson = results[0] as Map<String, dynamic>;
    final versionInfo = AppVersionInfo.fromJson(configJson);

    if (versionInfo.action == AppVersionAction.maintenance) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MaintenanceScreen(
            versionInfo: versionInfo,
            onRetry: _performVersionCheckAndProceed,
          ),
        ),
      );
    } else if (versionInfo.action == AppVersionAction.forceUpdate) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ForceUpdateDialog(
          versionInfo: versionInfo,
          onContinue: () {},
        ),
      );
    } else if (versionInfo.action == AppVersionAction.optionalUpdate) {
      showDialog(
        context: context,
        builder: (_) => ForceUpdateDialog(
          versionInfo: versionInfo,
          onContinue: () {
            Navigator.pop(context);
            _navigateToNextScreen();
          },
        ),
      );
    } else {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // If user has valid authenticated session -> HomeScreen; otherwise -> LoginScreen
    final Widget destination = AuthService.isAuthenticated ? const HomeScreen() : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text(
                            'S',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'The IELTS Spells',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mobile Companion • Micro-learning & Habit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
