/// User model for DuRey game
class UserModel {
  final String id;
  final String deviceId;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final String? country;
  final String? appVersion;

  UserModel({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    this.lastActiveAt,
    this.country,
    this.appVersion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      country: json['country'] as String?,
      appVersion: json['app_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'country': country,
      'app_version': appVersion,
    };
  }

  UserModel copyWith({
    String? id,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? country,
    String? appVersion,
  }) {
    return UserModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      country: country ?? this.country,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
