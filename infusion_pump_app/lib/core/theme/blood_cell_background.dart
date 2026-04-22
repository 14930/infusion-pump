import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A background painter that draws static medical cross and pulse
/// shapes scattered across the screen at very low opacity.
class BloodCellBackground extends StatelessWidget {
  final Widget child;

  const BloodCellBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(color: AppTheme.background),
        // Medical pattern shapes
        Positioned.fill(
          child: CustomPaint(
            painter: _MedicalPatternPainter(),
          ),
        ),
        // Actual content
        child,
      ],
    );
  }
}

class _MedicalPatternPainter extends CustomPainter {
  // Pre-defined shape positions (relative 0-1 coords), sizes, rotations
  static const List<_CellData> _cells = [
    _CellData(0.1, 0.08, 140, -0.3, 0x1A1E88E5),
    _CellData(0.85, 0.15, 100, 0.5, 0x1842A5F5),
    _CellData(0.05, 0.35, 120, 0.8, 0x1A1E88E5),
    _CellData(0.75, 0.42, 160, -0.6, 0x1542A5F5),
    _CellData(0.4, 0.6, 90, 1.2, 0x1A1E88E5),
    _CellData(0.9, 0.7, 130, -1.0, 0x2242A5F5),
    _CellData(0.15, 0.82, 110, 0.3, 0x181E88E5),
    _CellData(0.6, 0.9, 150, -0.8, 0x1A1E88E5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final cell in _cells) {
      final paint = Paint()
        ..color = Color(cell.color)
        ..style = PaintingStyle.fill;

      final cx = cell.relX * size.width;
      final cy = cell.relY * size.height;
      final r = cell.size / 2;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(cell.rotation);

      // Draw soft ellipse shapes (medical-style subtle pattern)
      // Outer ellipse
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: cell.size, height: r),
        paint,
      );

      // Inner glow (lighter center)
      final dimplePaint = Paint()
        ..color = Color(cell.color).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: cell.size * 0.5, height: r * 0.4),
        dimplePaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CellData {
  final double relX;
  final double relY;
  final double size;
  final double rotation;
  final int color;

  const _CellData(this.relX, this.relY, this.size, this.rotation, this.color);
}
