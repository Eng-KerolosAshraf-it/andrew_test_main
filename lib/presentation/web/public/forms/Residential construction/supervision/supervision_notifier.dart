import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'supervision_state.dart';

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
final supervisionProvider =
    NotifierProvider<SupervisionNotifier, SupervisionState>(
  SupervisionNotifier.new,
);

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────
class SupervisionNotifier extends Notifier<SupervisionState> {
  @override
  SupervisionState build() => const SupervisionState();

  // ── تحديث الحقول النصية ──────────────────
  void updateFirstName(String v)       => state = state.copyWith(firstName: v);
  void updateMiddleName(String v)      => state = state.copyWith(middleName: v);
  void updateLastName(String v)        => state = state.copyWith(lastName: v);
  void updateIdNumber(String v)        => state = state.copyWith(idNumber: v);
  void updateAddress(String v)         => state = state.copyWith(address: v);
  void updatePhone(String v)           => state = state.copyWith(phone: v);
  void updateAltPhone(String v)        => state = state.copyWith(altPhone: v);
  void updateEmail(String v)           => state = state.copyWith(email: v);
  void updateLocation(String v)        => state = state.copyWith(location: v);
  void updateDetailedAddress(String v) => state = state.copyWith(detailedAddress: v);
  void updateLandArea(String v)        => state = state.copyWith(landArea: v);
  void updateBuildingArea(String v)    => state = state.copyWith(buildingArea: v);
  void updateFloors(String v)          => state = state.copyWith(floors: v);
  void updateUnits(String v)           => state = state.copyWith(units: v);
  void updateNotes(String v)           => state = state.copyWith(notes: v);

  // ── تحديث الاختيارات ─────────────────────
  void setIsExistingProject(bool v)    => state = state.copyWith(isExistingProject: v);
  void setIsSiteAvailable(bool v)      => state = state.copyWith(isSiteAvailable: v);
  void setProjectType(String v)        => state = state.copyWith(projectType: v);
  void setBuildingType(String v)       => state = state.copyWith(buildingType: v);
  void setIsInsideCompound(bool v)     => state = state.copyWith(isInsideCompound: v);
  void setDesignPhase(String v)        => state = state.copyWith(designPhase: v);
  void setSoilType(String v)           => state = state.copyWith(soilType: v);
  void setHasBasement(bool v)          => state = state.copyWith(hasBasement: v);
  void setFacadeDirection(String v)    => state = state.copyWith(facadeDirection: v);
  void setClientWantsSoilStudy(bool v) => state = state.copyWith(clientWantsSoilStudy: v);

  // ── الخدمات القريبة ───────────────────────
  void toggleNearbyService(String service, List<String> allKeys) {
    final updated = List<String>.from(state.nearbyServices);
    if (updated.contains(service)) {
      updated.remove(service);
      updated.remove('all');
    } else {
      updated.add(service);
      if (updated.where((s) => s != 'all').length == allKeys.length) {
        updated.add('all');
      }
    }
    state = state.copyWith(nearbyServices: updated);
  }

  void toggleAllNearbyServices(List<String> allKeys) {
    final hasAll = state.nearbyServices.contains('all');
    state = state.copyWith(
      nearbyServices: hasAll ? [] : ['all', ...allKeys],
    );
  }

  // ── رفع الملفات ──────────────────────────
  Future<void> pickDesignFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      state = state.copyWith(
        designFileName: result.files.single.name,
        designFileBytes: result.files.single.bytes,
      );
    }
  }

  Future<void> pickSoilReport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      state = state.copyWith(
        soilReportFileName: result.files.single.name,
        soilReportBytes: result.files.single.bytes,
      );
    }
  }

  // ── رفع ملف لـ Supabase ──────────────────
  Future<String?> _uploadFile(Uint8List? bytes, String fileName, String folder) async {
    if (bytes == null || fileName.isEmpty) return null;
    final filePath = '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    try {
      await supabaseService.client.storage.from('project-files').uploadBinary(filePath, bytes);
      return supabaseService.client.storage.from('project-files').getPublicUrl(filePath);
    } catch (e) {
      return null;
    }
  }

  // ── إرسال النموذج ────────────────────────
  Future<void> submitForm() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final currentUser = supabaseService.client.auth.currentUser;
      if (currentUser == null) throw Exception('لازم تسجل دخول الأول');

      final designFileUrl = await _uploadFile(state.designFileBytes, state.designFileName ?? '', 'designs');
      final soilReportUrl = await _uploadFile(state.soilReportBytes, state.soilReportFileName ?? '', 'soil_reports');

      await supabaseService.client.from('project_service_forms').insert({
        'client_id': currentUser.id,
        'service_id': 3,
        'form_type': 'Residential_supervision',
        'form_data': {
          'first_name': state.firstName,
          'middle_name': state.middleName.isEmpty ? null : state.middleName,
          'last_name': state.lastName,
          'id_number': state.idNumber,
          'address': state.address,
          'phone': state.phone,
          'alt_phone': state.altPhone.isEmpty ? null : state.altPhone,
          'email': state.email,
          'location': state.location,
          'detailed_address': state.detailedAddress.isEmpty ? null : state.detailedAddress,
          'land_area': double.tryParse(state.landArea),
          'building_area': double.tryParse(state.buildingArea),
          'floors': int.tryParse(state.floors),
          'metadata': {
            'project_type': state.projectType,
            'building_type': state.buildingType,
            'soil_type': state.soilType,
            'is_existing_project': state.isExistingProject,
            'is_site_available': state.isSiteAvailable,
            'has_basement': state.hasBasement,
            'facade_direction': state.facadeDirection,
            'wants_soil_study': state.clientWantsSoilStudy,
            'nearby_services': state.nearbyServices,
            'is_inside_compound': state.isInsideCompound,
            'design_phase': state.designPhase,
            'notes': state.notes,
            'design_file_url': designFileUrl,
            'soil_report_url': soilReportUrl,
          },
        },
        'design_file_url': designFileUrl,
        'soil_report_url': soilReportUrl,
        'is_submitted': true,
      });

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() => state = const SupervisionState();
}
