import 'package:flutter/material.dart';

import '../models/sensor_event.dart';
import '../theme/app_theme.dart';

/// A small dependency-free line chart of temperature readings over time.
/// Deliberately hand-rolled with CustomPainter rather than a charting
/// package, to keep this build's dependency surface minimal.
class SensorLineChart extends StatelessWidget {
  const SensorLineChart({super.key, required this.events});

  final List<SensorEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    final temps = events.map((e) => e.temperatureC).toList();
    final minT = temps.reduce((a, b) => a < b ? a : b) - 1.5;
    final maxT = temps.reduce((a, b) => a > b ? a : b) + 1.5;

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          values: temps,
          minY: minT,
          maxY: maxT,
          lineColor: AppColors.primary,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.minY,
    required this.maxY,
    required this.lineColor,
  });

  final List<double> values;
  final double minY;
  final double maxY;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 8.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 12.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = topPad + chartHeight * (i / 3);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
    }

    if (values.length < 2) {
      return;
    }

    final range = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = leftPad + chartWidth * (i / (values.length - 1));
      final normalized = (values[i] - minY) / range;
      final y = topPad + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, topPad + chartHeight);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, topPad + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.18), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    final dotBorder = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotBorder);
      canvas.drawCircle(p, 2.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
