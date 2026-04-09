// lib/presentation/screens/scanner/scanner_screen.dart
//
// 扫描页：三种模式
//   1. 拍照识别（静态）
//   2. 相册选图（静态）
//   3. 实时识别 Live（逐帧截图 → PP-OCRv5，每秒一帧，防止积压）
//
// 实时识别不使用 startImageStream 的 YUV 转换（之前崩溃根源），
// 改用 takePicture 节流拍照 → JPEG → PP-OCRv5 检测，更稳定可靠。
//
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_provider.dart';
import '../../../services/ocr_service.dart';
import '../result/result_screen.dart';

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
  bool _isLiveMode = false;
  String _liveText = '';
  bool _isTorchOn = false;
  final _picker = ImagePicker();

  // 实时模式：每 1.2 秒拍一张照片进行识别
  Timer? _liveTimer;
  static const _liveInterval = Duration(milliseconds: 1200);

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
      _stopLive();
      ctrl.dispose();
      if (mounted) setState(() { _isInitialized = false; });
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLive();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    // 请求相机权限
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

  // ── 静态拍照识别 ────────────────────────────────────────────────────────

  Future<void> _captureAndRecognize() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_isProcessing) return;
    if (_isLiveMode) { _stopLive(); return; }

    setState(() => _isProcessing = true);
    try {
      final xFile = await ctrl.takePicture();
      if (!mounted) return;
      await _runRecognitionAndNavigate(xFile.path);
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
    await _runRecognitionAndNavigate(xFile.path);
  }

  Future<void> _runRecognitionAndNavigate(String imagePath) async {
    final provider = context.read<AppProvider>();

    // 若模型未就绪，先准备
    if (!provider.isModelReady) {
      await provider.initOcr();
      if (!provider.isModelReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'OCR model not ready. Check internet connection.')));
        }
        return;
      }
    }

    await provider.recognizeFromPath(imagePath);
    if (!mounted) return;
    if (provider.status == AppStatus.success) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ResultScreen()));
    } else if (provider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.errorMessage)));
    }
  }

  // ── 实时识别（定时拍照模式，避免 YUV 崩溃）──────────────────────────────

  void _startLive() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    setState(() { _isLiveMode = true; _liveText = ''; });
    _liveTimer = Timer.periodic(_liveInterval, (_) => _liveCapture());
  }

  void _stopLive() {
    _liveTimer?.cancel();
    _liveTimer = null;
    if (mounted) setState(() { _isLiveMode = false; _liveText = ''; });
  }

  Future<void> _liveCapture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_isProcessing) return;
    if (!_isLiveMode) return;
    _isProcessing = true;
    try {
      final xFile = await ctrl.takePicture();
      final result = await OcrService.instance.recognizeFromFile(xFile.path);
      // 清理临时文件
      try { File(xFile.path).deleteSync(); } catch (_) {}
      if (mounted && _isLiveMode) {
        setState(() => _liveText = result.text.isNotEmpty ? result.text : _liveText);
      }
    } catch (_) {}
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Scanner', style: TextStyle(color: Colors.white)),
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
      CameraPreview(_controller!),
      CustomPaint(painter: _ScanOverlayPainter()),

      // 实时识别结果
      if (_isLiveMode)
        Positioned(
          left: 0, right: 0, bottom: 160,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppTheme.accentColor)),
                  const SizedBox(width: 6),
                  const Text('PP-OCRv5 Live',
                      style: TextStyle(color: AppTheme.accentColor, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                Text(
                  _liveText.isEmpty ? 'Scanning…' : _liveText,
                  style: TextStyle(
                      color: _liveText.isEmpty ? Colors.white38 : Colors.white,
                      fontSize: 14, height: 1.5),
                  maxLines: 6, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

      Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),

      // 识别中遮罩（静态模式）
      if (_isProcessing && !_isLiveMode)
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.92), Colors.transparent],
          stops: const [0.55, 1.0],
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _CircleBtn(
          icon: Icons.photo_library_outlined,
          label: 'Gallery',
          onTap: _pickFromGallery,
        ),
        // 主按钮
        GestureDetector(
          onTap: _captureAndRecognize,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLiveMode ? Colors.white24 : Colors.white,
              border: Border.all(color: Colors.white38, width: 3),
              boxShadow: _isLiveMode ? [] : [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.55),
                    blurRadius: 22, spreadRadius: 3),
              ],
            ),
            child: Icon(Icons.camera_alt_rounded,
                color: _isLiveMode ? Colors.white54 : AppTheme.darkBg,
                size: 32),
          ),
        ),
        _CircleBtn(
          icon: _isLiveMode ? Icons.stop_circle_outlined : Icons.play_circle_outline,
          label: _isLiveMode ? 'Stop' : 'Live',
          onTap: _isLiveMode ? _stopLive : _startLive,
          color: _isLiveMode ? AppTheme.accentColor : Colors.white,
        ),
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
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black.withOpacity(0.4);
    final clear = Paint()..blendMode = BlendMode.clear;
    final border = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final corner = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final w = size.width; final h = size.height;
    const fw = 280.0; const fh = 180.0;
    final l = (w - fw) / 2; final t = (h - fh) / 2 - 40;
    final rect = Rect.fromLTWH(l, t, fw, fh);
    const r = 12.0; const cl = 26.0;

    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(r)), clear);
    canvas.restore();
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(r)), border);

    void dc(Offset a, Offset b, Offset c) =>
        canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy), corner);
    dc(Offset(l, t+cl), Offset(l, t), Offset(l+cl, t));
    dc(Offset(l+fw-cl, t), Offset(l+fw, t), Offset(l+fw, t+cl));
    dc(Offset(l+fw, t+fh-cl), Offset(l+fw, t+fh), Offset(l+fw-cl, t+fh));
    dc(Offset(l+cl, t+fh), Offset(l, t+fh), Offset(l, t+fh-cl));
  }
  @override
  bool shouldRepaint(_) => false;
}
