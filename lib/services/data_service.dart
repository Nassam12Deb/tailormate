import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/measurement.dart';
import '../models/garment_type.dart';
import '../models/custom_measurement.dart';
import 'image_service.dart';

class User {
  String id;
  String email;
  String password;
  String nom;
  String prenom;
  String telephone;
  DateTime dateCreation;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.dateCreation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      dateCreation: DateTime.parse(json['dateCreation']),
    );
  }

  String get fullName => '$prenom $nom';
}

class DataService with ChangeNotifier {
  List<User> _users = [];
  List<Client> _clients = [];
  List<Measurement> _measurements = [];
  List<GarmentType> _garmentTypes = [];
  List<CustomMeasurement> _customMeasurements = [];
  User? _currentUser;
  bool _isLoggedIn = false;

  List<User> get users => _users;
  List<Client> get clients => _clients.where((client) => _isUserData(client.id)).toList();
  List<Measurement> get measurements => _measurements.where((measurement) => _isUserData(measurement.clientId)).toList();
  List<GarmentType> get garmentTypes => _garmentTypes.where((type) => _isUserData(type.id)).toList();
  List<CustomMeasurement> get customMeasurements => _customMeasurements.where((measure) => _isUserData(measure.id)).toList();
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  DataService() {
    _loadData();
  }

  bool _isUserData(String id) {
    return _currentUser != null && id.startsWith(_currentUser!.id);
  }

  String _generateUserSpecificId(String baseId) {
    return '${_currentUser?.id}_$baseId';
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger les utilisateurs
    final usersJson = prefs.getStringList('users') ?? [];
    _users = usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
    
    // Charger les clients
    final clientsJson = prefs.getStringList('clients') ?? [];
    _clients = clientsJson.map((json) => Client.fromJson(jsonDecode(json))).toList();
    
    // Charger les mesures
    final measurementsJson = prefs.getStringList('measurements') ?? [];
    _measurements = measurementsJson.map((json) => Measurement.fromJson(jsonDecode(json))).toList();
    
    // Charger les types de vêtements
    final garmentTypesJson = prefs.getStringList('garmentTypes') ?? [];
    _garmentTypes = garmentTypesJson.map((json) => GarmentType.fromJson(jsonDecode(json))).toList();
    
    // Charger les mesures personnalisées
    final customMeasurementsJson = prefs.getStringList('customMeasurements') ?? [];
    _customMeasurements = customMeasurementsJson.map((json) => CustomMeasurement.fromJson(jsonDecode(json))).toList();
    
    // État de connexion
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final currentUserId = prefs.getString('currentUserId');
    if (currentUserId != null && _users.isNotEmpty) {
      _currentUser = _users.firstWhere(
        (user) => user.id == currentUserId,
        orElse: () => _users.first,
      );
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder les utilisateurs
    final usersJson = _users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList('users', usersJson);
    
    // Sauvegarder les clients
    final clientsJson = _clients.map((client) => jsonEncode(client.toJson())).toList();
    await prefs.setStringList('clients', clientsJson);
    
    // Sauvegarder les mesures
    final measurementsJson = _measurements.map((measurement) => jsonEncode(measurement.toJson())).toList();
    await prefs.setStringList('measurements', measurementsJson);
    
    // Sauvegarder les types de vêtements
    final garmentTypesJson = _garmentTypes.map((type) => jsonEncode(type.toJson())).toList();
    await prefs.setStringList('garmentTypes', garmentTypesJson);
    
    // Sauvegarder les mesures personnalisées
    final customMeasurementsJson = _customMeasurements.map((measure) => jsonEncode(measure.toJson())).toList();
    await prefs.setStringList('customMeasurements', customMeasurementsJson);
    
    // Sauvegarder l'état de connexion
    await prefs.setBool('isLoggedIn', _isLoggedIn);
    if (_currentUser != null) {
      await prefs.setString('currentUserId', _currentUser!.id);
    } else {
      await prefs.remove('currentUserId');
    }
  }

  // Gestion des utilisateurs
  Future<bool> register(User user) async {
    // Vérifier si l'email existe déjà
    if (_users.any((u) => u.email == user.email)) {
      return false;
    }

    _users.add(user);
    
    // Créer des données par défaut pour le nouvel utilisateur
    _createDefaultDataForUser(user);
    
    await _saveData();
    notifyListeners();
    return true;
  }

  void _createDefaultDataForUser(User user) {
    // Types de vêtements par défaut
    _garmentTypes.addAll([
      GarmentType(
        id: '${user.id}_1',
        name: 'Chemise',
        measurementFields: ['Cou', 'Tour De Poitrine', 'Manches', 'Tour De Taille', 'Longueur'],
        dateCreated: DateTime.now(),
      ),
      GarmentType(
        id: '${user.id}_2',
        name: 'Pantalon',
        measurementFields: ['Ceinture', 'Longueur', 'Hanche', 'Cuisse'],
        dateCreated: DateTime.now(),
      ),
      GarmentType(
        id: '${user.id}_3',
        name: 'Veste',
        measurementFields: ['Tour De Poitrine', 'Longueur', 'Épaules', 'Manches'],
        dateCreated: DateTime.now(),
      ),
    ]);

    // Mesures personnalisées par défaut
    _customMeasurements.addAll([
      CustomMeasurement(
        id: '${user.id}_1',
        name: 'Cou',
        unit: 'cm',
        dateCreated: DateTime.now(),
      ),
      CustomMeasurement(
        id: '${user.id}_2',
        name: 'Tour De Poitrine',
        unit: 'cm',
        dateCreated: DateTime.now(),
      ),
      CustomMeasurement(
        id: '${user.id}_3',
        name: 'Manches',
        unit: 'cm',
        dateCreated: DateTime.now(),
      ),
    ]);
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      _currentUser = user;
      _isLoggedIn = true;
      await _saveData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _saveData();
    notifyListeners();
  }

  // Mettre à jour les informations utilisateur
  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      
      // Si c'est l'utilisateur courant, mettre à jour aussi
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      
      _saveData();
      notifyListeners();
    }
  }

  // Gestion des clients
  void addClient(Client client) {
    final userSpecificClient = Client(
      id: _generateUserSpecificId(client.id),
      nom: client.nom,
      prenom: client.prenom,
      adresse: client.adresse,
      telephone: client.telephone,
      imagePath: client.imagePath,
      dateCreation: client.dateCreation,
    );
    
    _clients.add(userSpecificClient);
    _saveData();
    notifyListeners();
  }

  void updateClient(Client updatedClient) {
    final index = _clients.indexWhere((client) => client.id == updatedClient.id && _isUserData(client.id));
    if (index != -1) {
      _clients[index] = updatedClient;
      _saveData();
      notifyListeners();
    }
  }

  void deleteClient(String clientId) {
    if (!_isUserData(clientId)) return;
    
    final clientMeasurements = getMeasurementsByClient(clientId);
    for (final measurement in clientMeasurements) {
      if (measurement.fabricImagePaths.isNotEmpty) {
        ImageService.deleteImages(measurement.fabricImagePaths);
      }
    }
    
    _clients.removeWhere((client) => client.id == clientId && _isUserData(client.id));
    _measurements.removeWhere((measurement) => measurement.clientId == clientId && _isUserData(measurement.clientId));
    _saveData();
    notifyListeners();
  }

  // Gestion des mesures
  void addMeasurement(Measurement measurement) {
    final userSpecificMeasurement = Measurement(
      id: _generateUserSpecificId(measurement.id),
      clientId: measurement.clientId,
      type: measurement.type,
      valeurs: measurement.valeurs,
      dateCreation: measurement.dateCreation,
      fabricImagePaths: measurement.fabricImagePaths,
    );
    
    _measurements.add(userSpecificMeasurement);
    _saveData();
    notifyListeners();
  }

  List<Measurement> getMeasurementsByClient(String clientId) {
    return _measurements.where((measurement) => 
      measurement.clientId == clientId && _isUserData(measurement.clientId)
    ).toList();
  }

  Map<String, int> getMeasurementDistribution() {
    final distribution = <String, int>{};
    for (final measurement in _measurements) {
      if (_isUserData(measurement.clientId)) {
        distribution[measurement.type] = (distribution[measurement.type] ?? 0) + 1;
      }
    }
    return distribution;
  }

  // Gestion des types de vêtements
  void addGarmentType(GarmentType type) {
    final userSpecificType = GarmentType(
      id: _generateUserSpecificId(type.id),
      name: type.name,
      measurementFields: type.measurementFields,
      dateCreated: type.dateCreated,
    );
    
    _garmentTypes.add(userSpecificType);
    _saveData();
    notifyListeners();
  }

  void updateGarmentType(GarmentType updatedType) {
    final index = _garmentTypes.indexWhere((type) => type.id == updatedType.id && _isUserData(type.id));
    if (index != -1) {
      _garmentTypes[index] = updatedType;
      _saveData();
      notifyListeners();
    }
  }

  void deleteGarmentType(String typeId) {
    if (!_isUserData(typeId)) return;
    _garmentTypes.removeWhere((type) => type.id == typeId && _isUserData(type.id));
    _saveData();
    notifyListeners();
  }

  // Gestion des mesures personnalisées
  void addCustomMeasurement(CustomMeasurement measurement) {
    final userSpecificMeasurement = CustomMeasurement(
      id: _generateUserSpecificId(measurement.id),
      name: measurement.name,
      unit: measurement.unit,
      dateCreated: measurement.dateCreated,
    );
    
    _customMeasurements.add(userSpecificMeasurement);
    _saveData();
    notifyListeners();
  }

  void updateCustomMeasurement(CustomMeasurement updatedMeasurement) {
    final index = _customMeasurements.indexWhere((measure) => 
      measure.id == updatedMeasurement.id && _isUserData(measure.id)
    );
    if (index != -1) {
      _customMeasurements[index] = updatedMeasurement;
      _saveData();
      notifyListeners();
    }
  }

  void deleteCustomMeasurement(String measurementId) {
    if (!_isUserData(measurementId)) return;
    _customMeasurements.removeWhere((measure) => 
      measure.id == measurementId && _isUserData(measure.id)
    );
    _saveData();
    notifyListeners();
  }

  // Supprimer le compte utilisateur
  Future<bool> deleteUserAccount(String userId) async {
    try {
      // Supprimer toutes les données de l'utilisateur
      _clients.removeWhere((client) => _isUserData(client.id));
      _measurements.removeWhere((measurement) => _isUserData(measurement.clientId));
      _garmentTypes.removeWhere((type) => _isUserData(type.id));
      _customMeasurements.removeWhere((measure) => _isUserData(measure.id));
      
      // Supprimer l'utilisateur
      _users.removeWhere((user) => user.id == userId);
      
      // Déconnecter si c'est l'utilisateur courant
      if (_currentUser?.id == userId) {
        await logout();
      }
      
      await _saveData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}