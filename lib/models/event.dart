class Event {
  final int? id;
  final int teamId;
  final String title;
  final String description;
  final String location;

  Event({
    this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int?,
      teamId: json['teamId'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}
