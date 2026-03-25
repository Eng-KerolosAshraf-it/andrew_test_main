class ClientRequest {
  final String id;
  final String title;
  final String clientName;
  final String date;
  final String projectType;
  final String description;
  final String imageUrl;

  ClientRequest({
    required this.id,
    required this.title,
    required this.clientName,
    required this.date,
    required this.projectType,
    required this.description,
    required this.imageUrl,
  });
}
