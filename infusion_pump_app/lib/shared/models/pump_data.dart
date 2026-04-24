/// Model representing pump data read from Firebase.
class PumpData {
  final double dispensedML;
  final double expectedVolumeML;
  final double setFlowRateMLperHR;
  final double setVolumeML;
  final double remainingML;
  final double remainingTimeMin;
  final String status;
  final String command;
  final DateTime lastUpdated;

  const PumpData({
    this.dispensedML = 0.0,
    this.expectedVolumeML = 0.0,
    this.setFlowRateMLperHR = 0.0,
    this.setVolumeML = 0.0,
    this.remainingML = 0.0,
    this.remainingTimeMin = 0.0,
    this.status = 'idle',
    this.command = '',
    required this.lastUpdated,
  });

  factory PumpData.fromMap(Map<String, dynamic> map) {
    return PumpData(
      dispensedML: _toDouble(map['dispensedML']),
      expectedVolumeML: _toDouble(map['expectedVolumeML']),
      setFlowRateMLperHR: _toDouble(map['setFlowRateMLperHR']),
      setVolumeML: _toDouble(map['setVolumeML']),
      remainingML: _toDouble(map['remainingML']),
      remainingTimeMin: _toDouble(map['remainingTimeMin']),
      status: (map['status'] as String?) ?? 'idle',
      command: (map['command'] as String?) ?? '',
      lastUpdated: DateTime.now(),
    );
  }

  factory PumpData.empty() => PumpData(lastUpdated: DateTime.now());

  /// Progress as a fraction 0.0 to 1.0.
  double get progress {
    if (setVolumeML <= 0) return 0.0;
    return (dispensedML / setVolumeML).clamp(0.0, 1.0);
  }

  /// Formatted remaining time (read from Firebase remainingTimeMin).
  String get remainingTimeFormatted {
    final mins = remainingTimeMin;
    if (mins <= 0) return 'Complete';
    if (mins < 60) return '${mins.toStringAsFixed(0)} min';
    final hours = (mins / 60).floor();
    final remMins = (mins % 60).floor();
    return '${hours}h ${remMins}m';
  }

  static double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
