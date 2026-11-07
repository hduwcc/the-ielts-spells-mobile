import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/app_version_info.dart';

class ForceUpdateDialog extends StatelessWidget {
  final AppVersionInfo versionInfo;
  final VoidCallback onContinue;

  const ForceUpdateDialog({
    super.key,
    required this.versionInfo,
    required this.onContinue,
  });

  bool get isMandatory => versionInfo.action == AppVersionAction.forceUpdate;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isMandatory,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isMandatory ? 'Yêu cầu cập nhật' : 'Có phiên bản mới!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phiên bản hiện tại: v${versionInfo.currentVersion} • Mới nhất: v${versionInfo.latestVersion}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              if (versionInfo.releaseNotes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nội dung cập nhật:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        versionInfo.releaseNotes,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // In real device: launchUrl(Uri.parse(versionInfo.storeUrl))
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đang mở ${versionInfo.storeUrl}...'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text('Cập nhật ngay'),
                ),
              ),
              if (!isMandatory) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onContinue,
                    child: const Text(
                      'Để sau',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
