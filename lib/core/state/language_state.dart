import 'package:flutter/material.dart';

// مراقب حالة اللغة: يستخدم لتنبيه التطبيق عند تغيير اللغة (عربي 'ar' بشكل افتراضي)
final languageNotifier = ValueNotifier<String>('ar');
final clientLanguageNotifier = ValueNotifier<String>('ar');
final adminLanguageNotifier = ValueNotifier<String>('ar');
final engineerLanguageNotifier = ValueNotifier<String>('ar');
final technicianLanguageNotifier = ValueNotifier<String>('ar');

// مفتاح التنقل العالمي: يسمح بالتنقل بين الصفحات من أي مكان في الكود دون الحاجة لـ BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
