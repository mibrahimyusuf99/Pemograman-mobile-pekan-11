import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPanel extends StatefulWidget {
  const CameraPanel({super.key});

  @override
  State<CameraPanel> createState() => _CameraPanelState();
}

class _CameraPanelState extends State<CameraPanel> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  String _errorMessage = '';
  int _selectedCameraIndex = 0;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndInitCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_selectedCameraIndex);
    }
  }

  Future<void> _checkAndInitCamera() async {
    setState(() => _isLoading = true);

    // Minta izin kamera langsung via permission_handler
    final status = await Permission.camera.request();
    final granted = status == PermissionStatus.granted;

    if (!granted) {
      if (mounted) {
        setState(() {
          _permissionGranted = false;
          _errorMessage =
              'Izin kamera ditolak. Aktifkan izin kamera di Pengaturan.';
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _permissionGranted = true);

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Tidak ada kamera yang tersedia di perangkat ini.';
            _isLoading = false;
          });
        }
        return;
      }
      await _initCamera(_selectedCameraIndex);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengakses kamera: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initCamera(int index) async {
    final oldController = _controller;
    if (oldController != null) {
      await oldController.dispose();
      _controller = null;
    }

    if (_cameras.isEmpty || index >= _cameras.length) return;

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _errorMessage = '';
          _selectedCameraIndex = index;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menginisialisasi kamera: $e';
          _isLoading = false;
          _isInitialized = false;
        });
      }
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _isInitialized = false;
      _isLoading = true;
    });
    _initCamera(nextIndex);
  }

  String _getCameraLabel(CameraDescription cam) {
    switch (cam.lensDirection) {
      case CameraLensDirection.back:
        return 'Kamera Belakang';
      case CameraLensDirection.front:
        return 'Kamera Depan';
      case CameraLensDirection.external:
        return 'Kamera Eksternal';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
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
                  Icons.camera_alt,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Camera Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
                  child: Text(
                    _permissionGranted ? 'Diizinkan' : 'Ditolak',
                    style: TextStyle(
                      fontSize: 11,
                      color: _permissionGranted ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Area preview kamera
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 220,
                color: Colors.black87,
                child: _buildCameraPreview(),
              ),
            ),

            const SizedBox(height: 10),

            if (_isInitialized && _cameras.isNotEmpty)
              Text(
                'Aktif: ${_getCameraLabel(_cameras[_selectedCameraIndex])}  | Resolusi: Medium',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

            if (_cameras.length > 1 && _permissionGranted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.flip_camera_android, size: 18),
                  label: const Text('Ganti Kamera'),
                  onPressed: _isLoading ? null : _switchCamera,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                  onPressed: _checkAndInitCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Memuat kamera...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white38,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitialized && _controller != null) {
      return CameraPreview(_controller!);
    }

    return const Center(
      child: Text(
        'Kamera belum dimulai',
        style: TextStyle(color: Colors.white54, fontSize: 13),
      ),
    );
  }
}
