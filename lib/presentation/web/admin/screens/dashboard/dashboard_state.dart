// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
class DashboardStats {
  final int totalProjects;
  final int totalEngineers;
  final int totalTechnicians;
  final int totalClients;
  final int newRequests; // فورمات مكتملة لسه ماتحولتش لمشروع

  const DashboardStats({
    this.totalProjects = 0,
    this.totalEngineers = 0,
    this.totalTechnicians = 0,
    this.totalClients = 0,
    this.newRequests = 0,
  });
}

class DashboardState {
  final DashboardStats stats;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.stats = const DashboardStats(),
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
