import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/measurement.dart';
import '../models/garment_type.dart';
import '../models/custom_measurement.dart';
import 'image_service.dart'; // IMPORT AJOUTÉ

class DataService with ChangeNotifier {
  List<Client> _clients = [];
  List<Measurement> _measurements = [];
  List<GarmentType> _garmentTypes = [];
  List<CustomMeasurement> _customMeasurements = [];
  bool _isLoggedIn = false;

  List<Client> get clients => _clients;
  List<Measurement> get measurements => _measurements;
  List<GarmentType> get garmentTypes => _garmentTypes;
  List<CustomMeasurement> get customMeasurements => _customMeasurements;
  bool get isLoggedIn => _isLoggedIn;

  DataService() {
    _loadData();
    _initializeDefaultData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
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
    
    notifyListeners();
  }

  void _initializeDefaultData() {
    if (_garmentTypes.isEmpty) {
      _garmentTypes.addAll([
        GarmentType(
          id: '1',
          name: 'Chemise',
          measurementFields: ['Cou', 'Tour De Poitrine', 'Manches', 'Tour De Taille', 'Longueur'],
          dateCreated: DateTime.now(),
        ),
        GarmentType(
          id: '2',
          name: 'Pantalon',
          measurementFields: ['Ceinture', 'Longueur', 'Hanche', 'Cuisse'],
          dateCreated: DateTime.now(),
        ),
        GarmentType(
          id: '3',
          name: 'Veste',
          measurementFields: ['Tour De Poitrine', 'Longueur', 'Épaules', 'Manches'],
          dateCreated: DateTime.now(),
        ),
      ]);
    }

    if (_customMeasurements.isEmpty) {
      _customMeasurements.addAll([
        CustomMeasurement(
          id: '1',
          name: 'Cou',
          unit: 'cm',
          dateCreated: DateTime.now(),
        ),
        CustomMeasurement(
          id: '2',
          name: 'Tour De Poitrine',
          unit: 'cm',
          dateCreated: DateTime.now(),
        ),
        CustomMeasurement(
          id: '3',
          name: 'Manches',
          unit: 'cm',
          dateCreated: DateTime.now(),
        ),
      ]);
    }
    _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
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
  }

  // Gestion des clients
  void addClient(Client client) {
    _clients.add(client);
    _saveData();
    notifyListeners();
  }

  void updateClient(Client updatedClient) {
    final index = _clients.indexWhere((client) => client.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      _saveData();
      notifyListeners();
    }
  }

  void deleteClient(String clientId) {
    // Supprimer les images des mesures avant de supprimer le client
    final clientMeasurements = getMeasurementsByClient(clientId);
    for (final measurement in clientMeasurements) {
      if (measurement.fabricImagePaths.isNotEmpty) {
        ImageService.deleteImages(measurement.fabricImagePaths);
      }
    }
    
    _clients.removeWhere((client) => client.id == clientId);
    _measurements.removeWhere((measurement) => measurement.clientId == clientId);
    _saveData();
    notifyListeners();
  }

  // Gestion des mesures
  void addMeasurement(Measurement measurement) {
    _measurements.add(measurement);
    _saveData();
    notifyListeners();
  }

  List<Measurement> getMeasurementsByClient(String clientId) {
    return _measurements.where((measurement) => measurement.clientId == clientId).toList();
  }

  Map<String, int> getMeasurementDistribution() {
    final distribution = <String, int>{};
    for (final measurement in _measurements) {
      distribution[measurement.type] = (distribution[measurement.type] ?? 0) + 1;
    }
    return distribution;
  }

  // Gestion des types de vêtements
  void addGarmentType(GarmentType type) {
    _garmentTypes.add(type);
    _saveData();
    notifyListeners();
  }

  void updateGarmentType(GarmentType updatedType) {
    final index = _garmentTypes.indexWhere((type) => type.id == updatedType.id);
    if (index != -1) {
      _garmentTypes[index] = updatedType;
      _saveData();
      notifyListeners();
    }
  }

  void deleteGarmentType(String typeId) {
    _garmentTypes.removeWhere((type) => type.id == typeId);
    _saveData();
    notifyListeners();
  }

  // Gestion des mesures personnalisées
  void addCustomMeasurement(CustomMeasurement measurement) {
    _customMeasurements.add(measurement);
    _saveData();
    notifyListeners();
  }

  void updateCustomMeasurement(CustomMeasurement updatedMeasurement) {
    final index = _customMeasurements.indexWhere((measure) => measure.id == updatedMeasurement.id);
    if (index != -1) {
      _customMeasurements[index] = updatedMeasurement;
      _saveData();
      notifyListeners();
    }
  }

  void deleteCustomMeasurement(String measurementId) {
    _customMeasurements.removeWhere((measure) => measure.id == measurementId);
    _saveData();
    notifyListeners();
  }

  // Authentification
  Future<bool> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }
}