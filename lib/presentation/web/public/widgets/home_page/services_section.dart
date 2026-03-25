import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/data/services_data.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/public/widgets/home_page/service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final isMobile = Responsive.isMobile(context);
        final isTablet = Responsive.isTablet(context);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: isMobile ? 30 : 40),
          child: Column(
            crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(AppTranslations.get('our_services', lang),
                style: TextStyle(
                  fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.w900, letterSpacing: -1,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                )),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 5),
                  crossAxisSpacing: 24, mainAxisSpacing: isMobile ? 24 : 40,
                  childAspectRatio: isMobile ? 0.95 : 0.72,
                ),
                itemCount: ServicesData.mainServices.length,
                itemBuilder: (context, index) {
                  final service = ServicesData.mainServices[index];
                  return ServiceCard(
                    title: AppTranslations.get(service.titleKey, lang),
                    desc: AppTranslations.get(service.descKey, lang),
                    imagePath: service.imagePath,
                    onTap: () => Navigator.pushNamed(context, service.route),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
