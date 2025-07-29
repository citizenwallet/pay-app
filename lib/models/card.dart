class Card {
  final String serial;
  final String? project;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String owner;

  const Card({
    required this.serial,
    this.project,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      serial: json['serial'],
      project: json['project'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'project': project,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'owner': owner,
    };
  }
}
