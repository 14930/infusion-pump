/// Validation utilities for form inputs.
class Validators {
  Validators._();

  /// Validates flow rate: must be 1-999 mL/hr.
  static String? flowRate(String? value) {
    if (value == null || value.isEmpty) return 'Flow rate is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n < 1 || n > 999) return 'Must be between 1 and 999 mL/hr';
    return null;
  }

  /// Validates volume: must be 1-9999 mL.
  static String? volume(String? value) {
    if (value == null || value.isEmpty) return 'Volume is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n < 1 || n > 9999) return 'Must be between 1 and 9999 mL';
    return null;
  }

  /// Validates patient weight: must be 0.1-500 kg.
  static String? weight(String? value) {
    if (value == null || value.isEmpty) return 'Weight is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n < 0.1 || n > 500) return 'Must be between 0.1 and 500 kg';
    return null;
  }

  /// Validates concentration: must be > 0.
  static String? concentration(String? value) {
    if (value == null || value.isEmpty) return 'Concentration is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Must be greater than 0';
    return null;
  }

  /// Validates dose: must be > 0.
  static String? dose(String? value) {
    if (value == null || value.isEmpty) return 'Dose is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Must be greater than 0';
    return null;
  }

  /// Validates a required text field.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }
}
