// lib/presentation/screens/scanner/scanner_screen.dart
//
// 扫描页：两种模式
//   1. 拍照识别（静态）
//   2. 相册选图（静态）
//
// 已移除实时识别功能。
// 已移除中心矩形扫描框，改为全屏取景，体验更直观。
//
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../processing/processing_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
      if (mounted) setState(() { _isInitialized = false; });
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')));
      }
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final ctrl = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) { ctrl.dispose(); return; }
      _controller = ctrl;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  // ── 拍照识别 ──────────────────────────────────────────────────────────────

  Future<void> _captureAndNavigate() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final xFile = await ctrl.takePicture();
      if (!mounted) return;
      await _navigateToProcessing(xFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 90);
    if (xFile == null || !mounted) return;
    await _navigateToProcessing(xFile.path);
  }

  // 拍照后直接跳转到正在识别页
  Future<void> _navigateToProcessing(String imagePath) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scanner',
            style: TextStyle(color: Colors.white, shadows: [
              Shadow(color: Colors.black54, blurRadius: 8)
            ])),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 手电筒
          if (_isInitialized)
            IconButton(
              onPressed: () async {
                try {
                  await _controller!.setFlashMode(
                      _isTorchOn ? FlashMode.off : FlashMode.torch);
                  setState(() => _isTorchOn = !_isTorchOn);
                } catch (_) {}
              },
              icon: Icon(
                _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isTorchOn ? Colors.yellow : Colors.white,
              ),
            ),
          // 引擎标签
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
            ),
            child: const Text('PP-OCRv5',
                style: TextStyle(color: AppTheme.accentColor, fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized || _controller == null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 20),
          const Text('Initializing camera…',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _initCamera,
            child: const Text('Retry',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ]),
      );
    }

    return Stack(fit: StackFit.expand, children: [
      // 全屏相机预览
      CameraPreview(_controller!),

      // 底部操作栏
      Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),

      // 识别中遮罩
      if (_isProcessing)
        Container(
          color: Colors.black54,
          child: const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text('PP-OCRv5 recognizing…',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              SizedBox(height: 6),
              Text('Local processing',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
        ),
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 44),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
          stops: const [0.6, 1.0],
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        // 相册按钮
        _CircleBtn(
          icon: Icons.photo_library_outlined,
          label: 'Gallery',
          onTap: _pickFromGallery,
        ),
        // 主拍照按钮
        GestureDetector(
          onTap: _captureAndNavigate,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 76, height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isProcessing ? Colors.white30 : Colors.white,
              border: Border.all(color: Colors.white54, width: 3),
              boxShadow: _isProcessing ? [] : [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.55),
                    blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: Icon(Icons.camera_alt_rounded,
                color: _isProcessing ? Colors.white54 : AppTheme.darkBg,
                size: 34),
          ),
        ),
        // 占位（保持三列对称）
        const SizedBox(width: 64),
      ]),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _CircleBtn({required this.icon, required this.label,
      required this.onTap, this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)])),
      ]),
    );
  }
}
