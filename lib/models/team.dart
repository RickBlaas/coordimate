class Team {
  final int? id;
  final String name;
  final String description;
  final Map<String, dynamic>? metadata;

  // final String createdAt;
  // final String updatedAt;
  final List<TeamMember> members;
  final int? ownerId;

  Team({
    this.id,
    required this.name,
    required this.description,
    this.metadata = const {'Icon': 'calendar_today'},  
    this.members = const [],
    this.ownerId,
  });

  // Factory constructor to create Team from JSON data
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {'Icon': 'calendar_today'},
      members: (json['members'] as List?)
          ?.map((member) => TeamMember.fromJson(member as Map<String, dynamic>))
          .toList() ?? [],
      ownerId: json['ownerId'] as int?,
    );
  }
}

class TeamMember {
  final int id;
  final String name;

  TeamMember({
    required this.id,
    required this.name,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as int? ?? 0,  // Default to 0 if null
      name: json['name'] as String? ?? '',
    );
  }
}