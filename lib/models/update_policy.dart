class UpdatePolicy {
  const UpdatePolicy({
    required this.platform,
    required this.minRequiredVersion,
    required this.forceUpdateUrl,
    required this.isEnabled,
  });

  final String platform;
  final String minRequiredVersion;
  final String forceUpdateUrl;
  final bool isEnabled;

  factory UpdatePolicy.fromMap(Map<String, dynamic> map) {
    return UpdatePolicy(
      platform: (map['platform'] ?? '').toString(),
      minRequiredVersion: (map['min_required_version'] ?? '').toString(),
      forceUpdateUrl: (map['force_update_url'] ?? '').toString(),
      isEnabled: map['is_enabled'] == true,
    );
  }
}
