import '../models/engineer_project.dart';
import '../constants/assets.dart';

class EngineerData {
  static List<EngineerProject> getMockProjects() {
    return [
      EngineerProject(
        name: 'Grandview Residences',
        location: 'San Francisco, CA',
        imageUrl: AppAssets.lakesideResidence,
        progress: 0.75,
        status: 'active',
      ),
      EngineerProject(
        name: 'Riverbend Plaza',
        location: 'Austin, TX',
        imageUrl: AppAssets.mountainViewCabin,
        progress: 0.40,
        status: 'pending_review',
      ),
      EngineerProject(
        name: 'Summit Tower',
        location: 'Denver, CO',
        imageUrl: AppAssets.urbanLoftRenovation,
        progress: 1.0,
        status: 'completed',
      ),
      EngineerProject(
        name: 'Coastal Retreat',
        location: 'Miami, FL',
        imageUrl: AppAssets.lakesideResidence,
        progress: 0.60,
        status: 'active',
      ),
      EngineerProject(
        name: 'Maplewood Estates',
        location: 'Seattle, WA',
        imageUrl: AppAssets.mountainViewCabin,
        progress: 0.90,
        status: 'active',
      ),
      EngineerProject(
        name: 'Oakridge Commons',
        location: 'Chicago, IL',
        imageUrl: AppAssets.urbanLoftRenovation,
        progress: 0.25,
        status: 'active',
      ),
    ];
  }
}
