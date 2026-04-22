import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/utils/debouncer.dart';
import '../../core/utils/validators.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 3 - Manual Control
/// Start/Pause/Stop buttons, flow rate & volume inputs, Apply Settings.
class ControlScreen extends ConsumerStatefulWidget {
  const ControlScreen({super.key});

  @override
  ConsumerState<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends ConsumerState<ControlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flowRateController = TextEditingController();
  final _volumeController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);
  bool _isApplying = false;

  @override
  void dispose() {
    _flowRateController.dispose();
    _volumeController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pumpAsync = ref.watch(pumpDataProvider);
    final connectionAsync = ref.watch(connectionProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Manual Control'),
        actions: [
          ConnectionIndicator(isConnected: isConnected),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            pumpAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (pump) => Center(child: StatusChip(status: pump.status)),
            ),
            const SizedBox(height: 24),

            // Control buttons
            const Text(
              'PUMP CONTROL',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    color: AppTheme.success,
                    onPressed: () => _sendCommand('start'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ControlButton(
                    label: 'Pause',
                    icon: Icons.pause_rounded,
                    color: AppTheme.warning,
                    onPressed: () => _sendCommand('pause'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ControlButton(
                    label: 'Stop',
                    icon: Icons.stop_rounded,
                    color: AppTheme.error,
                    onPressed: () => _confirmStop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Settings inputs
            const Text(
              'INFUSION SETTINGS',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _flowRateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.flowRate,
                    decoration: const InputDecoration(
                      labelText: 'Flow Rate (mL/hr)',
                      hintText: '1 - 999',
                      prefixIcon: Icon(Icons.speed_rounded,
                          color: AppTheme.muted, size: 20),
                      suffixText: 'mL/hr',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _volumeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.volume,
                    decoration: const InputDecoration(
                      labelText: 'Target Volume (mL)',
                      hintText: '1 - 9999',
                      prefixIcon: Icon(Icons.water_drop_outlined,
                          color: AppTheme.muted, size: 20),
                      suffixText: 'mL',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isApplying ? null : _applySettings,
                      icon: _isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.onSurface,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                          _isApplying ? 'Applying...' : 'Apply Settings'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current hardware status
            const Text(
              'HARDWARE STATUS',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            pumpAsync.when(
              loading: () => const LinearProgressIndicator(
                  color: AppTheme.primary),
              error: (err, _) => Text('Error: $err',
                  style: const TextStyle(color: AppTheme.error)),
              data: (pump) => Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    _InfoRow('Status', pump.status.toUpperCase()),
                    _InfoRow('Dispensed',
                        '${pump.dispensedML.toStringAsFixed(1)} mL'),
                    _InfoRow('Set Flow Rate',
                        '${pump.setFlowRateMLperHR.toStringAsFixed(1)} mL/hr'),
                    _InfoRow('Target Volume',
                        '${pump.setVolumeML.toStringAsFixed(1)} mL'),
                    _InfoRow('Weight',
                        '${pump.weightGrams.toStringAsFixed(1)} g'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendCommand(String command) {
    _debouncer.run(() {
      final service = ref.read(firebaseServiceProvider);
      service.sendCommand(command);
    });
  }

  void _confirmStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Stop Infusion?',
            style: TextStyle(color: AppTheme.onSurface)),
        content: const Text(
          'This will immediately stop the infusion pump. Are you sure?',
          style: TextStyle(color: AppTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: AppTheme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              _sendCommand('stop');
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  Future<void> _applySettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isApplying = true);

    final flowRate = double.parse(_flowRateController.text);
    final volume = double.parse(_volumeController.text);

    try {
      final service = ref.read(firebaseServiceProvider);
      await service.applySettings(flowRate: flowRate, volume: volume);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings applied successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}

/// A colored control button (Start/Pause/Stop).
class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(80), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row showing a label and value in the hardware status card.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
