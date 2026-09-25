import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/models.dart';
import 'scan_history_database.dart';

class PapusoyReportService {
  const PapusoyReportService._();

  static Future<String> export({
    required List<ScanData> scans,
    required String location,
    required String scoutedBy,
    DateTime? exportedAt,
  }) async {
    final reportNumber = await ScanHistoryDatabase.instance
        .takeNextReportNumber();
    final filename = 'PapusoyHydrofarm_report#$reportNumber.pdf';
    final bytes = await buildPdf(
      scans: scans,
      location: location,
      scoutedBy: scoutedBy,
      exportedAt: exportedAt ?? DateTime.now(),
    );
    await Printing.sharePdf(bytes: bytes, filename: filename);
    return filename;
  }

  static Future<Uint8List> buildPdf({
    required List<ScanData> scans,
    required String location,
    required String scoutedBy,
    required DateTime exportedAt,
  }) async {
    final document = pw.Document(
      title: 'Papusoy Hydrofarm Scouting Report',
      author: scoutedBy,
      subject: 'Crop scouting report for $location',
    );
    final logoData = await _loadBrandLogo();
    final logo = pw.MemoryImage(_optimizedLogo(logoData.buffer.asUint8List()));
    final infected = scans
        .where((scan) => scan.status == 'Infected')
        .toList(growable: false);
    final healthyCount = scans.length - infected.length;
    final diseaseCounts = _counts(infected.map((scan) => scan.disease));
    final cropInfectionCounts = _counts(infected.map((scan) => scan.plant));
    final cropGroups = <String, List<ScanData>>{};
    for (final scan in scans) {
      cropGroups.putIfAbsent(scan.plant, () => <ScanData>[]).add(scan);
    }

    final attachments = <_ReportAttachment>[];
    final imageCache = <String, pw.ImageProvider>{};
    for (final scan in infected) {
      try {
        final file = File(scan.imagePath);
        if (await file.exists()) {
          final cached = imageCache[scan.imagePath];
          final image = cached ?? pw.MemoryImage(await _optimizedImage(file));
          imageCache[scan.imagePath] = image;
          attachments.add(_ReportAttachment(scan: scan, image: image));
        }
      } on FileSystemException {
        // A missing local image does not prevent the report from exporting.
      }
    }

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(36, 34, 36, 34),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Papusoy Hydrofarm',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          _header(
            logo: logo,
            location: location,
            scoutedBy: scoutedBy,
            date: exportedAt,
          ),
          pw.SizedBox(height: 24),
          _sectionTitle('Observations'),
          pw.SizedBox(height: 10),
          _summaryCards(
            healthy: healthyCount,
            infected: infected.length,
            mostActiveDisease: _topEntry(diseaseCounts),
            mostAffectedCrop: _topEntry(cropInfectionCounts),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Location: $location',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 8),
          _cropTable(cropGroups, location),
          pw.SizedBox(height: 12),
          pw.Text(
            'Diseases recorded at this location',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            diseaseCounts.isEmpty
                ? 'None detected'
                : diseaseCounts.entries
                      .map((entry) => '${entry.key} (${entry.value})')
                      .join(', '),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 22),
          _sectionTitle('Attachments'),
          pw.SizedBox(height: 10),
          if (attachments.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                infected.isEmpty
                    ? 'No affected crops were recorded at this location.'
                    : 'Affected crop images are no longer available on this device.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            )
          else
            ...attachments.asMap().entries.map(
              (entry) => _attachment(entry.key + 1, entry.value),
            ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _header({
    required pw.ImageProvider logo,
    required String location,
    required String scoutedBy,
    required DateTime date,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 58,
          height: 58,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.green700, width: 1.2),
            borderRadius: pw.BorderRadius.circular(29),
          ),
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Papusoy Hydrofarm',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'SCOUTING REPORT',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Location: $location',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'Scouted date: ${_dateLabel(date)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'Scouted by: $scoutedBy',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String value) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.only(bottom: 5),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.green700, width: 1),
      ),
    ),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 15,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.green900,
      ),
    ),
  );

  static pw.Widget _summaryCards({
    required int healthy,
    required int infected,
    required String mostActiveDisease,
    required String mostAffectedCrop,
  }) {
    return pw.Row(
      children: [
        _summaryCard('Healthy', '$healthy', PdfColors.green700),
        pw.SizedBox(width: 6),
        _summaryCard('Infected', '$infected', PdfColors.red700),
        pw.SizedBox(width: 6),
        _summaryCard(
          'Most active disease',
          mostActiveDisease,
          PdfColors.orange800,
        ),
        pw.SizedBox(width: 6),
        _summaryCard('Most affected crop', mostAffectedCrop, PdfColors.red800),
      ],
    );
  }

  static pw.Widget _summaryCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        height: 55,
        padding: const pw.EdgeInsets.all(7),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              maxLines: 2,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cropTable(
    Map<String, List<ScanData>> groups,
    String location,
  ) {
    final rows = groups.entries
        .map((entry) {
          final affected = entry.value
              .where((scan) => scan.status == 'Infected')
              .length;
          final diseases = entry.value
              .where((scan) => scan.status == 'Infected')
              .map((scan) => scan.disease)
              .toSet()
              .join(', ');
          return [
            entry.key,
            location,
            '${entry.value.length}',
            '${entry.value.length - affected}',
            '$affected',
            diseases.isEmpty ? 'None' : diseases,
          ];
        })
        .toList(growable: false);
    return pw.TableHelper.fromTextArray(
      headers: const [
        'Crop',
        'Location tag',
        'Scans',
        'Healthy',
        'Infected',
        'Diseases',
      ],
      data: rows,
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellStyle: const pw.TextStyle(fontSize: 7.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(0.6),
        3: pw.FlexColumnWidth(0.7),
        4: pw.FlexColumnWidth(0.7),
        5: pw.FlexColumnWidth(1.8),
      },
    );
  }

  static pw.Widget _attachment(int number, _ReportAttachment attachment) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(
              attachment.image,
              height: 190,
              fit: pw.BoxFit.cover,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.grey100,
            child: pw.Text(
              '$number. ${attachment.scan.plant} - ${attachment.scan.disease}',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, int> _counts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  static Future<Uint8List> _optimizedImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = decoded.width > 1200
        ? img.copyResize(decoded, width: 1200)
        : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: 78));
  }

  static Uint8List _optimizedLogo(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(decoded, width: 256);
    return Uint8List.fromList(img.encodePng(resized, level: 6));
  }

  static Future<ByteData> _loadBrandLogo() async {
    try {
      return await rootBundle.load('assets/papusoy_logo.png');
    } catch (_) {
      return rootBundle.load('assets/leaflens_logo.png');
    }
  }

  static String _topEntry(Map<String, int> counts) {
    if (counts.isEmpty) return 'None';
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return '${entries.first.key} (${entries.first.value})';
  }

  static String _dateLabel(DateTime value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }
}

class _ReportAttachment {
  const _ReportAttachment({required this.scan, required this.image});

  final ScanData scan;
  final pw.ImageProvider image;
}
