// lib/services/pdf_service.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<void> exportToPdf({
    required String text,
    required String title,
    String? imagePath,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansSCRegular();

    pw.MemoryImage? image;
    if (imagePath != null && File(imagePath).existsSync()) {
      final bytes = await File(imagePath).readAsBytes();
      image = pw.MemoryImage(bytes);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue400, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '本地OCR 识别结果',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.blue700,
                ),
              ),
              pw.Text(
                DateTime.now().toString().substring(0, 19),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          ),
        ),
        build: (context) => [
          if (image != null) ...[
            pw.Center(
              child: pw.Container(
                constraints: const pw.BoxConstraints(maxHeight: 200),
                child: pw.Image(image),
              ),
            ),
            pw.SizedBox(height: 16),
          ],
          pw.Text(
            title.isNotEmpty ? title : '识别文字',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 12, lineSpacing: 6),
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ocr_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '本地OCR导出PDF',
    );
  }

  static Future<void> printText({
    required String text,
    String? title,
  }) async {
    final font = await PdfGoogleFonts.notoSansSCRegular();
    await Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          theme: pw.ThemeData.withFont(base: font),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (title != null)
                pw.Text(title,
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text(text,
                  style: pw.TextStyle(font: font, fontSize: 12)),
            ],
          ),
        ),
      );
      return pdf.save();
    });
  }
}
