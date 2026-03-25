import '../constants/assets.dart';

class ReportData {
  static List<Map<String, String>> getAllReports(String lang) {
    bool isAr = lang == 'ar';
    // Generates a larger list of reports for demonstration
    return List.generate(20, (index) {
      int day = 20 - index;
      return {
        'day': isAr ? 'اليوم $day' : 'Day $day',
        'title': _getDayTitle(day, lang),
        'date': _getDayDate(day, lang),
        'image': _getDayImage(day),
      };
    });
  }

  static String _getDayTitle(int day, String lang) {
    bool isAr = lang == 'ar';
    switch (day) {
      case 20:
        return isAr ? 'تركيب الأنظمة الذكية' : 'Installing Smart Systems';
      case 19:
        return isAr ? 'أعمال الميكانيكا والتكييف' : 'Mechanical & HVAC Work';
      case 18:
        return isAr ? 'التمديدات الكهربائية' : 'Electrical Wiring';
      case 17:
        return isAr ? 'أعمال السباكة' : 'Plumbing Installation';
      case 16:
        return isAr ? 'بدء التشطيبات' : 'Starting Finishing Works';
      case 15:
        return isAr ? 'صيانة الموقع' : 'Site Maintenance';
      case 10:
        return isAr ? 'إكمال الهيكل الإنشائي' : 'Structural Framing Done';
      case 5:
        return isAr ? 'إكمال الأساسات' : 'Foundation Completion';
      case 4:
        return isAr ? 'الحفر والتدعيم' : 'Excavation & Reinforcement';
      case 3:
        return isAr ? 'تجهيز الموقع' : 'Site Preparation';
      case 2:
        return isAr ? 'توصيل المواد' : 'Material Delivery';
      case 1:
        return isAr ? 'بدء المشروع' : 'Project Kickoff';
      default:
        return isAr ? 'فحص جودة البناء' : 'Construction Quality Audit';
    }
  }

  static String _getDayDate(int day, String lang) {
    bool isAr = lang == 'ar';
    int julyDay = 20 + (day % 11); // Simplified logic
    return isAr ? '$julyDay يوليو، 2024' : 'July $julyDay, 2024';
  }

  static String _getDayImage(int day) {
    // Rotating between available project and service images
    List<String> images = [
      AppAssets.lakesideResidence,
      AppAssets.mountainViewCabin,
      AppAssets.urbanLoftRenovation,
      AppAssets.residentialConstruction,
      AppAssets.commercialConstruction,
      AppAssets.industrialConstruction,
      AppAssets.infrastructure,
      AppAssets.civilEngineering,
    ];
    return images[day % images.length];
  }
}
