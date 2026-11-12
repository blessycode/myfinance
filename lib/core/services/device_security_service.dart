import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class DeviceSecurityService {
  DeviceSecurityService._();

  static final instance = DeviceSecurityService._();
  final LocalAuthentication _authentication = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> get hasEnrolledBiometrics async {
    try {
      return await _authentication.isDeviceSupported() &&
          (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on LocalAuthException {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      if (!await hasEnrolledBiometrics) return false;
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }

  Future<String> deviceDescription() async {
    try {
      if (kIsWeb) {
        final info = await _deviceInfo.webBrowserInfo;
        return 'Web browser${info.browserName.name == 'unknown' ? '' : ' · ${info.browserName.name}'}';
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await _deviceInfo.androidInfo;
          return '${info.manufacturer} ${info.model} · Android ${info.version.release}';
        case TargetPlatform.iOS:
          final info = await _deviceInfo.iosInfo;
          return '${info.utsname.machine} · iOS ${info.systemVersion}';
        case TargetPlatform.macOS:
          final info = await _deviceInfo.macOsInfo;
          return '${info.model} · macOS ${info.majorVersion}';
        case TargetPlatform.windows:
          final info = await _deviceInfo.windowsInfo;
          return 'Windows ${info.majorVersion}.${info.minorVersion}';
        case TargetPlatform.linux:
          final info = await _deviceInfo.linuxInfo;
          return info.prettyName;
        case TargetPlatform.fuchsia:
          return 'Fuchsia device';
      }
    } catch (_) {
      return 'Device details unavailable';
    }
  }
}
