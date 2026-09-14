import 'package:flutter/material.dart';

class GridOverlay extends StatelessWidget {
  const GridOverlay({super.key, required this.rows, required this.columns});

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridOverlayPainter(rows: rows, columns: columns),
        size: Size.infinite,
      ),
    );
  }
}

class _GridOverlayPainter extends CustomPainter {
  const _GridOverlayPainter({required this.rows, required this.columns});

  final int rows;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    void drawLine(Offset start, Offset end) {
      canvas.drawLine(start, end, shadowPaint);
      canvas.drawLine(start, end, linePaint);
    }

    for (int column = 1; column < columns; column++) {
      final x = size.width * column / columns;
      drawLine(Offset(x, 0), Offset(x, size.height));
    }
    for (int row = 1; row < rows; row++) {
      final y = size.height * row / rows;
      drawLine(Offset(0, y), Offset(size.width, y));
    }

    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        final cellNumber = row * columns + column + 1;
        final center = Offset(column * cellWidth + 20, row * cellHeight + 20);
        canvas.drawCircle(center, 13, Paint()..color = Colors.black87);
        canvas.drawCircle(
          center,
          13,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$cellNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridOverlayPainter oldDelegate) {
    return rows != oldDelegate.rows || columns != oldDelegate.columns;
  }
}
