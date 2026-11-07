enum AppVersionAction {
  upToDate,
  optionalUpdate,
  forceUpdate,
  maintenance,
}

class AppVersionInfo {
  final AppVersionAction action;
  final String currentVersion;
  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;
  final bool isUnderMaintenance;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final String releaseNotes;

  AppVersionInfo({
    required this.action,
    required this.currentVersion,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
    required this.isUnderMaintenance,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
    required this.releaseNotes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    AppVersionAction action = AppVersionAction.upToDate;
    final actionStr = json['action'] as String? ?? 'UP_TO_DATE';

    if (json['isUnderMaintenance'] == true || actionStr == 'MAINTENANCE') {
      action = AppVersionAction.maintenance;
    } else if (actionStr == 'FORCE_UPDATE') {
      action = AppVersionAction.forceUpdate;
    } else if (actionStr == 'OPTIONAL_UPDATE') {
      action = AppVersionAction.optionalUpdate;
    }

    return AppVersionInfo(
      action: action,
      currentVersion: json['currentVersion'] ?? '1.0.0',
      latestVersion: json['latestVersion'] ?? '1.0.0',
      minSupportedVersion: json['minSupportedVersion'] ?? '1.0.0',
      storeUrl: json['storeUrl'] ?? 'https://theieltsspells.com',
      isUnderMaintenance: json['isUnderMaintenance'] ?? false,
      maintenanceTitle: json['maintenanceTitle'] ?? 'Hệ thống đang bảo trì',
      maintenanceMessage: json['maintenanceMessage'] ?? 'Hệ thống đang bảo trì định kỳ.',
      releaseNotes: json['releaseNotes'] ?? '',
    );
  }
}
