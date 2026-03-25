class FormData {
  static const List<String> buildingTypeKeys = [
    'villa',
    'apt_building',
    'office_building',
    'factory',
  ];

  static const List<String> soilTypeKeys = ['clay', 'sandy', 'rocky', 'other'];

  static const List<String> projectTypeKeys = ['Residential', 'Commercial'];

  static const Map<String, String> projectTypes = {
    'Residential': 'res_const',
    'Commercial': 'comm_const',
  };

  static const List<String> constructionScopes = [
    'struct_exec_only',
    'full_turnkey_const',
  ];

  static const List<String> facadeDirections = [
    'north',
    'south',
    'east',
    'west',
  ];

  static const List<String> nearbyServicesKeys = [
    'sewer',
    'water',
    'electricity',
  ];

  static const List<String> designPhases = ['New Design', 'Modification'];
}
