import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/client.dart';
import '../../../core/models/project.dart';
import '../../../core/repositories/client_repository.dart';
import '../../features/auth/data/auth_providers.dart';
import 'sites_repository.dart';

/// Repository providers
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository();
});

final sitesRepositoryProvider = Provider<SitesRepository>((ref) {
  return SitesRepository();
});

/// Client search query provider
final clientSearchProvider = StateProvider<String>((ref) {
  return '';
});

/// Clients list provider
final clientsListProvider = FutureProvider<List<Client>>((ref) async {
  final repo = ref.watch(clientRepositoryProvider);
  final query = ref.watch(clientSearchProvider);

  if (query.isEmpty) {
    return repo.getClients();
  } else {
    return repo.searchClients(query);
  }
});

/// Sites list provider (role-aware)
final sitesListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(sitesRepositoryProvider);
  final userRole = await ref.watch(currentUserRoleProvider.future);

  if (userRole == 'manager') {
    // Managers get only assigned sites
    final sites = await repo.getManagerSites();
    return sites
        .map((s) => {
              'id': s.id,
              'name': s.name,
              'location': s.location,
              'status': s.status,
            })
        .toList();
  } else {
    // Admin/accountant see all sites with finance
    return repo.getSitesWithFinance();
  }
});

/// Site detail provider
final siteDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, siteId) async {
    final repo = ref.watch(sitesRepositoryProvider);
    return repo.getSiteDetail(siteId);
  },
);

/// All clients for dropdown/picker
final allClientsProvider = FutureProvider<List<Client>>((ref) async {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getClients();
});

/// Invalidate caches on mutation
final siteMutationProvider = StateProvider<int>((ref) {
  return 0;
});

final clientMutationProvider = StateProvider<int>((ref) {
  return 0;
});
