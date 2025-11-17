class Service {
  String id;
  String name;
  String description;
  List<String> requirements;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.requirements,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      requirements: List<String>.from(map['requirements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requirements': requirements,
    };
  }
}
