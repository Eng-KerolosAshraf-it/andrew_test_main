class EngineerTask {
  final String id;
  final String title;
  final String priority; // high, medium, low
  final String deadline;
  final String imageUrl;
  final String status;

  EngineerTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.deadline,
    required this.imageUrl,
    required this.status,
  });
}
