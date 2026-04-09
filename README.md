# 本地OCR Flutter项目

完整的本地OCR文字提取器，基于 Google ML Kit，支持 Android & iOS。

## 快速开始

```bash
# 1. 解压项目
unzip local_ocr_flutter.zip && cd ocr_app

# 2. 安装 Flutter 依赖
flutter pub get

# 3. 生成多语言文件（重要！）
flutter gen-l10n

# 4. 生成 Isar 代码（已预生成，如需重新生成：）
dart run build_runner build --delete-conflicting-outputs

# 5. 运行 (连接设备)
flutter run

# 6. 构建 Android APK
flutter build apk --release

# 7. 构建 Android AAB (上传 Play Store)
flutter build appbundle --release

# 8. 构建 iOS (需要 macOS + Xcode)
flutter build ios --release
```

## 广告开关

打开 `lib/core/constants/ad_constants.dart`：
```dart
static const bool useTestAds = true;   // ← 发布前改为 false
```

## 功能清单

| 功能 | 状态 |
|------|------|
| 拍照识别 | ✅ |
| 相册选图识别 | ✅ |
| 实时摄像头识别 | ✅ |
| 历史记录（Isar本地DB）| ✅ |
| 全文搜索历史 | ✅ |
| 一键复制 | ✅ |
| 分享 | ✅ |
| TTS朗读 | ✅ |
| PDF导出（激励广告解锁）| ✅ |
| 多语言OCR（中/英/日/韩/拉丁）| ✅ |
| 开屏广告 | ✅ Android |
| 横幅广告 | ✅ Android |
| 插页广告（每5次识别）| ✅ Android |
| 激励广告（PDF导出）| ✅ Android |
| iOS无广告 | ✅ |
| 5语言UI（简中/繁中/英/日/韩）| ✅ |
| 桌面图标多语言名称 | ✅ |
| 隐私政策（5语言）| ✅ |
| Android 12+ 启动页 | ✅ |
| App图标（全尺寸）| ✅ |

## 广告配置

| 广告类型 | 位置 | Android | iOS |
|---------|------|---------|-----|
| 开屏广告 | 启动时 | ✅ | ❌ |
| 横幅广告 | 首页+结果页底部 | ✅ | ❌ |
| 插页广告 | 每5次识别后 | ✅ | ❌ |
| 激励广告 | PDF导出前 | ✅ | ❌(直接导出) |

## 包名
`cn.inaiworld.local_ocr`

## 联系
867263994@qq.com
