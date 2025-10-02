import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    
    return false;
  }

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

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}