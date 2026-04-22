import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A reusable metric display card with title, value, and unit.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String? tooltip;
  final String? lastUpdated;
  final IconData? icon;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.tooltip,
    this.lastUpdated,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppTheme.muted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (tooltip != null)
                Tooltip(
                  message: tooltip!,
                  child: const Icon(
                    Icons.help_outline,
                    size: 14,
                    color: AppTheme.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.exo2(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 4),
            Text(
              lastUpdated!,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
