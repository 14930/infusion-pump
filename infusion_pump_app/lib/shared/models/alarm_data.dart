/// Model representing alarm states from Firebase.
class AlarmData {
  final bool occlusion;
  final bool bubble;
  final bool bagEmpty;
  final bool complete;

  const AlarmData({
    this.occlusion = false,
    this.bubble = false,
    this.bagEmpty = false,
    this.complete = false,
  });

  factory AlarmData.fromMap(Map<String, bool> map) {
    return AlarmData(
      occlusion: map['occlusion'] ?? false,
      bubble: map['bubble'] ?? false,
      bagEmpty: map['bagEmpty'] ?? false,
      complete: map['complete'] ?? false,
    );
  }

  factory AlarmData.empty() => const AlarmData();

  /// True if any alarm is currently active.
  bool get hasActiveAlarm => occlusion || bubble || bagEmpty || complete;

  /// Number of active alarms.
  int get activeCount =>
      [occlusion, bubble, bagEmpty, complete].where((a) => a).length;

  /// List of active alarm labels.
  List<String> get activeLabels {
    final labels = <String>[];
    if (occlusion) labels.add('Occlusion');
    if (bubble) labels.add('Air Bubble');
    if (bagEmpty) labels.add('Bag Empty');
    if (complete) labels.add('Infusion Complete');
    return labels;
  }
}
