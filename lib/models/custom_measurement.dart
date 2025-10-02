class CustomMeasurement {
  String id;
  String name;
  String unit;
  DateTime dateCreated;

  CustomMeasurement({
    required this.id,
    required this.name,
    required this.unit,
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory CustomMeasurement.fromJson(Map<String, dynamic> json) {
    return CustomMeasurement(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }
}