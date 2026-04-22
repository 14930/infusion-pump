import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A status chip that shows the pump state with appropriate color.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'running':
        return _StatusConfig('Running', AppTheme.success);
      case 'paused':
        return _StatusConfig('Paused', AppTheme.warning);
      case 'complete':
        return _StatusConfig('Complete', AppTheme.info);
      case 'idle':
      default:
        return _StatusConfig('Idle', AppTheme.muted);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  _StatusConfig(this.label, this.color);
}
