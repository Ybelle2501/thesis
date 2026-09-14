// ─── DATA MODELS ─────────────────────────────────────────────────────────────

class ScanData {
  final int? id;
  final String plant;
  final String disease;
  final String status;
  final double confidence;
  final String imagePath;
  final String rawLabel;
  final int classIndex;
  final DateTime capturedAt;
  final String source;
  final String scanMode;
  final int? gridCell;

  const ScanData({
    this.id,
    required this.plant,
    required this.disease,
    required this.status,
    required this.confidence,
    required this.imagePath,
    required this.rawLabel,
    required this.classIndex,
    required this.capturedAt,
    required this.source,
    required this.scanMode,
    this.gridCell,
  });

  ScanData copyWith({int? id, String? imagePath}) {
    return ScanData(
      id: id ?? this.id,
      plant: plant,
      disease: disease,
      status: status,
      confidence: confidence,
      imagePath: imagePath ?? this.imagePath,
      rawLabel: rawLabel,
      classIndex: classIndex,
      capturedAt: capturedAt,
      source: source,
      scanMode: scanMode,
      gridCell: gridCell,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'plant': plant,
      'disease': disease,
      'status': status,
      'confidence': confidence,
      'image_path': imagePath,
      'raw_label': rawLabel,
      'class_index': classIndex,
      'captured_at': capturedAt.toUtc().millisecondsSinceEpoch,
      'source': source,
      'scan_mode': scanMode,
      'grid_cell': gridCell,
    };
  }

  factory ScanData.fromMap(Map<String, Object?> map) {
    return ScanData(
      id: map['id'] as int?,
      plant: map['plant'] as String,
      disease: map['disease'] as String,
      status: map['status'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      imagePath: map['image_path'] as String,
      rawLabel: map['raw_label'] as String,
      classIndex: map['class_index'] as int,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(
        map['captured_at'] as int,
        isUtc: true,
      ).toLocal(),
      source: map['source'] as String,
      scanMode: map['scan_mode'] as String,
      gridCell: map['grid_cell'] as int?,
    );
  }

  String get date => '${dateGroupLabel(capturedAt)}, ${timeLabel(capturedAt)}';

  String get contextLabel {
    final cell = gridCell == null ? '' : ' - Cell $gridCell';
    return '$source - $scanMode$cell';
  }

  String get emoji => '🌿';
}

String dateGroupLabel(DateTime value, {DateTime? relativeTo}) {
  final date = value.toLocal();
  final now = (relativeTo ?? DateTime.now()).toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = today.difference(target).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final year = date.year == now.year ? '' : ', ${date.year}';
  return '${months[date.month - 1]} ${date.day}$year';
}

String timeLabel(DateTime value) {
  final date = value.toLocal();
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
