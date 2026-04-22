import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Firebase connection status indicator for the app bar.
class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const ConnectionIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: (isConnected ? AppTheme.success : AppTheme.error)
            .withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isConnected ? AppTheme.success : AppTheme.error)
              .withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isConnected ? AppTheme.success : AppTheme.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? AppTheme.success : AppTheme.error)
                      .withAlpha(100),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Connected' : 'Offline',
            style: TextStyle(
              color: isConnected ? AppTheme.success : AppTheme.error,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
