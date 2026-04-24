import 'dart:convert';

import 'package:flutter/services.dart';

import '../../shared/models/drug_library_entry.dart';

class DrugLibraryService {
  static const String _libraryAsset = 'assets/drug_library/s_dose_cleaned.csv';

  List<DrugLibraryEntry>? _cachedEntries;

  Future<List<DrugLibraryEntry>> loadEntries() async {
    if (_cachedEntries != null) return _cachedEntries!;

    final csvText = await rootBundle.loadString(_libraryAsset);
    final lines = const LineSplitter().convert(csvText);
    if (lines.length < 2) {
      _cachedEntries = const [];
      return _cachedEntries!;
    }

    final headers = _splitCsvLine(lines.first)
        .map((header) => header.trim())
        .toList(growable: false);

    final parsed = <DrugLibraryEntry>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final values = _splitCsvLine(line);
      if (values.length != headers.length) continue;

      final row = <String, String>{};
      for (var col = 0; col < headers.length; col++) {
        row[headers[col]] = values[col];
      }
      parsed.add(DrugLibraryEntry.fromCsv(row));
    }

    _cachedEntries = parsed;
    return _cachedEntries!;
  }

  Future<List<String>> getIvDrugNames() async {
    final entries = await loadEntries();
    final names = entries
        .where((entry) => entry.route == 'IV')
        .map((entry) => entry.generic)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  Future<DrugDoseValidationResult> validateDose({
    required String selectedDrug,
    required double ageValue,
    required AgeUnit ageUnit,
    required double weightKg,
    required double enteredDailyDoseMg,
  }) async {
    if (selectedDrug == 'Other') {
      return const DrugDoseValidationResult.allowed(
        message:
            'Custom drug selected. Library limits are not available, so use clinical judgment before delivery.',
      );
    }

    final entries = await loadEntries();
    final drugRows = entries
        .where((entry) =>
            entry.generic.toLowerCase() == selectedDrug.toLowerCase())
        .toList();

    if (drugRows.isEmpty) {
      return const DrugDoseValidationResult.allowed(
        message:
            'Drug is not in the library. You can use Other for custom delivery.',
      );
    }

    final ivRows = drugRows.where((entry) => entry.route == 'IV').toList();
    if (ivRows.isEmpty) {
      return const DrugDoseValidationResult.blocked(
        message:
            'This drug has no IV entry in the library, so delivery is blocked.',
      );
    }

    final ageMatchedRows = ivRows
        .where(
            (entry) => entry.matchesAge(ageValue: ageValue, ageUnit: ageUnit))
        .toList();
    if (ageMatchedRows.isEmpty) {
      return const DrugDoseValidationResult.blocked(
        message:
            'Drug exists in the library, but the patient age is outside allowed IV ranges. Delivery blocked.',
      );
    }

    final weightMatchedRows =
        ageMatchedRows.where((entry) => entry.matchesWeight(weightKg)).toList();
    final effectiveRows =
        weightMatchedRows.isNotEmpty ? weightMatchedRows : ageMatchedRows;

    final maxCandidates = <double>[];
    for (final row in effectiveRows) {
      if (row.maxDoseDdMg > 0) {
        maxCandidates.add(row.maxDoseDdMg);
      }
      if (row.limitMg > 0) {
        maxCandidates.add(row.limitMg);
      }
      if (row.maxDoseDwMg > 0) {
        maxCandidates.add(row.maxDoseDwMg * weightKg);
      }
    }

    if (maxCandidates.isEmpty) {
      return const DrugDoseValidationResult.allowed(
        message:
            'No numeric max dose was found for this IV age range. Delivery is allowed with caution.',
      );
    }

    maxCandidates.sort();
    final maxAllowedDailyDoseMg = maxCandidates.first;

    if (enteredDailyDoseMg > maxAllowedDailyDoseMg) {
      return DrugDoseValidationResult.blocked(
        maxAllowedDailyDoseMg: maxAllowedDailyDoseMg,
        message:
            'Entered dose exceeds the maximum allowed (${maxAllowedDailyDoseMg.toStringAsFixed(1)} mg/day) for this drug and age. Delivery blocked.',
      );
    }

    return DrugDoseValidationResult.allowed(
      maxAllowedDailyDoseMg: maxAllowedDailyDoseMg,
      message:
          'Dose is within the IV library limit (${maxAllowedDailyDoseMg.toStringAsFixed(1)} mg/day).',
    );
  }

  List<String> _splitCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }

    fields.add(buffer.toString().trim());
    return fields;
  }
}

class DrugDoseValidationResult {
  final bool isAllowed;
  final double? maxAllowedDailyDoseMg;
  final String message;

  const DrugDoseValidationResult._({
    required this.isAllowed,
    required this.maxAllowedDailyDoseMg,
    required this.message,
  });

  const DrugDoseValidationResult.allowed({
    required String message,
    double? maxAllowedDailyDoseMg,
  }) : this._(
          isAllowed: true,
          maxAllowedDailyDoseMg: maxAllowedDailyDoseMg,
          message: message,
        );

  const DrugDoseValidationResult.blocked({
    required String message,
    double? maxAllowedDailyDoseMg,
  }) : this._(
          isAllowed: false,
          maxAllowedDailyDoseMg: maxAllowedDailyDoseMg,
          message: message,
        );
}
