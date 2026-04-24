import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../core/utils/debouncer.dart';
import '../../core/utils/validators.dart';
import '../../shared/models/drug_library_entry.dart';
import '../../shared/providers/drug_library_providers.dart';
import '../../shared/providers/firebase_providers.dart';

/// Screen 4 - Auto Dose Calculator
/// Calculates flow rate from drug, weight, concentration, and dose.
class DoseCalculatorScreen extends ConsumerStatefulWidget {
  const DoseCalculatorScreen({super.key});

  @override
  ConsumerState<DoseCalculatorScreen> createState() =>
      _DoseCalculatorScreenState();
}

class _DoseCalculatorScreenState extends ConsumerState<DoseCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _doseController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  String _selectedDrug = 'Other';
  String _selectedUnit = 'mcg/kg/min';
  AgeUnit _selectedAgeUnit = AgeUnit.years;
  double? _calculatedRate;
  double? _enteredDailyDoseMg;
  bool _isSending = false;
  String? _infoMessage;
  bool _deliveryBlocked = false;

  @override
  void dispose() {
    _weightController.dispose();
    _ageController.dispose();
    _concentrationController.dispose();
    _doseController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionProvider);
    final ivDrugNamesAsync = ref.watch(ivDrugNamesProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;
    final ivDrugs = ivDrugNamesAsync.valueOrNull ?? const <String>[];
    final drugOptions = ['Other', ...ivDrugs];

    if (!drugOptions.contains(_selectedDrug)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedDrug = 'Other';
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Dose Calculator'),
        actions: [
          ConnectionIndicator(isConnected: isConnected),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IV-only drug library selection
              const Text(
                'DRUG SELECTION',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ivDrugNamesAsync.when(
                loading: () =>
                    const LinearProgressIndicator(color: AppTheme.primary),
                error: (err, _) => Text(
                  'Unable to load drug library: $err',
                  style: const TextStyle(color: AppTheme.error),
                ),
                data: (_) => DropdownButtonFormField<String>(
                  initialValue: _selectedDrug,
                  dropdownColor: AppTheme.surface,
                  decoration: const InputDecoration(
                    labelText: 'IV Drug (Library)',
                    prefixIcon: Icon(Icons.medication_rounded,
                        color: AppTheme.muted, size: 20),
                  ),
                  items: drugOptions
                      .map(
                        (drug) => DropdownMenuItem<String>(
                          value: drug,
                          child: Text(drug),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedDrug = value;
                      _infoMessage = null;
                      _deliveryBlocked = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Patient weight
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.weight,
                decoration: const InputDecoration(
                  labelText: 'Patient Weight',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined,
                      color: AppTheme.muted, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Patient age for library validation
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateAge,
                      decoration: const InputDecoration(
                        labelText: 'Patient Age',
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: AppTheme.muted, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<AgeUnit>(
                      initialValue: _selectedAgeUnit,
                      dropdownColor: AppTheme.surface,
                      decoration: const InputDecoration(labelText: 'Age Unit'),
                      items: const [
                        DropdownMenuItem(
                            value: AgeUnit.days, child: Text('Days')),
                        DropdownMenuItem(
                            value: AgeUnit.months, child: Text('Months')),
                        DropdownMenuItem(
                            value: AgeUnit.years, child: Text('Years')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAgeUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Drug concentration
              TextFormField(
                controller: _concentrationController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.concentration,
                decoration: const InputDecoration(
                  labelText: 'Drug Concentration',
                  suffixText: 'mg/mL',
                  prefixIcon: Icon(Icons.science_outlined,
                      color: AppTheme.muted, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Prescribed dose with unit selector
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _doseController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.dose,
                      decoration: const InputDecoration(
                        labelText: 'Prescribed Dose',
                        prefixIcon: Icon(Icons.local_pharmacy_outlined,
                            color: AppTheme.muted, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      dropdownColor: AppTheme.surface,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'mcg/kg/min', child: Text('mcg/kg/min')),
                        DropdownMenuItem(
                            value: 'mg/kg/hr', child: Text('mg/kg/hr')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calculate button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('Calculate Flow Rate'),
                ),
              ),
              const SizedBox(height: 20),

              // Result display
              if (_calculatedRate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0x1A2ECC71),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0x442ECC71), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Calculated Flow Rate',
                        style: TextStyle(color: AppTheme.success, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_calculatedRate!.toStringAsFixed(2)} mL/hr',
                        style: GoogleFonts.exo2(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFormulaExplanation(),
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entered daily dose: ${_enteredDailyDoseMg?.toStringAsFixed(1) ?? '0.0'} mg/day',
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_infoMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _deliveryBlocked
                          ? const Color(0x33E74C3C)
                          : const Color(0x332ECC71),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _deliveryBlocked
                              ? const Color(0x66E74C3C)
                              : const Color(0x662ECC71),
                          width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _deliveryBlocked
                              ? Icons.block_rounded
                              : Icons.verified_rounded,
                          color: _deliveryBlocked
                              ? AppTheme.error
                              : AppTheme.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _infoMessage!,
                            style: TextStyle(
                              color: _deliveryBlocked
                                  ? AppTheme.error
                                  : AppTheme.success,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Send to device button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed:
                        (_isSending || _deliveryBlocked) ? null : _sendToDevice,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_deliveryBlocked
                        ? 'Delivery Blocked'
                        : (_isSending ? 'Sending...' : 'Send to Device')),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Quick preview of loaded IV drug library
              const Text(
                'IV DRUG LIBRARY',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.cardDecoration,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ivDrugNamesAsync.when(
                  loading: () => const Text(
                    'Loading library...',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                  error: (err, _) => Text(
                    'Library error: $err',
                    style: const TextStyle(color: AppTheme.error),
                  ),
                  data: (drugs) {
                    final preview = drugs.take(12).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IV entries available: ${drugs.length} drugs',
                          style: const TextStyle(
                              color: AppTheme.onSurface, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: preview
                              .map((drug) => Chip(
                                    label: Text(drug),
                                    backgroundColor: AppTheme.surface,
                                    side: const BorderSide(
                                        color: Color(0x441E88E5), width: 0.8),
                                  ))
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final concentration = double.parse(_concentrationController.text);
    final dose = double.parse(_doseController.text);

    double conversionFactor;
    if (_selectedUnit == 'mcg/kg/min') {
      // mcg/kg/min -> mg/hr: multiply by 60 / 1000
      conversionFactor = 60.0 / 1000.0;
    } else {
      // mg/kg/hr: already in mg/hr per kg
      conversionFactor = 1.0;
    }

    final rate = (dose * weight * conversionFactor) / concentration;
    final dailyDoseMg = _toDailyDoseMg(dose, weight);

    _debouncer.run(() {
      _validateDoseAgainstLibrary(dailyDoseMg);
    });

    setState(() {
      _calculatedRate = rate;
      _enteredDailyDoseMg = dailyDoseMg;
    });
  }

  String _getFormulaExplanation() {
    final weight = _weightController.text;
    final conc = _concentrationController.text;
    final dose = _doseController.text;
    if (_selectedUnit == 'mcg/kg/min') {
      return 'Formula: ($dose mcg/kg/min x $weight kg x 60) / ($conc mg/mL x 1000)';
    }
    return 'Formula: ($dose mg/kg/hr x $weight kg) / $conc mg/mL';
  }

  Future<void> _sendToDevice() async {
    if (_calculatedRate == null) return;

    final dailyDoseMg = _enteredDailyDoseMg ??
        _toDailyDoseMg(
          double.parse(_doseController.text),
          double.parse(_weightController.text),
        );

    final isAllowed = await _validateDoseAgainstLibrary(dailyDoseMg);
    if (!isAllowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_infoMessage ?? 'Dose is blocked by the drug library.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      final currentPump = ref.read(pumpDataProvider).valueOrNull;
      final currentVolume = currentPump?.setVolumeML ?? 0;

      await service.setDosingParameters(
        drugName: _selectedDrug,
        patientWeightKg: double.parse(_weightController.text),
        dosePerKg: double.parse(_doseController.text),
        calculatedFlowRate: _calculatedRate!,
      );

      // Keep Control tab and pump settings in sync by writing through pumpRoot.
      if (currentVolume > 0) {
        await service.applySettings(
          flowRate: _calculatedRate!,
          volume: currentVolume,
        );
      } else {
        await service.setFlowRate(_calculatedRate!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Dosing parameters sent to device (IV safety check passed)'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  double _toDailyDoseMg(double dosePerKg, double weightKg) {
    if (_selectedUnit == 'mcg/kg/min') {
      return dosePerKg * weightKg * 60 * 24 / 1000;
    }
    return dosePerKg * weightKg * 24;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Age must be greater than 0';
    return null;
  }

  Future<bool> _validateDoseAgainstLibrary(double dailyDoseMg) async {
    final age = double.parse(_ageController.text);
    final weight = double.parse(_weightController.text);

    final validation = await ref.read(drugLibraryServiceProvider).validateDose(
          selectedDrug: _selectedDrug,
          ageValue: age,
          ageUnit: _selectedAgeUnit,
          weightKg: weight,
          enteredDailyDoseMg: dailyDoseMg,
        );

    if (mounted) {
      setState(() {
        _deliveryBlocked = !validation.isAllowed;
        _infoMessage = validation.message;
      });
    }

    return validation.isAllowed;
  }
}
