class AppConfig {
  final String appId;
  final String appUrl;
  final String appName;
  final Map<String, dynamic>? metadata;
  final bool isDevelopmentMode;

  AppConfig({
    required this.appId,
    required this.appUrl,
    required this.appName,
    this.metadata,
    this.isDevelopmentMode = true,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appId: json['appId'] as String,
      appUrl: json['appUrl'] as String,
      appName: json['appName'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDevelopmentMode: true,
    );
  }

  factory AppConfig.fromApkUrl(String url) {
    // Extract app name from URL or use a default
    final appName = url.split('/').last.replaceAll('.apk', '');
    return AppConfig(
      appId: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
      appUrl: url,
      appName: appName,
      isDevelopmentMode: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'appUrl': appUrl,
      'appName': appName,
      'metadata': metadata,
      'isDevelopmentMode': isDevelopmentMode,
    };
  }
} 