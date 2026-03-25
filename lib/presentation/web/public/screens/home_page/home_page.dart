import 'package:flutter/material.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/presentation/web/public/widgets/home_page/hero_section.dart';
import 'package:engineering_platform/presentation/web/public/widgets/home_page/services_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _servicesKey = GlobalKey();

  void _scrollToServices() {
    final ctx = _servicesKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutQuart);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        return Column(
          children: [
            HeroSection(onGetStarted: _scrollToServices),
            ServicesSection(key: _servicesKey),
          ],
        );
      },
    );
  }
}
