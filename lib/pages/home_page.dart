import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/accelerometer_panel.dart';
import '../widgets/gyroscope_panel.dart';
import '../widgets/location_panel.dart' show LocationPanel;
import '../widgets/camera_panel.dart' show CameraPanel;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  final String _buildDate = DateFormat('dd MMM yyyy').format(DateTime.now());

  final List<String> _tabs = ['Semua', 'Gerak', 'Lokasi', 'Kamera'];
  final List<IconData> _tabIcons = [
    Icons.dashboard,
    Icons.sensors,
    Icons.location_on,
    Icons.camera_alt,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text(
          'Sensor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF1565C0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = _selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _tabIcons[i],
                            size: 16,
                            color: isSelected ? Colors.white : Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _tabs[i],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(children: [_buildInfoBanner(), ..._buildPanels()]),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data sensor diperbarui secara real-time. '
              'Pastikan izin GPS dan kamera sudah diberikan.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // PENTING: tidak pakai const karena widget bersifat stateful (punya initState)
  List<Widget> _buildPanels() {
    switch (_selectedTab) {
      case 0:
        return [
          const AccelerometerPanel(),
          const GyroscopePanel(),
          const LocationPanel(),
          const CameraPanel(),
        ];
      case 1:
        return [const AccelerometerPanel(), const GyroscopePanel()];
      case 2:
        return [const LocationPanel()];
      case 3:
        return [const CameraPanel()];
      default:
        return [];
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Sensor Dashboard App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tugas Praktikum pekan 11'),
            const SizedBox(height: 4),
            const Text('Pemrograman Mobile Android'),
            const Text('D3 Teknik Komputer - UNIKOM'),
            const Text('Muhammad Ibrahim Yusuf - 10824006'),
            const Divider(height: 20),
            _aboutRow(Icons.vibration, 'Accelerometer', 'sensors_plus'),
            _aboutRow(Icons.rotate_90_degrees_ccw, 'Gyroscope', 'sensors_plus'),
            _aboutRow(Icons.location_on, 'GPS', 'geolocator'),
            _aboutRow(Icons.camera_alt, 'Kamera', 'camera'),
            const Divider(height: 20),
            Text(
              'Build: $_buildDate',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(IconData icon, String name, String package) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            package,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
