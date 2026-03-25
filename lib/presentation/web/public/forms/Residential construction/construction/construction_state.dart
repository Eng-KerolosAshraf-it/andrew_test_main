import 'dart:typed_data';

/// يمثل الحالة الكاملة لنموذج التنفيذ (المقاولات)
class ConstructionState {
  // ── بيانات شخصية ──
  final String firstName;
  final String middleName;
  final String lastName;
  final String idNumber;
  final String address;
  final String phone;
  final String altPhone;
  final String email;

  // ── تفاصيل الخدمة ──
  final String constructionServiceType;
  final bool hasExistingDesign;
  final bool isSiteAvailable;

  // ── نوع المشروع والموقع ──
  final String projectType;
  final String buildingType;
  final bool isInsideCompound;
  final String location;
  final String detailedAddress;
  final String designPhase;

  // ── بيانات الأرض والمبنى ──
  final String soilType;
  final String landArea;
  final String buildingArea;
  final String floors;
  final bool hasBasement;
  final String units;
  final String facadeDirection;

  // ── ملاحظات وإضافات ──
  final List<String> nearbyServices;
  final bool clientWantsSoilStudy;
  final String notes;

  // ── الملفات ──
  final String? designFileName;
  final Uint8List? designFileBytes;
  final String? soilReportFileName;
  final Uint8List? soilReportBytes;

  // ── حالة الإرسال ──
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ConstructionState({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.idNumber = '',
    this.address = '',
    this.phone = '',
    this.altPhone = '',
    this.email = '',
    this.constructionServiceType = 'struct_exec_only',
    this.hasExistingDesign = false,
    this.isSiteAvailable = true,
    this.projectType = 'Residential',
    this.buildingType = 'villa',
    this.isInsideCompound = false,
    this.location = '',
    this.detailedAddress = '',
    this.designPhase = 'New Design',
    this.soilType = 'clay',
    this.landArea = '',
    this.buildingArea = '',
    this.floors = '',
    this.hasBasement = false,
    this.units = '',
    this.facadeDirection = 'North',
    this.nearbyServices = const [],
    this.clientWantsSoilStudy = false,
    this.notes = '',
    this.designFileName,
    this.designFileBytes,
    this.soilReportFileName,
    this.soilReportBytes,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ConstructionState copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? idNumber,
    String? address,
    String? phone,
    String? altPhone,
    String? email,
    String? constructionServiceType,
    bool? hasExistingDesign,
    bool? isSiteAvailable,
    String? projectType,
    String? buildingType,
    bool? isInsideCompound,
    String? location,
    String? detailedAddress,
    String? designPhase,
    String? soilType,
    String? landArea,
    String? buildingArea,
    String? floors,
    bool? hasBasement,
    String? units,
    String? facadeDirection,
    List<String>? nearbyServices,
    bool? clientWantsSoilStudy,
    String? notes,
    String? designFileName,
    Uint8List? designFileBytes,
    String? soilReportFileName,
    Uint8List? soilReportBytes,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ConstructionState(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      constructionServiceType: constructionServiceType ?? this.constructionServiceType,
      hasExistingDesign: hasExistingDesign ?? this.hasExistingDesign,
      isSiteAvailable: isSiteAvailable ?? this.isSiteAvailable,
      projectType: projectType ?? this.projectType,
      buildingType: buildingType ?? this.buildingType,
      isInsideCompound: isInsideCompound ?? this.isInsideCompound,
      location: location ?? this.location,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      designPhase: designPhase ?? this.designPhase,
      soilType: soilType ?? this.soilType,
      landArea: landArea ?? this.landArea,
      buildingArea: buildingArea ?? this.buildingArea,
      floors: floors ?? this.floors,
      hasBasement: hasBasement ?? this.hasBasement,
      units: units ?? this.units,
      facadeDirection: facadeDirection ?? this.facadeDirection,
      nearbyServices: nearbyServices ?? this.nearbyServices,
      clientWantsSoilStudy: clientWantsSoilStudy ?? this.clientWantsSoilStudy,
      notes: notes ?? this.notes,
      designFileName: designFileName ?? this.designFileName,
      designFileBytes: designFileBytes ?? this.designFileBytes,
      soilReportFileName: soilReportFileName ?? this.soilReportFileName,
      soilReportBytes: soilReportBytes ?? this.soilReportBytes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
