import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:intl/intl.dart';

class AccelerometerPanel extends StatefulWidget {
  const AccelerometerPanel({super.key});

  @override
  State<AccelerometerPanel> createState() => _AccelerometerPanelState();
}

class _AccelerometerPanelState extends State<AccelerometerPanel> {
  AccelerometerEvent? _accel;
  StreamSubscription<AccelerometerEvent>? _sub;
  String _lastUpdate = '-';
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 200),
    ).listen((AccelerometerEvent event) {
      if (!_isPaused) {
        setState(() {
          _accel = event;
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

  // Menentukan intensitas gerak berdasarkan magnitude
  String _getMotionStatus() {
    if (_accel == null) return 'Tidak ada data';
    final magnitude = (_accel!.x.abs() + _accel!.y.abs() + _accel!.z.abs());
    if (magnitude < 12) return 'Diam';
    if (magnitude < 20) return 'Bergerak pelan';
    return 'Bergerak cepat / Diguncang';
  }

  Color _getMotionColor() {
    if (_accel == null) return Colors.grey;
    final magnitude = (_accel!.x.abs() + _accel!.y.abs() + _accel!.z.abs());
    if (magnitude < 12) return Colors.green;
    if (magnitude < 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAxisRow(String axis, double? value, Color color) {
    final display = value?.toStringAsFixed(2) ?? '-';
    final barValue = value != null ? (value.abs() / 20).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Label sumbu
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
          // Progress bar nilai
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
          // Nilai numerik
          SizedBox(
            width: 70,
            child: Text(
              '$display m/s²',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.right,
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
                const Icon(Icons.vibration, color: Color(0xFF1565C0), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Accelerometer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Tombol pause/resume
                IconButton(
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  tooltip: _isPaused ? 'Resume' : 'Pause',
                  onPressed: _togglePause,
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
            const Divider(),

            // Baris sumbu X, Y, Z
            _buildAxisRow('X', _accel?.x, Colors.red),
            _buildAxisRow('Y', _accel?.y, Colors.green),
            _buildAxisRow('Z', _accel?.z, Colors.blue),

            const SizedBox(height: 10),

            // Status gerak
            Row(
              children: [
                Icon(Icons.circle, color: _getMotionColor(), size: 12),
                const SizedBox(width: 6),
                Text(
                  'Status: ${_getMotionStatus()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _getMotionColor(),
                    fontWeight: FontWeight.w500,
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