import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Service for managing device identification
class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static String? _cachedDeviceId;

  /// Get or generate device ID
  /// This ID is generated once and persisted locally
  static Future<String> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Try to load from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_deviceIdKey);

    if (storedId != null && storedId.isNotEmpty) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    // Generate new device ID
    String deviceId = await _generateDeviceId();

    // Store it
    await prefs.setString(_deviceIdKey, deviceId);
    _cachedDeviceId = deviceId;

    return deviceId;
  }

  /// Generate unique device ID based on platform
  static Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Use Android ID (unique per device and app installation)
        return 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Use identifierForVendor (unique per vendor per device)
        final vendorId = iosInfo.identifierForVendor ?? 'unknown';
        return 'ios_$vendorId';
      } else {
        // Fallback for other platforms
        return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      // Fallback if device info fails
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Clear device ID (for testing purposes only)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
  }
}
