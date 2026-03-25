import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/data/services_data.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/public/widgets/service_category_card/service_category_card.dart';

class CivilServicesPage extends StatelessWidget {
  const CivilServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final bool isMobile = Responsive.isMobile(context);
        final bool isTablet = Responsive.isTablet(context);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: isMobile ? 12 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.accent.withValues(alpha: 0.05), Theme.of(context).scaffoldBackgroundColor],
                ),
              ),
              child: Column(
                crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(AppTranslations.get('civil_services_title', lang),
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.w900, letterSpacing: -1,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                    )),
                  const SizedBox(height: 8),
                  Text(AppTranslations.get('civil_services_subtitle', lang),
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15, letterSpacing: 0.5,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                    )),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(AppTranslations.get('choose_service', lang),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                      crossAxisSpacing: 16, mainAxisSpacing: 4,
                      childAspectRatio: isMobile ? 0.9 : 0.88,
                    ),
                    itemCount: ServicesData.civilServices.length,
                    itemBuilder: (context, index) {
                      final service = ServicesData.civilServices[index];
                      return ServiceCategoryCard(
                        imagePath: service.imagePath,
                        title: AppTranslations.get(service.titleKey, lang),
                        description: AppTranslations.get(service.descKey, lang),
                        onTap: () => Navigator.pushNamed(context, service.route),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(AppTranslations.get('select_service', lang),
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                        )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
