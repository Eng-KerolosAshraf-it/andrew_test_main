import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/constants/assets.dart';
import 'package:engineering_platform/core/utils/responsive.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  const HeroSection({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final isMobile = Responsive.isMobile(context);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                AppColors.accentLight.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.5),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 140, vertical: isMobile ? 24 : 36),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(AppTranslations.get('welcome_banner', lang),
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                    ),
                    const SizedBox(height: 10),
                    Text(AppTranslations.get('hero_title', lang),
                      textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 44, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -1.5,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                      )),
                    const SizedBox(height: 10),
                    Text(AppTranslations.get('hero_subtitle', lang),
                      textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 17, height: 1.5,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                      )),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        onPressed: onGetStarted,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          backgroundColor: AppColors.accent, foregroundColor: Colors.white,
                          elevation: 8, shadowColor: AppColors.accent.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppTranslations.get('get_started', lang),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile) const SizedBox(height: 20) else const SizedBox(width: 24),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  height: isMobile ? 180 : 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))],
                    image: const DecorationImage(image: AssetImage(AppAssets.logo), fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
