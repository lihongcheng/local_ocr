// lib/presentation/screens/processing/processing_screen.dart
//
// 正在识别页：显示识别进度动画，完成后自动跳转结果页
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_provider.dart';
import '../result/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final bool isFromCamera;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    this.isFromCamera = false,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startRecognition();
  }

  Future<void> _startRecognition() async {
    final provider = context.read<AppProvider>();

    // 确保模型就绪
    if (!provider.isModelReady) {
      await provider.initOcr();
      if (!provider.isModelReady) {
        if (mounted) {
          _showErrorAndPop('OCR model not ready. Check internet connection.');
        }
        return;
      }
    }

    // 执行识别
    await provider.recognizeFromPath(widget.imagePath);

    if (!mounted) return;

    // 根据结果跳转
    if (provider.status == AppStatus.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    } else if (provider.errorMessage.isNotEmpty) {
      _showErrorAndPop(provider.errorMessage);
    }
  }

  void _showErrorAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图片预览
            if (File(widget.imagePath).existsSync())
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 400.ms,
                  ),

            const SizedBox(height: 32),

            // 识别动画
            _buildProcessingIndicator(provider.status),

            const SizedBox(height: 24),

            // 状态文本
            _buildStatusText(provider.status),

            const SizedBox(height: 12),

            // 引擎信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.offline_bolt_outlined,
                      color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'PP-OCRv5 · Local processing',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(AppStatus status) {
    if (status == AppStatus.preparingModel) {
      // 模型准备中
      return Column(
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              color: AppTheme.warningColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Preparing model…',
              style: TextStyle(color: AppTheme.warningColor, fontSize: 12),
            ),
          ),
        ],
      );
    }

    // 正在识别
    return SizedBox(
      width: 56,
      height: 56,
      child: CircularProgressIndicator(
        color: AppTheme.primaryColor,
        strokeWidth: 3,
      ),
    ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms);
  }

  Widget _buildStatusText(AppStatus status) {
    String text;
    Color color;

    if (status == AppStatus.preparingModel) {
      text = 'Downloading OCR model…';
      color = AppTheme.warningColor;
    } else {
      text = 'Recognizing text…';
      color = Colors.white;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}