import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';

class LocationPanel extends StatefulWidget {
  const LocationPanel({super.key});

  @override
  State<LocationPanel> createState() => _LocationPanelState();
}

class _LocationPanelState extends State<LocationPanel> {
  Position? _position;
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastUpdate = '-';
  String _permissionStatus = 'Belum dicek';
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  // Hanya cek status permission, tidak meminta
  Future<void> _checkPermissionStatus() async {
    final status = await PermissionService.checkLocationPermission();
    if (mounted) {
      setState(() {
        _permissionStatus = PermissionService.describeStatus(status);
        _permissionGranted = PermissionService.isGranted(status);
      });
    }
  }

  // Minta izin lalu ambil lokasi
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _position = position;
          _lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());
          _permissionGranted = true;
          _permissionStatus = 'Diizinkan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _permissionGranted = false;
        });
        await _checkPermissionStatus();
      }
    }
  }

  // Buka pengaturan jika ditolak permanen
  Future<void> _openSettings() async {
    await PermissionService.openSettings();
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFC62828),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'GPS Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Indikator status permission
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _permissionGranted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _permissionGranted ? Colors.green : Colors.red,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _permissionGranted ? Icons.check_circle : Icons.cancel,
                        size: 12,
                        color: _permissionGranted ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _permissionStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: _permissionGranted ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // Tampilan data lokasi
            if (_position != null) ...[
              _buildInfoRow(
                Icons.my_location,
                'Latitude',
                LocationService.formatCoordinate(_position!.latitude),
                Colors.blue,
              ),
              _buildInfoRow(
                Icons.explore,
                'Longitude',
                LocationService.formatCoordinate(_position!.longitude),
                Colors.blue,
              ),
              _buildInfoRow(
                Icons.height,
                'Altitude',
                '${_position!.altitude.toStringAsFixed(1)} m',
                Colors.green,
              ),
              _buildInfoRow(
                Icons.speed,
                'Kecepatan',
                '${_position!.speed.toStringAsFixed(2)} m/s',
                Colors.orange,
              ),
              _buildInfoRow(
                Icons.gps_fixed,
                'Akurasi',
                '±${_position!.accuracy.toStringAsFixed(1)} m',
                Colors.purple,
              ),
            ] else if (_errorMessage.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Tekan tombol di bawah untuk mendapatkan lokasi',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],

            // Pesan error
            if (_errorMessage.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol buka pengaturan jika ditolak permanen
              if (_errorMessage.contains('permanen'))
                TextButton.icon(
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text(
                    'Buka Pengaturan',
                    style: TextStyle(fontSize: 13),
                  ),
                  onPressed: _openSettings,
                ),
            ],

            const SizedBox(height: 8),

            // Timestamp
            if (_lastUpdate != '-')
              Text(
                'Diperbarui: $_lastUpdate',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

            const SizedBox(height: 10),

            // Tombol refresh
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(
                  _isLoading ? 'Mencari lokasi...' : 'Refresh Lokasi',
                ),
                onPressed: _isLoading ? null : _getLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
