import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 5 - Infusion History Log
/// Shows completed session records from Firebase history/.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionProvider);
    final historyAsync = ref.watch(historyProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Infusion History'),
        actions: [
          ConnectionIndicator(isConnected: isConnected),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: AppTheme.muted)),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 64, color: AppTheme.muted.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text(
                    'No infusion sessions recorded yet',
                    style: TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completed and stopped sessions will appear here.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          // Sort by date descending
          final sorted = List<Map<String, dynamic>>.from(sessions)
            ..sort((a, b) {
              final aDate = (a['date'] as String?) ?? '';
              final bDate = (b['date'] as String?) ?? '';
              return bDate.compareTo(aDate);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              return _SessionCard(
                session: sorted[index],
                onExport: () => _exportSession(context, sorted[index]),
              );
            },
          );
        },
      ),
    );
  }

  void _exportSession(BuildContext context, Map<String, dynamic> session) {
    final text = _buildSummaryText(session);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session summary copied to clipboard'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  String _buildSummaryText(Map<String, dynamic> s) {
    final buf = StringBuffer();
    buf.writeln('--- Infusion Session Summary ---');
    buf.writeln('Date: ${s['date'] ?? ''}');
    buf.writeln('Drug: ${s['drugName'] ?? 'Unknown'}');
    buf.writeln('Started: ${s['startTime'] ?? ''}');
    buf.writeln('Ended: ${s['endTime'] ?? ''}');
    buf.writeln(
        'Flow Rate: ${_toDouble(s['setFlowRate']).toStringAsFixed(1)} mL/hr');
    buf.writeln(
        'Total Dispensed: ${_toDouble(s['totalDispensed']).toStringAsFixed(1)} mL');
    final alarms = s['alarmsTriggered'] ?? '';
    if (alarms.toString().isNotEmpty) {
      buf.writeln('Alarms: $alarms');
    }
    buf.writeln('--------------------------------');
    return buf.toString();
  }

  double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Expandable session card.
class _SessionCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final VoidCallback onExport;

  const _SessionCard({required this.session, required this.onExport});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final drugName = (s['drugName'] as String?) ?? 'Unknown Drug';
    final date = (s['date'] as String?) ?? '';
    final startTime = (s['startTime'] as String?) ?? '';
    final endTime = (s['endTime'] as String?) ?? '';
    final setFlowRate = _toDouble(s['setFlowRate']);
    final totalDispensed = _toDouble(s['totalDispensed']);
    final alarmsTriggered = (s['alarmsTriggered'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drugName.isNotEmpty ? drugName : 'Unknown Drug',
                          style: const TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$date  $startTime',
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${totalDispensed.toStringAsFixed(1)} mL',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Color(0x221E88E5)),
                  _DetailRow('Date', date),
                  _DetailRow('Started', startTime),
                  _DetailRow('Ended', endTime),
                  _DetailRow('Set Flow Rate',
                      '${setFlowRate.toStringAsFixed(1)} mL/hr'),
                  _DetailRow('Total Dispensed',
                      '${totalDispensed.toStringAsFixed(1)} mL'),
                  if (alarmsTriggered.isNotEmpty)
                    _DetailRow('Alarms', alarmsTriggered),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onExport,
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Summary'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style:
                    const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
