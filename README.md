# Local OCR — PP-OCRv5 Flutter App

完全本地化的 OCR 文字识别应用，Android 端使用百度 **PP-OCRv5**（via ONNX Runtime），iOS 端使用 **Apple Vision**。

## 包名
`cn.inaiworld.local_ocr`

---

## OCR 引擎说明

| 平台 | 引擎 | 模型 | 体积 | 联网要求 |
|------|------|------|------|---------|
| Android | ONNX Runtime + PP-OCRv5 | `mobile_ocr` 插件 | ~20MB（首次下载，缓存后离线） | 仅首次下载 |
| iOS | Apple Vision (系统) | 系统内置 | 0 MB | 永不需要 |

### Android 首次下载说明
- PP-OCRv5 模型（~20MB）托管于 `https://models.ente.io/PP-OCRv5/`
- 首次运行时自动下载并缓存到 `context.filesDir/assets/mobile_ocr/`
- 缓存后永久离线使用，SHA-256 校验保证完整性
- Splash 页面显示下载进度，失败可重试或跳过（识别时再次尝试）

### PP-OCRv5 优势（相比 Google ML Kit）
- 中文识别准确率提升约 13%（官方数据）
- 原生支持简体中文、繁体中文、拼音、英文、日语混合识别
- 手写体识别能力显著增强
- 支持 100+ 语言

---

## 快速开始

```bash
# 1. 安装依赖（包含 mobile_ocr git 依赖）
flutter pub get

# 2. 生成 Isar 代码（已预生成，如需重新生成）
dart run build_runner build --delete-conflicting-outputs

# 3. 运行（首次 Android 运行需联网下载模型）
flutter run

# 4. 构建 Android release APK
flutter build apk --release

# 5. 构建 Android AAB（上传 Play Store）
flutter build appbundle --release

# 6. 构建 iOS（需要 macOS + Xcode）
flutter build ios --release
```

---

## 广告开关

`lib/core/constants/ad_constants.dart`：

```dart
static const bool useTestAds = true;  // ← 发布前改为 false
```

---

## 功能清单

| 功能 | 状态 |
|------|------|
| 拍照识别（PP-OCRv5）| ✅ |
| 相册选图识别 | ✅ |
| 实时摄像头识别（定时截图模式）| ✅ |
| 历史记录（Isar 本地数据库）| ✅ |
| 全文搜索历史 | ✅ |
| 一键复制 | ✅ |
| 分享 | ✅ |
| TTS 朗读 | ✅ |
| PDF 导出（激励广告解锁，iOS 直接导出）| ✅ |
| 模型下载进度提示 + 重试 | ✅ |
| 5 语言 UI（简中/繁中/英/日/韩）| ✅ |
| 桌面图标多语言名称 | ✅ |
| 隐私政策（5 语言）| ✅ |
| Android 12+ 启动页 | ✅ |
| 开屏广告（Android）| ✅ |
| 横幅广告（Android）| ✅ |
| 插页广告（每 5 次识别，Android）| ✅ |
| 激励广告（PDF 导出，Android）| ✅ |
| iOS 无广告 | ✅ |

---

## 需求说明（已知限制）

- **Android minSdk = 24**（mobile_ocr 的 ONNX Runtime 要求）
- **实时识别模式**：采用定时截图（每 1.2 秒）而非 YUV 帧流处理，更稳定但延迟略高于帧流方式
- **模型首次需联网**：Android 端模型文件不内置于 APK（会使 APK 超过 Play Store 限制），改为首次运行时下载

---

## 联系
867263994@qq.com
