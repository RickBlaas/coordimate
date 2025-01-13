class Event {
  final int? id;
  final int teamId;
  final String title;
  final String description;
  final DateTime datetimeStart;
  final DateTime datetimeEnd;
  final Map<String, double> location;
  final Map<String, dynamic>? metadata;

  Event({
    this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.datetimeStart,
    required this.datetimeEnd,
    this.location = const {'latitude': 0.0,'longitude': 0.0}, // TODO: Replace with actual location.
    this.metadata,
  });

  // Factory constructor to create Event from JSON data
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int?,
      teamId: json['teamId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      datetimeStart: DateTime.parse(json['datetimeStart'] as String),
      datetimeEnd: DateTime.parse(json['datetimeEnd'] as String),
      // Handle possible int values for location
      location: {
        'latitude': (json['location']?['latitude'] ?? 0).toDouble(),
        'longitude': (json['location']?['longitude'] ?? 0).toDouble(),
      },
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
