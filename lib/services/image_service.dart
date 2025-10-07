import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'permission_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromCamera() async {
    try {
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        throw Exception('Permission caméra refusée');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        return await _saveImageToAppDirectory(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur caméra: $e');
      return null;
    }
  }

  static Future<String?> pickImageFromGallery() async {
    try {
      final hasPermission = await PermissionService.requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Permission galerie refusée');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        return await _saveImageToAppDirectory(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur galerie: $e');
      return null;
    }
  }

  static Future<String> _saveImageToAppDirectory(String imagePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appPath = appDir.path;
      final String fileName = 'fabric_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '$appPath/$fileName';
      
      final File imageFile = File(imagePath);
      await imageFile.copy(newPath);
      
      return newPath;
    } catch (e) {
      debugPrint('Erreur sauvegarde image: $e');
      return imagePath;
    }
  }

  static Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return true;
    
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Erreur suppression image: $e');
      return false;
    }
  }

  static Future<bool> deleteImages(List<String> imagePaths) async {
    try {
      for (final path in imagePaths) {
        await deleteImage(path);
      }
      return true;
    } catch (e) {
      debugPrint('Erreur suppression images: $e');
      return false;
    }
  }
}