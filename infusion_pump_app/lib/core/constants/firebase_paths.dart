/// Firebase Realtime Database path constants.
///
/// Structure:
///   pump/           – session data & commands
///   alarms/         – alarm flags
///   doseCalc/       – dose calculator parameters
///   history/        – completed session logs
class FirebasePaths {
  FirebasePaths._();

  // ── Pump data (READ from ESP32) ──
  static const String pumpRoot = 'pump';
  static const String dispensedML = '$pumpRoot/dispensedML';
  static const String expectedVolumeML = '$pumpRoot/expectedVolumeML';
  static const String remainingML = '$pumpRoot/remainingML';
  static const String remainingTimeMin = '$pumpRoot/remainingTimeMin';
  static const String pumpStatus = '$pumpRoot/status';

  // ── Pump controls (WRITE to ESP32) ──
  static const String setFlowRate = '$pumpRoot/setFlowRateMLperHR';
  static const String setVolume = '$pumpRoot/setVolumeML';
  static const String command = '$pumpRoot/command';

  // ── Alarms (READ from ESP32) ──
  static const String alarmsRoot = 'alarms';
  static const String occlusion = '$alarmsRoot/occlusion';
  static const String bubble = '$alarmsRoot/bubble';
  static const String bagEmpty = '$alarmsRoot/bagEmpty';
  static const String alarmComplete = '$alarmsRoot/complete';

  // ── Dose Calculator (WRITE from app) ──
  static const String doseCalcRoot = 'doseCalc';
  static const String drugName = '$doseCalcRoot/drugName';
  static const String patientWeightKg = '$doseCalcRoot/patientWeightKg';
  static const String dosePerKg = '$doseCalcRoot/dosePerKg';
  static const String calculatedFlowRate = '$doseCalcRoot/calculatedFlowRate';

  // ── History (READ/WRITE from app) ──
  static const String historyRoot = 'history';
}
