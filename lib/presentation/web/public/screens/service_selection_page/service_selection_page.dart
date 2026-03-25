import 'package:flutter/material.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/data/services_data.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/presentation/web/public/widgets/service_selection_page/selection_card.dart';
import 'package:engineering_platform/presentation/web/public/forms/Residential%20construction/structural_design/Residential_structural_design_form.dart';
import 'package:engineering_platform/presentation/web/public/forms/Residential%20construction/supervision/Residential_supervision_form.dart';
import 'package:engineering_platform/presentation/web/public/forms/Residential%20construction/construction/Residential_construction_form.dart';

class ServiceSelectionPage extends StatelessWidget {
  ServiceSelectionPage({super.key});

  final ValueNotifier<String?> selectedServiceId = ValueNotifier<String?>(null);
  final GlobalKey _formKey = GlobalKey();

  Widget _getServiceForm(String serviceId) {
    switch (serviceId) {
      case 'struct':      return StructuralDesignForm();
      case 'construction': return const ConstructionForm();
      case 'supervision':  return const SupervisionForm();
      default:             return const Center(child: Text('Form not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, child) {
        final isMobile = Responsive.isMobile(context);
        final isTablet = Responsive.isTablet(context);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.accent.withValues(alpha: 0.05), Theme.of(context).scaffoldBackgroundColor],
            ),
          ),
          child: Column(
            crossAxisAlignment: lang == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(AppTranslations.get('step_closer', lang),
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 12),
              Text(AppTranslations.get('choose_service', lang),
                textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.w900, letterSpacing: -1,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                )),
              const SizedBox(height: 8),
              Text(AppTranslations.get('select_specialty', lang),
                textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                )),
              const SizedBox(height: 32),

              // كروت الاختيار
              ValueListenableBuilder<String?>(
                valueListenable: selectedServiceId,
                builder: (context, selectedId, _) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                      crossAxisSpacing: 12, mainAxisSpacing: 12,
                      childAspectRatio: isMobile ? 1.3 : 1.2,
                    ),
                    itemCount: ServicesData.civilSubServices.length,
                    itemBuilder: (context, index) {
                      final service = ServicesData.civilSubServices[index];
                      return SelectionCard(
                        title: AppTranslations.get(service['titleKey'], lang),
                        serviceId: service['id'],
                        isSelected: selectedId == service['id'],
                        onTap: () {
                          selectedServiceId.value = service['id'];
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_formKey.currentContext != null) {
                              Scrollable.ensureVisible(_formKey.currentContext!,
                                duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // الفورم
              ValueListenableBuilder<String?>(
                valueListenable: selectedServiceId,
                builder: (context, selectedId, _) {
                  if (selectedId == null) return const SizedBox.shrink();
                  return Container(
                    key: _formKey,
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(AppTranslations.get('form_details', lang),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => selectedServiceId.value = null),
                      ]),
                      const Divider(height: 32),
                      _getServiceForm(selectedId),
                    ]),
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
