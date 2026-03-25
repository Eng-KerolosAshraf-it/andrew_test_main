import 'package:flutter/material.dart';

// أداة التحكم في الاستجابة (Responsive): تساعد في تغيير شكل الواجهة بناءً على حجم الشاشة
class Responsive extends StatelessWidget {
  final Widget mobile; // الويجيت الذي يظهر في الجوال
  final Widget? tablet; // الويجيت الذي يظهر في التابلت (اختياري)
  final Widget desktop; // الويجيت الذي يظهر في الكمبيوتر

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // دوال ساكنة للتحقق من نوع الجهاز الحالي بناءً على عرض الشاشة
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // اختيار الويجيت المناسب للعرض بناءً على عرض الشاشة الحالي
    if (size.width >= 1100) {
      return desktop;
    } else if (size.width >= 850 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
