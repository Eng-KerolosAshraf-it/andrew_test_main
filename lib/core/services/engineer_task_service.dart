import '../models/engineer_task.dart';
import '../constants/assets.dart';

class EngineerTaskService {
  static Future<List<EngineerTask>> getTasks(String status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final allTasks = [
      EngineerTask(
        id: '1',
        title: 'Task 1: Foundation Inspection',
        priority: 'high',
        deadline: '10:00 AM',
        imageUrl: AppAssets.civilEngineering,
        status: 'to_do',
      ),
      EngineerTask(
        id: '2',
        title: 'Task 2: Material Delivery Check',
        priority: 'medium',
        deadline: '12:00 PM',
        imageUrl: AppAssets.residentialConstruction,
        status: 'to_do',
      ),
      EngineerTask(
        id: '3',
        title: 'Task 3: Site Safety Briefing',
        priority: 'high',
        deadline: '2:00 PM',
        imageUrl: AppAssets.infrastructure,
        status: 'to_do',
      ),
      EngineerTask(
        id: '4',
        title: 'Task 4: Equipment Maintenance',
        priority: 'low',
        deadline: '4:00 PM',
        imageUrl: AppAssets.industrialConstruction,
        status: 'to_do',
      ),
    ];

    return allTasks.where((task) => task.status == status).toList();
  }
}
