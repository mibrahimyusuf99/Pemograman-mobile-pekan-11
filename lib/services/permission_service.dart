import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Minta izin lokasi (GPS)
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted;
  }

  // Minta izin kamera
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  // Cek status izin lokasi tanpa request
  static Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.locationWhenInUse.status;
  }

  // Cek status izin kamera tanpa request
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  // Buka pengaturan app jika user sudah menolak permanen
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  // Helper: apakah status = granted?
  static bool isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted;
  }

  // Mendapatkan deskripsi status permission dalam Bahasa Indonesia
  static String describeStatus(PermissionStatus status) {
    if (status == PermissionStatus.granted) return 'Diizinkan';
    if (status == PermissionStatus.denied) return 'Ditolak';
    if (status == PermissionStatus.permanentlyDenied)
      return 'Ditolak permanen (buka Pengaturan)';
    if (status == PermissionStatus.restricted) return 'Dibatasi sistem';
    if (status == PermissionStatus.limited) return 'Terbatas';
    return 'Tidak diketahui';
  }
}
