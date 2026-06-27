import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:intl/intl.dart';

class GyroscopePanel extends StatefulWidget {
  const GyroscopePanel({super.key});

  @override
  State<GyroscopePanel> createState() => _GyroscopePanelState();
}

class _GyroscopePanelState extends State<GyroscopePanel> {
  GyroscopeEvent? _gyro;
  StreamSubscription<GyroscopeEvent>? _sub;
  String _lastUpdate = '-';
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _sub = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 200),
    ).listen((GyroscopeEvent event) {
      if (!_isPaused) {
        setState(() {
          _gyro = event;
          _lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void dispose() {
    // WAJIB: batalkan subscription agar tidak memory leak
    _sub?.cancel();
    super.dispose();
  }

  // Menentukan arah rotasi dominan
  String _getRotationStatus() {
    if (_gyro == null) return 'Tidak ada data';
    final x = _gyro!.x.abs();
    final y = _gyro!.y.abs();
    final z = _gyro!.z.abs();
    final max = [x, y, z].reduce((a, b) => a > b ? a : b);

    if (max < 0.1) return 'Stabil (tidak berputar)';
    if (max == x) return 'Rotasi sumbu X (pitch - maju/mundur)';
    if (max == y) return 'Rotasi sumbu Y (roll - kiri/kanan)';
    return 'Rotasi sumbu Z (yaw - berputar)';
  }

  // Konversi rad/s ke deg/s untuk tampilan yang lebih intuitif
  String _toDegPerSec(double? radPerSec) {
    if (radPerSec == null) return '-';
    final deg = radPerSec * (180 / 3.14159265);
    return deg.toStringAsFixed(1);
  }

  Widget _buildAxisRow(String axis, double? value, Color color) {
    final radDisplay = value?.toStringAsFixed(3) ?? '-';
    final degDisplay = _toDegPerSec(value);
    final barValue = value != null ? (value.abs() / 5).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  axis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barValue,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: Text(
                  '$radDisplay rad/s',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              '≈ $degDisplay °/s',
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
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
                const Icon(Icons.rotate_90_degrees_ccw,
                    color: Color(0xFF6A1B9A), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Gyroscope',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  tooltip: _isPaused ? 'Resume' : 'Pause',
                  onPressed: _togglePause,
                  color: const Color(0xFF6A1B9A),
                ),
              ],
            ),
            const Divider(),

            // Baris sumbu
            _buildAxisRow('X', _gyro?.x, Colors.deepOrange),
            _buildAxisRow('Y', _gyro?.y, Colors.teal),
            _buildAxisRow('Z', _gyro?.z, Colors.purple),

            const SizedBox(height: 10),

            // Keterangan rotasi
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getRotationStatus(),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Timestamp
            Text(
              'Diperbarui: $_lastUpdate${_isPaused ? " (Dijeda)" : ""}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}