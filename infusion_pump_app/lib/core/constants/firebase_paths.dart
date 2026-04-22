/// Firebase Realtime Database path constants for the ESP32 pump.
///
/// READ paths (sensor data from ESP32):
///   /pump/dispensedML, /pump/expectedVolumeML, /pump/weightGrams, /pump/status
///   /alarms/occlusion, /alarms/bubble, /alarms/bagEmpty, /alarms/complete
///
/// WRITE paths (user controls to ESP32):
///   /pump/setFlowRateMLperHR, /pump/setVolumeML, /pump/command
///   /dosing/drugName, /dosing/patientWeightKg, /dosing/calculatedRate
class FirebasePaths {
  FirebasePaths._();

  // ── Pump data (READ) ──
  static const String pumpRoot = 'pump';
  static const String dispensedML = '$pumpRoot/dispensedML';
  static const String expectedVolumeML = '$pumpRoot/expectedVolumeML';
  static const String weightGrams = '$pumpRoot/weightGrams';
  static const String pumpStatus = '$pumpRoot/status';

  // ── Pump controls (WRITE) ──
  static const String setFlowRate = '$pumpRoot/setFlowRateMLperHR';
  static const String setVolume = '$pumpRoot/setVolumeML';
  static const String command = '$pumpRoot/command';

  // ── Alarms (READ) ──
  static const String alarmsRoot = 'alarms';
  static const String occlusion = '$alarmsRoot/occlusion';
  static const String bubble = '$alarmsRoot/bubble';
  static const String bagEmpty = '$alarmsRoot/bagEmpty';
  static const String alarmComplete = '$alarmsRoot/complete';

  // ── Dosing (WRITE) ──
  static const String dosingRoot = 'dosing';
  static const String drugName = '$dosingRoot/drugName';
  static const String patientWeightKg = '$dosingRoot/patientWeightKg';
  static const String calculatedRate = '$dosingRoot/calculatedRate';
}
