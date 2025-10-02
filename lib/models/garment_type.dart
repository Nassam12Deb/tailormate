class GarmentType {
  String id;
  String name;
  List<String> measurementFields;
  DateTime dateCreated;

  GarmentType({
    required this.id,
    required this.name,
    required this.measurementFields,
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'measurementFields': measurementFields,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory GarmentType.fromJson(Map<String, dynamic> json) {
    return GarmentType(
      id: json['id'],
      name: json['name'],
      measurementFields: List<String>.from(json['measurementFields']),
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }
}