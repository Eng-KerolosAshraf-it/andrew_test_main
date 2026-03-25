import 'package:flutter/material.dart';
import '../models/technician_task.dart';
import '../constants/assets.dart';

class TechnicianData {
  static List<TechnicianTask> getMockTasks(bool isDark) {
    return [
      TechnicianTask(
        id: '1',
        title: 'Install HVAC System',
        priorityKey: 'high_priority',
        priorityColor: isDark ? Colors.orange : Colors.deepPurple.shade300,
        deadline: 'Deadline: July 20, 2024',
        statusKey: 'in_progress',
        imageUrl: AppAssets.mechanicalHVAC,
        materials: [
          'HVAC Unit',
          'Copper Piping',
          'Insulation Tape',
          'Thermostat',
          'Safety Harness',
        ],
        notes:
            'Install the main unit on the rooftop and ensure all piping is leak-free. Follow the wiring diagram in the manual.',
        duration: '6 hours',
      ),
      TechnicianTask(
        id: '2',
        title: 'Electrical Wiring for New Building',
        priorityKey: 'medium_priority',
        priorityColor: isDark ? Colors.blue : Colors.orange.shade300,
        deadline: 'Deadline: July 25, 2024',
        statusKey: 'in_progress',
        imageUrl: AppAssets.electricalEngineering,
        materials: [
          'Copper Wire (2.5mm)',
          'Electrical Conduits',
          'Circuit Breakers',
          'Switch Boxes',
          'Voltage Tester',
        ],
        notes:
            'Complete the wiring for the second floor. Ensure all circuits are properly grounded and labeled.',
        duration: '12 hours',
      ),
      TechnicianTask(
        id: '3',
        title: 'Plumbing System Check',
        priorityKey: 'low_priority',
        priorityColor: isDark ? Colors.green : Colors.blue.shade300,
        deadline: 'Deadline: August 5, 2024',
        statusKey: 'completed',
        imageUrl: AppAssets.plumbing,
        materials: [
          'Pipe Wrench',
          'Teflon Tape',
          'Pressure Gauge',
          'Replacement Valves',
          'Leak Detection Spray',
        ],
        notes:
            'Perform a full system check for any leaks or pressure drops. Replace any worn-out valves if necessary.',
        duration: '4 hours',
      ),
    ];
  }
}
