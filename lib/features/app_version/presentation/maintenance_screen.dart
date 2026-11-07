import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/app_version_info.dart';

class MaintenanceScreen extends StatelessWidget {
  final AppVersionInfo versionInfo;
  final VoidCallback onRetry;

  const MaintenanceScreen({
    super.key,
    required this.versionInfo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: AppColors.warning,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                versionInfo.maintenanceTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                versionInfo.maintenanceMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 180,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
