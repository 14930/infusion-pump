import 'package:firebase_database/firebase_database.dart';
import '../constants/firebase_paths.dart';

/// Service for reading from and writing to Firebase Realtime Database.
/// All pump sensor data and user controls go through this service.
class FirebaseService {
  final FirebaseDatabase _db;

  FirebaseService({FirebaseDatabase? database})
      : _db = database ?? FirebaseDatabase.instance;

  DatabaseReference get _ref => _db.ref();

  // ════════════════════════════════════════
  // READ STREAMS (from ESP32)
  // ════════════════════════════════════════

  /// Stream of dispensed volume in mL.
  Stream<double> get dispensedMLStream =>
      _ref.child(FirebasePaths.dispensedML).onValue.map(
            (event) => _toDouble(event.snapshot.value),
          );

  /// Stream of expected volume in mL.
  Stream<double> get expectedVolumeMLStream =>
      _ref.child(FirebasePaths.expectedVolumeML).onValue.map(
            (event) => _toDouble(event.snapshot.value),
          );

  /// Stream of weight reading in grams.
  Stream<double> get weightGramsStream =>
      _ref.child(FirebasePaths.weightGrams).onValue.map(
            (event) => _toDouble(event.snapshot.value),
          );

  /// Stream of pump status: "running" | "paused" | "complete" | "idle".
  Stream<String> get statusStream =>
      _ref.child(FirebasePaths.pumpStatus).onValue.map(
            (event) => (event.snapshot.value as String?) ?? 'idle',
          );

  /// Stream of all pump data as a map.
  Stream<Map<String, dynamic>> get pumpDataStream =>
      _ref.child(FirebasePaths.pumpRoot).onValue.map((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return <String, dynamic>{};
      });

  // ── Alarm streams ──

  Stream<bool> get occlusionStream =>
      _ref.child(FirebasePaths.occlusion).onValue.map(
            (event) => _toBool(event.snapshot.value),
          );

  Stream<bool> get bubbleStream =>
      _ref.child(FirebasePaths.bubble).onValue.map(
            (event) => _toBool(event.snapshot.value),
          );

  Stream<bool> get bagEmptyStream =>
      _ref.child(FirebasePaths.bagEmpty).onValue.map(
            (event) => _toBool(event.snapshot.value),
          );

  Stream<bool> get infusionCompleteStream =>
      _ref.child(FirebasePaths.alarmComplete).onValue.map(
            (event) => _toBool(event.snapshot.value),
          );

  /// Stream of all alarms as a map.
  Stream<Map<String, bool>> get allAlarmsStream =>
      _ref.child(FirebasePaths.alarmsRoot).onValue.map((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          return {
            'occlusion': _toBool(data['occlusion']),
            'bubble': _toBool(data['bubble']),
            'bagEmpty': _toBool(data['bagEmpty']),
            'complete': _toBool(data['complete']),
          };
        }
        return {
          'occlusion': false,
          'bubble': false,
          'bagEmpty': false,
          'complete': false,
        };
      });

  // ── Connection state ──

  Stream<bool> get connectionStream =>
      _db.ref('.info/connected').onValue.map(
            (event) => (event.snapshot.value as bool?) ?? false,
          );

  // ════════════════════════════════════════
  // WRITE OPERATIONS (to ESP32)
  // ════════════════════════════════════════

  /// Set the flow rate in mL/hr.
  Future<void> setFlowRate(double rate) async {
    await _ref.child(FirebasePaths.setFlowRate).set(rate);
  }

  /// Set the target volume in mL.
  Future<void> setVolume(double volume) async {
    await _ref.child(FirebasePaths.setVolume).set(volume);
  }

  /// Send a command: "start", "pause", or "stop".
  Future<void> sendCommand(String command) async {
    await _ref.child(FirebasePaths.command).set(command);
  }

  /// Set dosing parameters.
  Future<void> setDosingParameters({
    required String drugName,
    required double patientWeightKg,
    required double calculatedRate,
  }) async {
    await _ref.child(FirebasePaths.dosingRoot).update({
      'drugName': drugName,
      'patientWeightKg': patientWeightKg,
      'calculatedRate': calculatedRate,
    });
  }

  /// Apply flow rate and volume settings simultaneously.
  Future<void> applySettings({
    required double flowRate,
    required double volume,
  }) async {
    await _ref.child(FirebasePaths.pumpRoot).update({
      'setFlowRateMLperHR': flowRate,
      'setVolumeML': volume,
    });
  }

  // ════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════

  double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool _toBool(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
