import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildtrack/core/models/labour.dart';
import 'package:buildtrack/core/repositories/labour_repository.dart';

/// Labour repository provider
final labourRepositoryProvider = Provider<LabourRepository>((ref) {
  return LabourRepository();
});

/// Labour search query provider
final labourSearchProvider = StateProvider<String>((ref) {
  return '';
});

/// Labour list provider
final labourListProvider = FutureProvider<List<Labour>>((ref) async {
  final repo = ref.watch(labourRepositoryProvider);
  final query = ref.watch(labourSearchProvider);

  if (query.isEmpty) {
    return repo.getLabour();
  } else {
    return repo.searchLabour(query);
  }
});

/// Labour detail provider
final labourDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, labourId) async {
    final repo = ref.watch(labourRepositoryProvider);
    return repo.getLabourDetail(labourId);
  },
);

/// Site labour provider
final siteLabourProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, projectId) async {
    final repo = ref.watch(labourRepositoryProvider);
    return repo.getSiteLabour(projectId);
  },
);

/// Import preview data provider
final importPreviewProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});

/// Duplicate check provider
final duplicateCheckProvider = FutureProvider.family<bool, Map<String, dynamic>>(
  (ref, data) async {
    final repo = ref.watch(labourRepositoryProvider);
    return repo.hasDuplicateByPhoneOrCnic(
      phone: data['phone'] as String?,
      cnic: data['cnic'] as String?,
      excludeLabourId: data['exclude_id'] as String?,
    );
  },
);

/// Mutation counter for cache invalidation
final labourMutationProvider = StateProvider<int>((ref) {
  return 0;
});
