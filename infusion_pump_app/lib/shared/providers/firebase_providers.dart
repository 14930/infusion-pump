import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firebase_service.dart';
import '../../main.dart' show firebaseInitialized;
import '../models/pump_data.dart';
import '../models/alarm_data.dart';

/// Provider for the FirebaseService singleton.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Provider for Firebase connection status.
final connectionProvider = StreamProvider<bool>((ref) {
  if (!firebaseInitialized) {
    return Stream.value(false);
  }
  final service = ref.watch(firebaseServiceProvider);
  return service.connectionStream;
});

/// Provider for pump data stream.
final pumpDataProvider = StreamProvider<PumpData>((ref) {
  if (!firebaseInitialized) {
    return Stream.value(PumpData.empty());
  }
  final service = ref.watch(firebaseServiceProvider);
  return service.pumpDataStream.map((map) => PumpData.fromMap(map));
});

/// Provider for alarm data stream.
final alarmDataProvider = StreamProvider<AlarmData>((ref) {
  if (!firebaseInitialized) {
    return Stream.value(AlarmData.empty());
  }
  final service = ref.watch(firebaseServiceProvider);
  return service.allAlarmsStream.map((map) => AlarmData.fromMap(map));
});

/// Provider for pump status stream.
final pumpStatusProvider = StreamProvider<String>((ref) {
  if (!firebaseInitialized) {
    return Stream.value('idle');
  }
  final service = ref.watch(firebaseServiceProvider);
  return service.statusStream;
});

/// Provider for dispensed ML stream.
final dispensedMLProvider = StreamProvider<double>((ref) {
  if (!firebaseInitialized) {
    return Stream.value(0.0);
  }
  final service = ref.watch(firebaseServiceProvider);
  return service.dispensedMLStream;
});

/// Provider for volume chart data points. Accumulates data over time.
class VolumeChartNotifier extends StateNotifier<List<ChartPoint>> {
  final FirebaseService _service;
  StreamSubscription? _dispensedSub;
  StreamSubscription? _expectedSub;
  final DateTime _startTime = DateTime.now();
  double _lastDispensed = 0;
  double _lastExpected = 0;

  VolumeChartNotifier(this._service) : super([]) {
    if (firebaseInitialized) {
      _dispensedSub = _service.dispensedMLStream.listen((val) {
        _lastDispensed = val;
        _addPoint();
      });
      _expectedSub = _service.expectedVolumeMLStream.listen((val) {
        _lastExpected = val;
      });
    }
  }

  void _addPoint() {
    final elapsed = DateTime.now().difference(_startTime).inSeconds / 60.0;
    final point = ChartPoint(
      timeMinutes: elapsed,
      actual: _lastDispensed,
      expected: _lastExpected,
    );
    // Keep max 200 data points
    final newList = [...state, point];
    if (newList.length > 200) {
      newList.removeRange(0, newList.length - 200);
    }
    state = newList;
  }

  @override
  void dispose() {
    _dispensedSub?.cancel();
    _expectedSub?.cancel();
    super.dispose();
  }
}

final volumeChartProvider =
    StateNotifierProvider<VolumeChartNotifier, List<ChartPoint>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return VolumeChartNotifier(service);
});

/// A single data point for the volume chart.
class ChartPoint {
  final double timeMinutes;
  final double actual;
  final double expected;

  ChartPoint({
    required this.timeMinutes,
    required this.actual,
    required this.expected,
  });
}
