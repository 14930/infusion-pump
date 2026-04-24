import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/drug_library_service.dart';

final drugLibraryServiceProvider = Provider<DrugLibraryService>((ref) {
  return DrugLibraryService();
});

final ivDrugNamesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(drugLibraryServiceProvider);
  return service.getIvDrugNames();
});
