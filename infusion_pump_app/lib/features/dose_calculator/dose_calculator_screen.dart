import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/connection_indicator.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/debouncer.dart';
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
  final _concentrationController = TextEditingController();
  final _doseController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  String _selectedDrug = '';
  String _selectedUnit = 'mcg/kg/min';
  double? _calculatedRate;
  bool _isSending = false;
  String? _warningMessage;

  @override
  void dispose() {
    _weightController.dispose();
    _concentrationController.dispose();
    _doseController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionProvider);
    final isConnected = connectionAsync.valueOrNull ?? false;

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
              // Drug autocomplete
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
              Autocomplete<DrugReference>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _drugReferences;
                  }
                  return _drugReferences.where((drug) => drug.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (drug) => drug.name,
                onSelected: (drug) {
                  setState(() {
                    _selectedDrug = drug.name;
                    _selectedUnit = drug.unit;
                    _concentrationController.text =
                        drug.standardConcentration.toString();
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    validator: Validators.required,
                    decoration: const InputDecoration(
                      labelText: 'Drug Name',
                      hintText: 'Search for a drug...',
                      prefixIcon: Icon(Icons.medication_rounded,
                          color: AppTheme.muted, size: 20),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 8,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final drug = options.elementAt(index);
                            return ListTile(
                              title: Text(drug.name,
                                  style: const TextStyle(
                                      color: AppTheme.onSurface)),
                              subtitle: Text(
                                  '${drug.doseRange} ${drug.unit}',
                                  style: const TextStyle(
                                      color: AppTheme.muted, fontSize: 12)),
                              onTap: () => onSelected(drug),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
                        style:
                            TextStyle(color: AppTheme.success, fontSize: 13),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Warning if rate exceeds safe range
                if (_warningMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x33E67E22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0x66E67E22), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppTheme.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _warningMessage!,
                            style: const TextStyle(
                                color: AppTheme.warning, fontSize: 12),
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
                    onPressed: _isSending ? null : _sendToDevice,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                        _isSending ? 'Sending...' : 'Send to Device'),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Drug reference table
              const Text(
                'DRUG REFERENCE TABLE',
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
                child: Column(
                  children: _drugReferences
                      .map((drug) => _DrugRefTile(drug: drug))
                      .toList(),
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

    // Check if rate is within safe range for selected drug
    String? warning;
    final drugRef = _drugReferences.where((d) => d.name == _selectedDrug);
    if (drugRef.isNotEmpty) {
      final ref = drugRef.first;
      if (rate > ref.maxSafeRate) {
        warning =
            'Calculated rate (${rate.toStringAsFixed(1)} mL/hr) exceeds the typical safe range for ${ref.name} (max ~${ref.maxSafeRate} mL/hr). Verify prescription.';
      }
    }

    setState(() {
      _calculatedRate = rate;
      _warningMessage = warning;
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

    setState(() => _isSending = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      await service.setDosingParameters(
        drugName: _selectedDrug.isNotEmpty ? _selectedDrug : 'Custom',
        patientWeightKg: double.parse(_weightController.text),
        dosePerKg: double.parse(_doseController.text),
        calculatedFlowRate: _calculatedRate!,
      );
      await service.setFlowRate(_calculatedRate!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosing parameters sent to device'),
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
}

/// Drug reference tile in the reference table.
class _DrugRefTile extends StatelessWidget {
  final DrugReference drug;
  const _DrugRefTile({required this.drug});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x221E88E5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(drug.name,
                style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(drug.doseRange,
                style:
                    const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(drug.unit,
                style:
                    const TextStyle(color: AppTheme.muted, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// Pre-loaded drug reference data for 10 common ICU drugs.
class DrugReference {
  final String name;
  final String doseRange;
  final String unit;
  final double standardConcentration; // mg/mL
  final double maxSafeRate; // mL/hr

  const DrugReference({
    required this.name,
    required this.doseRange,
    required this.unit,
    required this.standardConcentration,
    required this.maxSafeRate,
  });
}

const List<DrugReference> _drugReferences = [
  DrugReference(
    name: 'Dopamine',
    doseRange: '2-20',
    unit: 'mcg/kg/min',
    standardConcentration: 1.6,
    maxSafeRate: 100,
  ),
  DrugReference(
    name: 'Dobutamine',
    doseRange: '2.5-20',
    unit: 'mcg/kg/min',
    standardConcentration: 1.0,
    maxSafeRate: 120,
  ),
  DrugReference(
    name: 'Norepinephrine',
    doseRange: '0.01-0.3',
    unit: 'mcg/kg/min',
    standardConcentration: 0.016,
    maxSafeRate: 100,
  ),
  DrugReference(
    name: 'Heparin',
    doseRange: '10-25',
    unit: 'units/kg/hr',
    standardConcentration: 100.0,
    maxSafeRate: 50,
  ),
  DrugReference(
    name: 'Morphine',
    doseRange: '0.01-0.05',
    unit: 'mg/kg/hr',
    standardConcentration: 1.0,
    maxSafeRate: 10,
  ),
  DrugReference(
    name: 'Midazolam',
    doseRange: '0.5-6',
    unit: 'mcg/kg/min',
    standardConcentration: 1.0,
    maxSafeRate: 30,
  ),
  DrugReference(
    name: 'Propofol',
    doseRange: '25-75',
    unit: 'mcg/kg/min',
    standardConcentration: 10.0,
    maxSafeRate: 50,
  ),
  DrugReference(
    name: 'Insulin',
    doseRange: '0.02-0.1',
    unit: 'units/kg/hr',
    standardConcentration: 1.0,
    maxSafeRate: 20,
  ),
  DrugReference(
    name: 'Amiodarone',
    doseRange: '0.5-1.0',
    unit: 'mg/kg/hr',
    standardConcentration: 1.8,
    maxSafeRate: 60,
  ),
  DrugReference(
    name: 'Furosemide',
    doseRange: '0.1-0.4',
    unit: 'mg/kg/hr',
    standardConcentration: 10.0,
    maxSafeRate: 10,
  ),
];
