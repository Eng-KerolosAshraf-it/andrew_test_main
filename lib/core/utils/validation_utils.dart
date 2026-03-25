import '../constants/translations.dart';

class ValidationUtils {
  static String? validateEmail(String? value, String lang) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_field', lang);
    }
    if (!value.contains('@')) {
      return AppTranslations.get('invalid_email', lang);
    }
    return null;
  }

  static String? validatePassword(String? value, String lang) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_field', lang);
    }
    if (value.length < 6) {
      return AppTranslations.get('short_password', lang);
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
    String lang,
  ) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_field', lang);
    }
    if (value != password) {
      return AppTranslations.get('passwords_not_match', lang);
    }
    return null;
  }

  static String? validateRequired(String? value, String lang) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_field', lang);
    }
    return null;
  }
}
