import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';
import '../models/client.dart';
import '../models/measurement.dart';
import '../models/garment_type.dart';
import '../models/custom_measurement.dart';

class DataService with ChangeNotifier {
  List<Client> _clients = [];
  List<Measurement> _measurements = [];
  List<GarmentType> _garmentTypes = [];
  List<CustomMeasurement> _customMeasurements = [];
  bool _isLoading = false;

  List<Client> get clients => _clients;
  List<Measurement> get measurements => _measurements;
  List<GarmentType> get garmentTypes => _garmentTypes;
  List<CustomMeasurement> get customMeasurements => _customMeasurements;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => FirebaseService.isLoggedIn;

  DataService() {
    if (isLoggedIn) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!isLoggedIn) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadClients(),
        _loadMeasurements(),
        _loadGarmentTypes(),
        _loadCustomMeasurements(),
      ]);
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClients() async {
    final snapshot = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('clients')
        .orderBy('dateCreation', descending: true)
        .get();

    _clients = snapshot.docs.map((doc) {
      final data = doc.data();
      return Client(
        id: doc.id,
        nom: data['nom'],
        prenom: data['prenom'],
        adresse: data['adresse'],
        telephone: data['telephone'],
        imagePath: data['imagePath'],
        dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> _loadMeasurements() async {
    final snapshot = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('measurements')
        .orderBy('dateCreation', descending: true)
        .get();

    _measurements = snapshot.docs.map((doc) {
      final data = doc.data();
      return Measurement(
        id: doc.id,
        clientId: data['clientId'],
        type: data['type'],
        valeurs: Map<String, double>.from(data['valeurs']),
        dateCreation: (data['dateCreation'] as Timestamp).toDate(),
        fabricImagePaths: List<String>.from(data['fabricImagePaths'] ?? []),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> _loadGarmentTypes() async {
    final snapshot = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('garmentTypes')
        .orderBy('dateCreated', descending: true)
        .get();

    _garmentTypes = snapshot.docs.map((doc) {
      final data = doc.data();
      return GarmentType(
        id: doc.id,
        name: data['name'],
        measurementFields: List<String>.from(data['measurementFields']),
        dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      );
    }).toList();

    if (_garmentTypes.isEmpty) {
      await _initializeDefaultGarmentTypes();
    }

    notifyListeners();
  }

  Future<void> _loadCustomMeasurements() async {
    final snapshot = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('customMeasurements')
        .orderBy('dateCreated', descending: true)
        .get();

    _customMeasurements = snapshot.docs.map((doc) {
      final data = doc.data();
      return CustomMeasurement(
        id: doc.id,
        name: data['name'],
        unit: data['unit'],
        dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> _initializeDefaultGarmentTypes() async {
    final defaultTypes = [
      {
        'name': 'Chemise',
        'measurementFields': ['Cou', 'Tour De Poitrine', 'Manches', 'Tour De Taille', 'Longueur'],
        'dateCreated': Timestamp.now(),
      },
      {
        'name': 'Pantalon',
        'measurementFields': ['Ceinture', 'Longueur', 'Hanche', 'Cuisse'],
        'dateCreated': Timestamp.now(),
      },
      {
        'name': 'Veste',
        'measurementFields': ['Tour De Poitrine', 'Longueur', 'Épaules', 'Manches'],
        'dateCreated': Timestamp.now(),
      },
    ];

    final batch = FirebaseService.firestore.batch();
    final userRef = FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('garmentTypes');

    for (final typeData in defaultTypes) {
      final docRef = userRef.doc();
      batch.set(docRef, typeData);
    }

    await batch.commit();
    await _loadGarmentTypes();
  }

  // Gestion des clients
  Future<void> addClient(Client client) async {
    final docRef = FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('clients')
        .doc();

    await docRef.set({
      'nom': client.nom,
      'prenom': client.prenom,
      'adresse': client.adresse,
      'telephone': client.telephone,
      'imagePath': client.imagePath,
      'dateCreation': Timestamp.fromDate(client.dateCreation),
    });

    await _loadClients();
  }

  Future<void> updateClient(Client updatedClient) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('clients')
        .doc(updatedClient.id)
        .update({
      'nom': updatedClient.nom,
      'prenom': updatedClient.prenom,
      'adresse': updatedClient.adresse,
      'telephone': updatedClient.telephone,
      'imagePath': updatedClient.imagePath,
    });

    await _loadClients();
  }

  Future<void> deleteClient(String clientId) async {
    // Supprimer les mesures associées
    final measurementsSnapshot = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('measurements')
        .where('clientId', isEqualTo: clientId)
        .get();

    final batch = FirebaseService.firestore.batch();
    
    // Supprimer les images des mesures
    for (final doc in measurementsSnapshot.docs) {
      final measurement = Measurement.fromJson(doc.data());
      if (measurement.fabricImagePaths.isNotEmpty) {
        for (final imagePath in measurement.fabricImagePaths) {
          try {
            await FirebaseService.storage.refFromURL(imagePath).delete();
          } catch (e) {
            print('Erreur suppression image: $e');
          }
        }
      }
      batch.delete(doc.reference);
    }

    // Supprimer le client
    batch.delete(
      FirebaseService.firestore
          .collection('users')
          .doc(FirebaseService.currentUserId)
          .collection('clients')
          .doc(clientId),
    );

    await batch.commit();
    await _loadClients();
    await _loadMeasurements();
  }

  // Gestion des mesures
  Future<void> addMeasurement(Measurement measurement) async {
    final docRef = FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('measurements')
        .doc();

    // Upload des images vers Firebase Storage si nécessaire
    final uploadedImagePaths = <String>[];
    for (final localPath in measurement.fabricImagePaths) {
      try {
        final file = File(localPath);
        final fileName = 'fabric_${DateTime.now().millisecondsSinceEpoch}_${uploadedImagePaths.length}.jpg';
        final ref = FirebaseService.storage
            .ref()
            .child('users/${FirebaseService.currentUserId}/fabrics/$fileName');
        
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        uploadedImagePaths.add(downloadUrl);
        
        // Supprimer le fichier local
        await file.delete();
      } catch (e) {
        print('Erreur upload image: $e');
        uploadedImagePaths.add(localPath);
      }
    }

    await docRef.set({
      'clientId': measurement.clientId,
      'type': measurement.type,
      'valeurs': measurement.valeurs,
      'fabricImagePaths': uploadedImagePaths,
      'dateCreation': Timestamp.fromDate(measurement.dateCreation),
    });

    await _loadMeasurements();
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
  Future<void> addGarmentType(GarmentType type) async {
    final docRef = FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('garmentTypes')
        .doc();

    await docRef.set({
      'name': type.name,
      'measurementFields': type.measurementFields,
      'dateCreated': Timestamp.fromDate(type.dateCreated),
    });

    await _loadGarmentTypes();
  }

  Future<void> updateGarmentType(GarmentType updatedType) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('garmentTypes')
        .doc(updatedType.id)
        .update({
      'name': updatedType.name,
      'measurementFields': updatedType.measurementFields,
    });

    await _loadGarmentTypes();
  }

  Future<void> deleteGarmentType(String typeId) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('garmentTypes')
        .doc(typeId)
        .delete();

    await _loadGarmentTypes();
  }

  // Gestion des mesures personnalisées
  Future<void> addCustomMeasurement(CustomMeasurement measurement) async {
    final docRef = FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('customMeasurements')
        .doc();

    await docRef.set({
      'name': measurement.name,
      'unit': measurement.unit,
      'dateCreated': Timestamp.fromDate(measurement.dateCreated),
    });

    await _loadCustomMeasurements();
  }

  Future<void> updateCustomMeasurement(CustomMeasurement updatedMeasurement) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('customMeasurements')
        .doc(updatedMeasurement.id)
        .update({
      'name': updatedMeasurement.name,
      'unit': updatedMeasurement.unit,
    });

    await _loadCustomMeasurements();
  }

  Future<void> deleteCustomMeasurement(String measurementId) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.currentUserId)
        .collection('customMeasurements')
        .doc(measurementId)
        .delete();

    await _loadCustomMeasurements();
  }

  // Authentification
  Future<bool> login(String email, String password) async {
    try {
      setState(() => _isLoading = true);
      
      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (FirebaseService.isLoggedIn) {
        await _loadData();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('Erreur connexion: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Erreur inattendue: $e');
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> register(String email, String password, String nom, String prenom, String telephone) async {
    try {
      setState(() => _isLoading = true);
      
      final userCredential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Sauvegarder les informations supplémentaires dans Firestore
        await FirebaseService.firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email.trim(),
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'dateInscription': Timestamp.now(),
        });

        await _loadData();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('Erreur inscription: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Erreur inattendue: $e');
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> logout() async {
    await FirebaseService.signOut();
    _clearLocalData();
    notifyListeners();
  }

  void _clearLocalData() {
    _clients.clear();
    _measurements.clear();
    _garmentTypes.clear();
    _customMeasurements.clear();
  }

  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}