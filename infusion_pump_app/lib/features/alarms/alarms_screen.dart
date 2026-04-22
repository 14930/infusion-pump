import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/notification_service.dart';
import '../../shared/models/alarm_data.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 2 - Alarms Panel
/// 2x2 grid of alarm cards with visual/audio/haptic alerts.
class AlarmsScreen extends ConsumerStatefulWidget {
  const AlarmsScreen({super.key});

  @override
  ConsumerState<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends ConsumerState<AlarmsScreen> {
  AlarmData? _previousAlarms;

  @override
  Widget build(BuildContext context) {
    final alarmAsync = ref.watch(alarmDataProvider);
    final connectionAsync = ref.watch(connectionProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Alarms Panel'),
        actions: [
          ConnectionIndicator(isConnected: isConnected),
        ],
      ),
      body: alarmAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: AppTheme.muted)),
        ),
        data: (alarms) {
          _handleAlarmChanges(alarms);
          return _buildContent(alarms);
        },
      ),
    );
  }

  void _handleAlarmChanges(AlarmData alarms) {
    if (_previousAlarms == null) {
      _previousAlarms = alarms;
      return;
    }

    // Check for newly triggered alarms
    if (alarms.hasActiveAlarm) {
      // New occlusion alarm
      if (alarms.occlusion && !(_previousAlarms?.occlusion ?? false)) {
        _triggerAlertActions('Occlusion Detected',
            'Line blockage detected. Check IV tubing immediately.', 1);
      }
      if (alarms.bubble && !(_previousAlarms?.bubble ?? false)) {
        _triggerAlertActions('Air Bubble Detected',
            'Air detected in the IV line. Infusion paused for safety.', 2);
      }
      if (alarms.bagEmpty && !(_previousAlarms?.bagEmpty ?? false)) {
        _triggerAlertActions(
            'Bag Empty', 'IV bag is empty. Replace fluid bag.', 3);
      }
      if (alarms.complete && !(_previousAlarms?.complete ?? false)) {
        NotificationService.showInfoNotification(
          id: 4,
          title: 'Infusion Complete',
          body: 'The prescribed infusion volume has been delivered.',
        );
      }
    } else {
      // All alarms cleared
      AudioService.stopAlarm();
    }

    _previousAlarms = alarms;
  }

  void _triggerAlertActions(String title, String body, int id) {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    // Sound
    AudioService.playAlarm();
    // Notification
    NotificationService.showAlarmNotification(
      id: id,
      title: title,
      body: body,
    );
  }

  Widget _buildContent(AlarmData alarms) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Icon(
                  alarms.hasActiveAlarm
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color:
                      alarms.hasActiveAlarm ? AppTheme.error : AppTheme.success,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  alarms.hasActiveAlarm
                      ? '${alarms.activeCount} alarm(s) active'
                      : 'All systems normal',
                  style: TextStyle(
                    color: alarms.hasActiveAlarm
                        ? AppTheme.error
                        : AppTheme.success,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 alarm grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _AlarmCard(
                  label: 'Occlusion',
                  icon: Icons.block_rounded,
                  isActive: alarms.occlusion,
                  description: 'Line blockage detected',
                  tooltip:
                      'Indicates the IV tubing is blocked or kinked, preventing fluid flow.',
                ),
                _AlarmCard(
                  label: 'Air Bubble',
                  icon: Icons.bubble_chart_rounded,
                  isActive: alarms.bubble,
                  description: 'Air in the IV line',
                  tooltip:
                      'Air has been detected in the infusion line, which can be dangerous if injected.',
                ),
                _AlarmCard(
                  label: 'Bag Empty',
                  icon: Icons.water_drop_outlined,
                  isActive: alarms.bagEmpty,
                  description: 'IV bag depleted',
                  tooltip:
                      'The IV fluid bag is empty and needs to be replaced to continue infusion.',
                ),
                _AlarmCard(
                  label: 'Complete',
                  icon: Icons.check_circle_outline_rounded,
                  isActive: alarms.complete,
                  description: 'Infusion finished',
                  tooltip:
                      'The prescribed volume has been fully delivered to the patient.',
                ),
              ],
            ),
          ),

          // Silence button
          if (alarms.hasActiveAlarm)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  AudioService.stopAlarm();
                  NotificationService.cancelAll();
                },
                icon: const Icon(Icons.volume_off_rounded),
                label: const Text('Silence Alarms'),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single alarm card with active/inactive state and pulse animation.
class _AlarmCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final String description;
  final String? tooltip;

  const _AlarmCard({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.description,
    this.tooltip,
  });

  @override
  State<_AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<_AlarmCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isActive ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: widget.isActive
                ? AppTheme.alarmActiveDecoration
                : AppTheme.alarmOkDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 36,
                  color: widget.isActive ? AppTheme.error : AppTheme.success,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isActive
                            ? AppTheme.error
                            : AppTheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.tooltip != null) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: widget.tooltip!,
                        child: const Icon(Icons.help_outline,
                            size: 12, color: AppTheme.muted),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isActive ? widget.description : 'OK',
                  style: TextStyle(
                    color: widget.isActive ? AppTheme.error : AppTheme.muted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
