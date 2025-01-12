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
    required this.location,
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
      location: Map<String, double>.from(json['location'] as Map),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {'Icon': 'calendar_today'},
    );
  }
}