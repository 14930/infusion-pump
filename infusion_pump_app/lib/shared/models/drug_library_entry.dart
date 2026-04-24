class DrugLibraryEntry {
  final String generic;
  final double minAgeDays;
  final double maxAgeDays;
  final double minAgeMonths;
  final double maxAgeMonths;
  final double minAgeYears;
  final double maxAgeYears;
  final double minWeight;
  final double maxWeight;
  final double maxDoseDwMg;
  final double limitMg;
  final double maxDoseDdMg;
  final String route;

  const DrugLibraryEntry({
    required this.generic,
    required this.minAgeDays,
    required this.maxAgeDays,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.minAgeYears,
    required this.maxAgeYears,
    required this.minWeight,
    required this.maxWeight,
    required this.maxDoseDwMg,
    required this.limitMg,
    required this.maxDoseDdMg,
    required this.route,
  });

  factory DrugLibraryEntry.fromCsv(Map<String, String> row) {
    return DrugLibraryEntry(
      generic: (row['generic'] ?? '').trim(),
      minAgeDays: _toDouble(row['min_age_d']),
      maxAgeDays: _toDouble(row['max_age_d'], fallback: 999),
      minAgeMonths: _toDouble(row['min_age_m']),
      maxAgeMonths: _toDouble(row['max_age_m'], fallback: 999),
      minAgeYears: _toDouble(row['min_age_y']),
      maxAgeYears: _toDouble(row['max_age_y'], fallback: 999),
      minWeight: _toDouble(row['min_weight']),
      maxWeight: _toDouble(row['max_weight'], fallback: 999),
      maxDoseDwMg: _toDouble(row['max_dose_dw_mg']),
      limitMg: _toDouble(row['limit_mg']),
      maxDoseDdMg: _toDouble(row['max_dose_dd_mg']),
      route: (row['route'] ?? '').trim().toUpperCase(),
    );
  }

  bool matchesAge({required double ageValue, required AgeUnit ageUnit}) {
    switch (ageUnit) {
      case AgeUnit.days:
        return ageValue >= minAgeDays && ageValue <= maxAgeDays;
      case AgeUnit.months:
        return ageValue >= minAgeMonths && ageValue <= maxAgeMonths;
      case AgeUnit.years:
        return ageValue >= minAgeYears && ageValue <= maxAgeYears;
    }
  }

  bool matchesWeight(double weightKg) {
    return weightKg >= minWeight && weightKg <= maxWeight;
  }

  static double _toDouble(String? value, {double fallback = 0}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return double.tryParse(value.trim()) ?? fallback;
  }
}

enum AgeUnit { days, months, years }
