import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceType { mobile, tablet, desktop }

final layoutProvider = Provider<DeviceType>((ref) {
  // This is a placeholder that will be updated by a provider that listens to window size
  // For simplicity in this refactor, we'll use a standard MediaQuery approach 
  // but wrap it in a cleaner API.
  throw UnimplementedError('Use layoutProviderWithContext instead');
});

class Layout {
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return DeviceType.mobile;
    if (width < 1200) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) => deviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceType(context) == DeviceType.desktop;
}
