class Measurement {
  String id;
  String clientId;
  String type;
  Map<String, double> valeurs;
  DateTime dateCreation;
  List<String> fabricImagePaths; // Liste pour jusqu'à 2 photos

  Measurement({
    required this.id,
    required this.clientId,
    required this.type,
    required this.valeurs,
    required this.dateCreation,
    List<String>? fabricImagePaths,
  }) : fabricImagePaths = fabricImagePaths ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'type': type,
      'valeurs': valeurs,
      'dateCreation': dateCreation.toIso8601String(),
      'fabricImagePaths': fabricImagePaths,
    };
  }

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      clientId: json['clientId'],
      type: json['type'],
      valeurs: Map<String, double>.from(json['valeurs']),
      dateCreation: DateTime.parse(json['dateCreation']),
      fabricImagePaths: List<String>.from(json['fabricImagePaths'] ?? []),
    );
  }

  // Méthode pour ajouter une photo (maximum 2)
  bool addFabricImage(String imagePath) {
    if (fabricImagePaths.length < 2) {
      fabricImagePaths.add(imagePath);
      return true;
    }
    return false;
  }

  // Méthode pour supprimer une photo
  void removeFabricImage(int index) {
    if (index >= 0 && index < fabricImagePaths.length) {
      fabricImagePaths.removeAt(index);
    }
  }

  // Vérifier si on peut ajouter plus de photos
  bool get canAddMoreImages => fabricImagePaths.length < 2;
}