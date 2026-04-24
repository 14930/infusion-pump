import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A background widget that displays a smooth blue gradient
/// from light blue at the top to deep dark navy at the bottom.
class BloodCellBackground extends StatelessWidget {
  final Widget child;

  const BloodCellBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background – light blue top → dark navy bottom
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A3A5C), // Lighter navy blue
                Color(0xFF0F2744), // Mid dark blue
                AppTheme.background, // Deep dark navy (0xFF0A1628)
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Actual content
        child,
      ],
    );
  }
}
