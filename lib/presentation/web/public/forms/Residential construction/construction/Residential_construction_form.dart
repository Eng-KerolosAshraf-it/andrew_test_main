import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engineering_platform/shared/widgets/form_components.dart';
import 'package:engineering_platform/core/constants/colors.dart';
import 'package:engineering_platform/core/constants/translations.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/core/utils/responsive.dart';
import 'package:engineering_platform/core/data/form_data.dart';
import 'construction_notifier.dart';

class ConstructionForm extends ConsumerWidget {
  const ConstructionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final state = ref.watch(constructionProvider);
    final notifier = ref.read(constructionProvider.notifier);

    ref.listen(constructionProvider, (prev, next) {
      if (next.isSuccess) {
        _showBanner(context, AppTranslations.get('request_success', _lang()), Colors.green);
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        });
        Navigator.pop(context);
        notifier.reset();
      }
      if (next.errorMessage != null) {
        _showBanner(context, "${AppTranslations.get('request_error', _lang())}: ${next.errorMessage}", Colors.red);
      }
    });

    return ValueListenableBuilder<String>(
      valueListenable: clientLanguageNotifier,
      builder: (context, lang, _) {
        final bool isMobile = Responsive.isMobile(context);

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── رأس النموذج ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppTranslations.get('const_form_title', lang),
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── قسم المعلومات الشخصية ────────────────
                FormSection(
                  title: AppTranslations.get('personal_info_title', lang),
                  children: [
                    FormRow(children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('first_name', lang),
                        icon: Icons.person_outline,
                        initialValue: state.firstName,
                        onChanged: notifier.updateFirstName,
                        validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('middle_name', lang),
                        icon: Icons.person_outline,
                        initialValue: state.middleName,
                        onChanged: notifier.updateMiddleName,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('last_name', lang),
                        icon: Icons.person_outline,
                        initialValue: state.lastName,
                        onChanged: notifier.updateLastName,
                        validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                      )),
                    ]),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: AppTranslations.get('id_number', lang),
                      icon: Icons.badge_outlined,
                      initialValue: state.idNumber,
                      onChanged: notifier.updateIdNumber,
                      validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                    ),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: AppTranslations.get('address', lang),
                      icon: Icons.home_outlined,
                      initialValue: state.address,
                      onChanged: notifier.updateAddress,
                      validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                    ),
                    const SizedBox(height: 24),
                    FormRow(children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('phone_number', lang),
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        initialValue: state.phone,
                        onChanged: notifier.updatePhone,
                        validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('another_phone_number', lang),
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        initialValue: state.altPhone,
                        onChanged: notifier.updateAltPhone,
                      )),
                    ]),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: AppTranslations.get('email', lang),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: state.email,
                      onChanged: notifier.updateEmail,
                      validator: (v) => v!.isEmpty ? AppTranslations.get('required_error', lang) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // ── قسم تفاصيل الخدمة ────────────────────
                FormSection(
                  title: AppTranslations.get('req_service_title', lang),
                  children: [
                    Row(children: [
                      Text(AppTranslations.get('service_type', lang),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      ServiceTypeButton(label: AppTranslations.get('const_service', lang), isSelected: true),
                    ]),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('type_of_service', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24, runSpacing: 16,
                      children: FormData.constructionScopes.map((scope) => RadioOption(
                        label: AppTranslations.get(scope, lang),
                        isSelected: state.constructionServiceType == scope,
                        onTap: () => notifier.setConstructionServiceType(scope),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('existing_arch_design', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      RadioOption(label: AppTranslations.get('yes', lang), isSelected: state.hasExistingDesign,
                          onTap: () => notifier.setHasExistingDesign(true)),
                      const SizedBox(width: 24),
                      RadioOption(label: AppTranslations.get('no', lang), isSelected: !state.hasExistingDesign,
                          onTap: () => notifier.setHasExistingDesign(false)),
                    ]),
                    if (state.hasExistingDesign) ...[
                      const SizedBox(height: 24),
                      Text(AppTranslations.get('if_answer_yes', lang),
                          style: TextStyle(fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade700,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      FileUploadPlaceholder(
                        label: state.designFileName ?? AppTranslations.get('upload_arch_design', lang),
                        onTap: notifier.pickDesignFile,
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('site_available', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      RadioOption(label: AppTranslations.get('yes', lang), isSelected: state.isSiteAvailable,
                          onTap: () => notifier.setIsSiteAvailable(true)),
                      const SizedBox(width: 24),
                      RadioOption(label: AppTranslations.get('no', lang), isSelected: !state.isSiteAvailable,
                          onTap: () => notifier.setIsSiteAvailable(false)),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),

                // ── قسم نوع المشروع والموقع ──────────────
                FormSection(
                  title: AppTranslations.get('proj_id_title', lang),
                  children: [
                    Wrap(spacing: 24, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(AppTranslations.get('project_type', lang),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ServiceTypeButton(
                        label: AppTranslations.get('res_const', lang),
                        isSelected: state.projectType == 'Residential',
                        onTap: () => notifier.setProjectType('Residential'),
                      ),
                      Text(AppTranslations.get('comm_const_desc', lang),
                          style: TextStyle(fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey.shade600)),
                    ]),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('building_type', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 16, runSpacing: 16, children: FormData.buildingTypeKeys.map((key) => RadioOption(
                      label: AppTranslations.get(key, lang),
                      isSelected: state.buildingType == key,
                      onTap: () => notifier.setBuildingType(key),
                    )).toList()),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('inside_compound', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      RadioOption(label: AppTranslations.get('yes', lang), isSelected: state.isInsideCompound,
                          onTap: () => notifier.setIsInsideCompound(true)),
                      const SizedBox(width: 24),
                      RadioOption(label: AppTranslations.get('no', lang), isSelected: !state.isInsideCompound,
                          onTap: () => notifier.setIsInsideCompound(false)),
                    ]),
                    const SizedBox(height: 32),
                    AppFormField(
                      label: AppTranslations.get('geographic_location', lang),
                      icon: Icons.location_on_outlined,
                      initialValue: state.location,
                      onChanged: notifier.updateLocation,
                    ),
                    const SizedBox(height: 24),
                    AppFormField(
                      label: AppTranslations.get('approx_location', lang),
                      isLarge: true, icon: Icons.map_outlined,
                      initialValue: state.detailedAddress,
                      onChanged: notifier.updateDetailedAddress,
                    ),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('design_phase', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: FormData.designPhases.map((phase) => Row(children: [
                      RadioOption(
                        label: AppTranslations.get(phase == 'New Design' ? 'new_design' : 'mod_dev', lang),
                        isSelected: state.designPhase == phase,
                        onTap: () => notifier.setDesignPhase(phase),
                      ),
                      const SizedBox(width: 24),
                    ])).toList()),
                  ],
                ),
                const SizedBox(height: 40),

                // ── قسم بيانات الأرض والتربة ─────────────
                FormSection(
                  title: AppTranslations.get('land_details_title', lang),
                  children: [
                    Text(AppTranslations.get('soil_type', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 16, runSpacing: 16, children: FormData.soilTypeKeys.map((key) => RadioOption(
                      label: AppTranslations.get(key, lang),
                      isSelected: state.soilType == key,
                      onTap: () => notifier.setSoilType(key),
                    )).toList()),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(child: Text(AppTranslations.get('soil_report_label', lang),
                          style: const TextStyle(fontSize: 14))),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: FileUploadPlaceholder(
                        label: state.soilReportFileName ?? AppTranslations.get('upload_soil_report_btn', lang),
                        onTap: notifier.pickSoilReport,
                      )),
                    ]),
                    const SizedBox(height: 32),
                    FormRow(alignment: CrossAxisAlignment.center, children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('total_land_area', lang),
                        icon: Icons.square_foot_rounded, keyboardType: TextInputType.number,
                        initialValue: state.landArea, onChanged: notifier.updateLandArea,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: Text(AppTranslations.get('total_land_area_hint', lang),
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38 : Colors.grey.shade600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 24),
                    FormRow(alignment: CrossAxisAlignment.center, children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('actual_building_area', lang),
                        icon: Icons.home_work_outlined, keyboardType: TextInputType.number,
                        initialValue: state.buildingArea, onChanged: notifier.updateBuildingArea,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: Text(AppTranslations.get('actual_building_area_hint', lang),
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38 : Colors.grey.shade600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 24),
                    FormRow(alignment: CrossAxisAlignment.center, children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('num_floors', lang),
                        icon: Icons.layers_outlined, keyboardType: TextInputType.number,
                        initialValue: state.floors, onChanged: notifier.updateFloors,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: Text(AppTranslations.get('num_floors_hint_desc', lang),
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38 : Colors.grey.shade600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('basement_req', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      RadioOption(label: AppTranslations.get('yes', lang), isSelected: state.hasBasement,
                          onTap: () => notifier.setHasBasement(true)),
                      const SizedBox(width: 24),
                      RadioOption(label: AppTranslations.get('no', lang), isSelected: !state.hasBasement,
                          onTap: () => notifier.setHasBasement(false)),
                    ]),
                    const SizedBox(height: 32),
                    FormRow(alignment: CrossAxisAlignment.center, children: [
                      Expanded(child: AppFormField(
                        label: AppTranslations.get('num_units', lang),
                        icon: Icons.grid_view_rounded, keyboardType: TextInputType.number,
                        initialValue: state.units, onChanged: notifier.updateUnits,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: Text(AppTranslations.get('num_units_hint', lang),
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38 : Colors.grey.shade600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('facade_direction', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      Expanded(flex: 3, child: Wrap(spacing: 16, runSpacing: 16,
                        children: FormData.facadeDirections.map((key) => RadioOption(
                          label: AppTranslations.get(key, lang),
                          isSelected: state.facadeDirection.toLowerCase() == key.toLowerCase(),
                          onTap: () => notifier.setFacadeDirection(key[0].toUpperCase() + key.substring(1)),
                        )).toList(),
                      )),
                      Expanded(child: Text(AppTranslations.get('facade_direction_hint', lang),
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38 : Colors.grey.shade600, fontSize: 13))),
                    ]),
                  ],
                ),
                const SizedBox(height: 40),

                // ── قسم الملاحظات والإضافات ──────────────
                FormSection(
                  title: AppTranslations.get('notes_additions_title', lang),
                  children: [
                    Text(AppTranslations.get('nearby_services', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 24, runSpacing: 12, children: [
                      CheckboxOption(
                        label: AppTranslations.get('all_services', lang),
                        isSelected: state.nearbyServices.contains('all'),
                        onTap: () => notifier.toggleAllNearbyServices(FormData.nearbyServicesKeys),
                      ),
                      ...FormData.nearbyServicesKeys.map((service) => CheckboxOption(
                        label: AppTranslations.get(service, lang),
                        isSelected: state.nearbyServices.contains(service),
                        onTap: () => notifier.toggleNearbyService(service, FormData.nearbyServicesKeys),
                      )),
                    ]),
                    const SizedBox(height: 32),
                    Text(AppTranslations.get('wants_soil_study', lang),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormRow(children: [
                      RadioOption(label: AppTranslations.get('yes', lang), isSelected: state.clientWantsSoilStudy,
                          onTap: () => notifier.setClientWantsSoilStudy(true)),
                      const SizedBox(width: 24),
                      RadioOption(label: AppTranslations.get('no', lang), isSelected: !state.clientWantsSoilStudy,
                          onTap: () => notifier.setClientWantsSoilStudy(false)),
                    ]),
                    const SizedBox(height: 32),
                    AppFormField(
                      label: AppTranslations.get('additional_notes', lang),
                      hint: AppTranslations.get('additional_notes_hint', lang),
                      isLarge: true, icon: Icons.note_add_outlined,
                      initialValue: state.notes, onChanged: notifier.updateNotes,
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── زر الإرسال ───────────────────────────
                Center(
                  child: SizedBox(
                    height: 60,
                    width: isMobile ? double.infinity : 300,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                notifier.submitForm();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: state.isLoading
                          ? const SizedBox(height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(AppTranslations.get('submit_request', lang),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        );
      },
    );
  }

  String _lang() => clientLanguageNotifier.value;

  void _showBanner(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      content: Text(message),
      backgroundColor: color,
      actions: [
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: Text(color == Colors.green ? 'OK' : 'DISMISS',
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
