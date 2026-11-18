import 'package:flutter/material.dart';

import 'localized_text.dart' show localizeCopy;

String reportMonthLabel(
  BuildContext context,
  String value, {
  bool compact = false,
}) {
  final date = DateTime.tryParse('$value-01');
  if (date == null) return value;
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
  final month = months[date.month - 1];
  final label = localizeCopy(context, compact ? month.substring(0, 3) : month);
  return '$label${compact ? '\n' : ' '}${date.year}';
}

// Round only the label. Forecast calculations and chart values keep precision.
String estimatedScanLabel(double value) {
  if (value == 0) return 'No scans expected to show this';
  if (value < 1) return 'Fewer than 1 scan expected to show this';
  final count = value.round();
  return count == 1
      ? 'About 1 scan may show this'
      : 'About $count scans may show this';
}
