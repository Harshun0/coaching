import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// A stable per-install identifier sent to the backend for single-device login.
/// Not a hardware ID (those are unreliable/restricted on modern Android & iOS) —
/// each app install gets one stable value for its lifetime.
Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return info.id;
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return info.identifierForVendor ?? info.name;
  }
  return 'unknown-device';
}
