import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:engineering_platform/core/themes/app_theme.dart';
import 'package:engineering_platform/core/state/language_state.dart';
import 'package:engineering_platform/presentation/web/public/screens/home_page/home_page.dart';
import 'package:engineering_platform/presentation/web/public/screens/civil_services_page/civil_services_page.dart';
import 'package:engineering_platform/presentation/web/public/screens/service_selection_page/service_selection_page.dart';
import 'package:engineering_platform/presentation/web/auth/screens/login_page.dart';
import 'package:engineering_platform/presentation/web/auth/screens/signup_page.dart';
import 'package:engineering_platform/presentation/web/client/screens/dashboard/client_dashboard.dart';
import 'package:engineering_platform/presentation/web/client/screens/projects/projects_page.dart';
import 'package:engineering_platform/presentation/web/client/screens/project_details/project_details.dart';
import 'package:engineering_platform/presentation/web/client/screens/daily_reports/daily_reports.dart';
import 'package:engineering_platform/presentation/web/client/screens/account_settings/client_account_settings.dart';
import 'package:engineering_platform/presentation/web/admin/screens/dashboard/dashboard_overview.dart';
import 'package:engineering_platform/presentation/web/admin/screens/projects/admin_projects.dart';
import 'package:engineering_platform/presentation/web/admin/screens/requests/requests.dart';
import 'package:engineering_platform/presentation/web/admin/screens/settings/account_settings.dart';
import 'package:engineering_platform/presentation/web/admin/screens/staff/admin_staff.dart';
import 'package:engineering_platform/presentation/web/admin/screens/clients/admin_clients.dart';
import 'package:engineering_platform/presentation/web/engineer/screens/assigned_projects/assigned_projects.dart';
import 'package:engineering_platform/presentation/web/engineer/screens/daily_tasks/daily_tasks.dart';
import 'package:engineering_platform/presentation/web/engineer/screens/daily_progress_report/daily_progress_report.dart';
import 'package:engineering_platform/presentation/web/engineer/screens/issues_obstacles_log/issues_obstacles_log.dart';
import 'package:engineering_platform/presentation/web/engineer/screens/eng_profile_setting/eng_profile_setting.dart';
import 'package:engineering_platform/presentation/web/technician/screens/technician_task/technician_task.dart';
import 'package:engineering_platform/presentation/web/technician/screens/task_details/task_details.dart';
import 'package:engineering_platform/presentation/web/technician/screens/execution/execution.dart';
import 'package:engineering_platform/presentation/web/technician/screens/account_settings/technician_account_settings.dart';
import 'package:engineering_platform/shared/widgets/main_layout.dart';
import 'package:engineering_platform/core/state/user_state.dart';
import 'package:engineering_platform/core/services/supabase_service.dart';
import 'package:engineering_platform/core/constants/app_constants.dart';
import 'package:engineering_platform/presentation/web/auth/screens/forget_password_page.dart';
import 'package:engineering_platform/shared/widgets/role_guard.dart';
import 'package:engineering_platform/presentation/web/client/widgets/client_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:engineering_platform/presentation/web/engineer/screens/dashboard/engineer_dashboard.dart';
import 'package:engineering_platform/presentation/web/technician/screens/dashboard/technician_dashboard.dart';

import 'package:engineering_platform/core/constants/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    final completer = Completer<void>();
    final subscription = supabaseService.client.auth.onAuthStateChange.listen((data) {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future.timeout(const Duration(seconds: 3), onTimeout: () {});
    await subscription.cancel();

    await userState.loadUser();

    runApp(const ProviderScope(child: MyApp()));
  } catch (error) {
    print('Connection Error: $error');
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Connection Error: $error')))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          locale: Locale(lang),
          initialRoute: RouteNames.home,
          routes: {
            // ================= PUBLIC =================
            RouteNames.home: (context) => MainLayout(child: const HomePage()),
            RouteNames.login: (context) => const LoginPage(),
            RouteNames.signup: (context) => const SignupPage(),
            RouteNames.forgetPassword: (context) => const ForgetPasswordPage(),
            RouteNames.civilServices: (context) => MainLayout(child: const CivilServicesPage()),
            RouteNames.services: (context) => MainLayout(child: ServiceSelectionPage()),

            // ================= CLIENT =================
            RouteNames.clientHome: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const HomePage()),
                ),
            RouteNames.clientDashboard: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const ClientDashboard()),
                ),
            RouteNames.clientProjects: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const ProjectsPage()),
                ),
            RouteNames.clientProjectDetails: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const ProjectDetails()),
                ),
            RouteNames.clientReports: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const DailyReports()),
                ),
            RouteNames.clientSettings: (context) => RoleGuard(
                  allowedRoles: ['client'],
                  child: ClientLayout(child: const ClientAccountSettings()),
                ),

            // ================= ADMIN =================
            RouteNames.adminDashboard: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const DashboardOverview(),
                ),
            RouteNames.adminProjects: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const AdminProjects(),
                ),
            RouteNames.adminRequests: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const RequestsPage(),
                ),
            RouteNames.adminSettings: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const AccountSettings(),
                ),
            RouteNames.adminStaff: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const AdminStaff(),
                ),
            RouteNames.adminClients: (context) => RoleGuard(
                  allowedRoles: ['admin'],
                  child: const AdminClients(),
                ),

            // ================= ENGINEER =================
            RouteNames.engineerDashboard: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const EngineerDashboard(),
                ),
            RouteNames.engineerProjects: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const AssignedProjects(),
                ),
            RouteNames.engineerTasks: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const DailyTasks(),
                ),
            RouteNames.engineerProgress: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const DailyProgressReport(),
                ),
            RouteNames.engineerLogs: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const IssuesObstaclesLog(),
                ),
            RouteNames.engineerSettings: (context) => RoleGuard(
                  allowedRoles: ['engineer'],
                  child: const EngProfileSetting(),
                ),

            // ================= TECHNICIAN =================
            RouteNames.technicianDashboard: (context) => RoleGuard(
                  allowedRoles: ['technician'],
                  child: const TechnicianDashboard(),
                ),
            RouteNames.technicianTasks: (context) => RoleGuard(
                  allowedRoles: ['technician'],
                  child: const TechnicianTask(),
                ),
            RouteNames.technicianTaskDetails: (context) => RoleGuard(
                  allowedRoles: ['technician'],
                  child: const TaskDetails(),
                ),
            RouteNames.technicianExecution: (context) => RoleGuard(
                  allowedRoles: ['technician'],
                  child: const Execution(),
                ),
            RouteNames.technicianSettings: (context) => RoleGuard(
                  allowedRoles: ['technician'],
                  child: const TechnicianAccountSettings(),
                ),
          },
        );
      },
    );
  }
}
