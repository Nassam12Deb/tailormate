import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static late FirebaseApp app;
  static late FirebaseAuth auth;
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;

  static Future<void> initialize() async {
    app = await Firebase.initializeApp();
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
  }

  static String get currentUserId => auth.currentUser?.uid ?? '';

  static bool get isLoggedIn => auth.currentUser != null;

  static Future<void> signOut() async {
    await auth.signOut();
  }
}