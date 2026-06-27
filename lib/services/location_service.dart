import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mengambil posisi saat ini
  // Mengembalikan Position jika berhasil, null jika gagal
  static Future<Position?> getCurrentPosition() async {
    // 1. Cek apakah layanan lokasi aktif
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi (GPS) tidak aktif. Aktifkan GPS di pengaturan.');
    }

    // 2. Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Belum pernah diminta, minta sekarang
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User menolak secara permanen, arahkan ke pengaturan
      return Future.error(
        'Izin lokasi ditolak permanen. Aktifkan di Pengaturan > Aplikasi.',
      );
    }

    // 3. Ambil posisi dengan akurasi tinggi
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return position;
    } catch (e) {
      return Future.error('Gagal mendapatkan lokasi: $e');
    }
  }

  // Stream lokasi yang terus diperbarui
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update tiap 5 meter bergerak
      ),
    );
  }

  // Menghitung jarak antara dua titik (dalam meter)
  static double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  // Format koordinat jadi string yang mudah dibaca
  static String formatCoordinate(double value, {int decimals = 6}) {
    return value.toStringAsFixed(decimals);
  }
}