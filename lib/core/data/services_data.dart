import '../constants/assets.dart';
import '../models/service_category.dart';

// فئة بيانات الخدمات: تحتوي على القوائم الثابتة للخدمات المتاحة في التطبيق
class ServicesData {
  // قائمة خدمات الهندسة المدنية (سكني، تجاري، صناعي)
  static const List<ServiceCategory> civilServices = [
    ServiceCategory(
      id: 'residential',
      titleKey: 'res_const',
      descKey: 'res_const_desc',
      imagePath: AppAssets.residentialConstruction,
      route: '/services',
    ),
    ServiceCategory(
      id: 'commercial',
      titleKey: 'comm_const',
      descKey: 'comm_const_desc',
      imagePath: AppAssets.commercialConstruction,
      route: '/services',
    ),
    ServiceCategory(
      id: 'industrial',
      titleKey: 'ind_const',
      descKey: 'ind_const_desc',
      imagePath: AppAssets.industrialConstruction,
      route: '/services',
    ),
  ];

  // القائمة الفرعية لخدمات الهندسة المدنية (تصميم، بناء، إشراف)
  static const List<Map<String, dynamic>> civilSubServices = [
    {
      'id': 'struct',
      'titleKey': 'structural_design',
      'form': 'StructuralDesignForm',
    },
    {
      'id': 'construction',
      'titleKey': 'construction_service',
      'form': 'ConstructionForm',
    },
    {
      'id': 'supervision',
      'titleKey': 'project_supervision',
      'form': 'SupervisionForm',
    },
  ];

  // قائمة الخدمات الرئيسية المعروضة في الصفحة الرئيسية (مدني، معماري، كهرباء، الخ)
  static const List<ServiceCategory> mainServices = [
    ServiceCategory(
      id: 'civil',
      titleKey: 'civil_eng',
      descKey: 'civil_eng_desc',
      imagePath: AppAssets.civilEngineering,
      route: '/civil-services',
    ),
   /* ServiceCategory(
      id: 'arch',
      titleKey: 'arch',
      descKey: 'arch_desc',
      imagePath: AppAssets.architecture,
      route: '/architecture',
    ),
    ServiceCategory(
      id: 'electrical',
      titleKey: 'elec',
      descKey: 'elec_desc',
      imagePath: AppAssets.electricalEngineering,
      route: '/electrical',
    ),
    ServiceCategory(
      id: 'plumbing',
      titleKey: 'plumbing',
      descKey: 'plumbing_desc',
      imagePath: AppAssets.plumbing,
      route: '/plumbing',
    ),
    ServiceCategory(
      id: 'mechanical',
      titleKey: 'mech',
      descKey: 'mech_desc',
      imagePath: AppAssets.mechanicalHVAC,
      route: '/mechanical',
    ),
    ServiceCategory(
      id: 'smart',
      titleKey: 'smart',
      descKey: 'smart_desc',
      imagePath: AppAssets.smartSystems,
      route: '/smart-systems',
    ),
    ServiceCategory(
      id: 'consulting',
      titleKey: 'consult',
      descKey: 'consult_desc',
      imagePath: AppAssets.consulting,
      route: '/consulting',
    ),
    ServiceCategory(
      id: 'infra',
      titleKey: 'infra',
      descKey: 'infra_desc',
      imagePath: AppAssets.infrastructure,
      route: '/infrastructure',
    ),*/
  ];
}
