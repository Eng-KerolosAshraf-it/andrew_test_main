import '../constants/assets.dart';
import '../constants/translations.dart';

class ProjectData {
  static List<Map<String, String>> getMockProjects(String lang) {
    return [
      {
        'title': 'Lakeside Residence',
        'status': AppTranslations.get('on_track', lang),
        'stage': AppTranslations.get('foundation', lang),
        'image': AppAssets.lakesideResidence,
      },
      {
        'title': 'Mountain View Cabin',
        'status': AppTranslations.get('on_track', lang),
        'stage': AppTranslations.get('framing', lang),
        'image': AppAssets.mountainViewCabin,
      },
      {
        'title': 'Urban Loft Renovation',
        'status': AppTranslations.get('on_track', lang),
        'stage': AppTranslations.get('finishing', lang),
        'image': AppAssets.urbanLoftRenovation,
      },
    ];
  }
}
