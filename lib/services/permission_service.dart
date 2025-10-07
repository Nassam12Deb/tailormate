import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Demander la permission de la caméra
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Demander la permission de la galerie
  static Future<bool> requestGalleryPermission() async {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    
    // Pour Android, utiliser storage
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    
    return false;
  }

  // Vérifier toutes les permissions nécessaires
  static Future<Map<String, bool>> checkAllPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;

    return {
      'camera': cameraStatus.isGranted,
      'storage': storageStatus.isGranted,
      'photos': photosStatus.isGranted,
    };
  }

  // Ouvrir les paramètres de l'application
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}