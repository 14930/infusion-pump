import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 5 - Infusion History Log
/// Shows completed session records stored locally.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<SessionRecord> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('infusion_sessions') ?? [];
    setState(() {
      _sessions = jsonList
          .map((json) => SessionRecord.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      _isLoading = false;
    });
  }

  /// Save a new session record.
  // ignore: unused_element - Called externally by other screens when sessions end
  static Future<void> saveSession(SessionRecord session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('infusion_sessions') ?? [];
    jsonList.add(jsonEncode(session.toJson()));
    await prefs.setStringList('infusion_sessions', jsonList);
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionProvider);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _sessions.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    return _SessionCard(
                      session: _sessions[index],
                      onExport: () => _exportSession(_sessions[index]),
                    );
                  },
                ),
    );
  }

  void _exportSession(SessionRecord session) {
    final text = session.toSummaryText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session summary copied to clipboard'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}

/// Expandable session card.
class _SessionCard extends StatefulWidget {
  final SessionRecord session;
  final VoidCallback onExport;

  const _SessionCard({required this.session, required this.onExport});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

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
                          s.drugName.isNotEmpty ? s.drugName : 'Unknown Drug',
                          style: const TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          dateFormat.format(s.startTime),
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${s.totalDispensedML.toStringAsFixed(1)} mL',
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
                  _DetailRow('Started', dateFormat.format(s.startTime)),
                  if (s.endTime != null)
                    _DetailRow('Ended', dateFormat.format(s.endTime!)),
                  _DetailRow(
                      'Duration', _formatDuration(s.durationMinutes)),
                  _DetailRow('Set Flow Rate',
                      '${s.setFlowRate.toStringAsFixed(1)} mL/hr'),
                  _DetailRow('Total Dispensed',
                      '${s.totalDispensedML.toStringAsFixed(1)} mL'),
                  if (s.alarmsTriggered.isNotEmpty)
                    _DetailRow('Alarms', s.alarmsTriggered.join(', ')),
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

  String _formatDuration(double minutes) {
    if (minutes < 60) return '${minutes.toStringAsFixed(0)} min';
    final hours = (minutes / 60).floor();
    final mins = (minutes % 60).floor();
    return '${hours}h ${mins}m';
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

/// A single infusion session record.
class SessionRecord {
  final String drugName;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDispensedML;
  final double setFlowRate;
  final List<String> alarmsTriggered;
  final double durationMinutes;

  SessionRecord({
    required this.drugName,
    required this.startTime,
    this.endTime,
    required this.totalDispensedML,
    required this.setFlowRate,
    this.alarmsTriggered = const [],
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'drugName': drugName,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'totalDispensedML': totalDispensedML,
        'setFlowRate': setFlowRate,
        'alarmsTriggered': alarmsTriggered,
        'durationMinutes': durationMinutes,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        drugName: json['drugName'] ?? '',
        startTime: DateTime.parse(json['startTime']),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'])
            : null,
        totalDispensedML: (json['totalDispensedML'] as num?)?.toDouble() ?? 0,
        setFlowRate: (json['setFlowRate'] as num?)?.toDouble() ?? 0,
        alarmsTriggered: List<String>.from(json['alarmsTriggered'] ?? []),
        durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0,
      );

  String toSummaryText() {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer();
    buf.writeln('--- Infusion Session Summary ---');
    buf.writeln('Drug: $drugName');
    buf.writeln('Started: ${df.format(startTime)}');
    if (endTime != null) buf.writeln('Ended: ${df.format(endTime!)}');
    buf.writeln('Duration: ${durationMinutes.toStringAsFixed(0)} min');
    buf.writeln('Flow Rate: ${setFlowRate.toStringAsFixed(1)} mL/hr');
    buf.writeln('Total Dispensed: ${totalDispensedML.toStringAsFixed(1)} mL');
    if (alarmsTriggered.isNotEmpty) {
      buf.writeln('Alarms: ${alarmsTriggered.join(", ")}');
    }
    buf.writeln('--------------------------------');
    return buf.toString();
  }
}
