class Client {
  String id;
  String nom;
  String prenom;
  String adresse;
  String telephone;
  String? imagePath;
  DateTime dateCreation;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.telephone,
    this.imagePath,
    required this.dateCreation,
  });

  String get fullName => '$prenom $nom';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'telephone': telephone,
      'imagePath': imagePath,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      imagePath: json['imagePath'],
      dateCreation: DateTime.parse(json['dateCreation']),
    );
  }
}