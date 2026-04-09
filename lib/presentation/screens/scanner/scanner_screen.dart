// lib/presentation/screens/scanner/scanner_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_provider.dart';
import '../result/result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isLiveMode = false;
  String _liveText = '';
  bool _isTorchOn = false;
  final _picker = ImagePicker();
  TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      if (_isLiveMode) { try { _controller?.stopImageStream(); } catch (_) {} }
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;
      _controller = CameraController(_cameras!.first, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) { debugPrint('摄像头初始化失败: $e'); }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isLiveMode) { try { _controller?.stopImageStream(); } catch (_) {} }
    _controller?.dispose();
    _recognizer.close();
    super.dispose();
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final xFile = await _controller!.takePicture();
      if (!mounted) return;
      final provider = context.read<AppProvider>();
      await provider.recognizeFromPath(xFile.path);
      if (!mounted) return;
      if (provider.status == AppStatus.success) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xFile == null || !mounted) return;
    final provider = context.read<AppProvider>();
    await provider.recognizeFromPath(xFile.path);
    if (!mounted) return;
    if (provider.status == AppStatus.success) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
    }
  }

  void _startLiveRecognition() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isLiveMode = true);
    _controller!.startImageStream(_processFrame);
  }

  void _stopLiveRecognition() {
    try { _controller?.stopImageStream(); } catch (_) {}
    setState(() { _isLiveMode = false; _liveText = ''; });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final wb = WriteBuffer();
      for (final plane in image.planes) { wb.putUint8List(plane.bytes); }
      final bytes = wb.done().buffer.asUint8List();
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv_420_888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
      final result = await _recognizer.processImage(inputImage);
      if (mounted) setState(() => _liveText = result.text);
    } catch (_) {}
    _isProcessing = false;
  }

  void _switchLanguage(String lang) {
    _recognizer.close();
    TextRecognitionScript script;
    switch (lang) {
      case 'ja': script = TextRecognitionScript.japanese; break;
      case 'ko': script = TextRecognitionScript.korean; break;
      case 'latin': script = TextRecognitionScript.latin; break;
      default: script = TextRecognitionScript.chinese;
    }
    _recognizer = TextRecognizer(script: script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('扫描识别', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isInitialized)
            IconButton(
              onPressed: () async {
                await _controller!.setFlashMode(_isTorchOn ? FlashMode.off : FlashMode.torch);
                setState(() => _isTorchOn = !_isTorchOn);
              },
              icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isTorchOn ? Colors.yellow : Colors.white),
            ),
          PopupMenuButton<String>(
            color: AppTheme.darkCard,
            icon: const Icon(Icons.translate, color: Colors.white),
            onSelected: _switchLanguage,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'zh', child: Text('🇨🇳 中文', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'en', child: Text('🇺🇸 English', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'ja', child: Text('🇯🇵 日本語', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'ko', child: Text('🇰🇷 한국어', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'latin', child: Text('🌐 Latin', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: AppTheme.primaryColor),
        SizedBox(height: 20),
        Text('正在初始化摄像头...', style: TextStyle(color: Colors.white70)),
      ]));
    }
    return Stack(fit: StackFit.expand, children: [
      CameraPreview(_controller!),
      CustomPaint(painter: _ScanOverlayPainter()),
      if (_isLiveMode && _liveText.isNotEmpty)
        Positioned(left: 0, right: 0, bottom: 160,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.5)),
            ),
            child: Text(_liveText, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5), maxLines: 5, overflow: TextOverflow.ellipsis),
          ),
        ),
      Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
      if (_isProcessing && !_isLiveMode)
        Container(
          color: Colors.black54,
          child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text('识别中...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ])),
        ),
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.9), Colors.transparent], stops: const [0.6, 1.0]),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _CircleBtn(icon: Icons.photo_library_outlined, label: '相册', onTap: _pickFromGallery),
        GestureDetector(
          onTap: _captureAndRecognize,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white,
              border: Border.all(color: Colors.white38, width: 3),
              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
            ),
            child: const Icon(Icons.camera_alt_rounded, color: AppTheme.darkBg, size: 32),
          ),
        ),
        _CircleBtn(
          icon: _isLiveMode ? Icons.stop_circle_outlined : Icons.play_circle_outline,
          label: _isLiveMode ? '停止' : '实时',
          onTap: _isLiveMode ? _stopLiveRecognition : _startLiveRecognition,
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
  const _CircleBtn({required this.icon, required this.label, required this.onTap, this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2), border: Border.all(color: Colors.white30)),
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
    final bg = Paint()..color = Colors.black.withOpacity(0.45);
    final clear = Paint()..blendMode = BlendMode.clear;
    final border = Paint()..color = AppTheme.primaryColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final corner = Paint()..color = AppTheme.primaryColor..style = PaintingStyle.stroke..strokeWidth = 4.0..strokeCap = StrokeCap.round;
    final w = size.width; final h = size.height;
    const frameW = 280.0; const frameH = 180.0;
    final left = (w - frameW) / 2; final top = (h - frameH) / 2 - 40;
    final rect = Rect.fromLTWH(left, top, frameW, frameH);
    const r = 12.0; const cLen = 26.0;
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(r)), clear);
    canvas.restore();
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(r)), border);
    void dc(Offset a, Offset b, Offset c) {
      canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy), corner);
    }
    dc(Offset(left, top + cLen), Offset(left, top), Offset(left + cLen, top));
    dc(Offset(left + frameW - cLen, top), Offset(left + frameW, top), Offset(left + frameW, top + cLen));
    dc(Offset(left + frameW, top + frameH - cLen), Offset(left + frameW, top + frameH), Offset(left + frameW - cLen, top + frameH));
    dc(Offset(left + cLen, top + frameH), Offset(left, top + frameH), Offset(left, top + frameH - cLen));
  }
  @override
  bool shouldRepaint(_) => false;
}
