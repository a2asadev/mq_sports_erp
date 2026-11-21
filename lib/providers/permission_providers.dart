import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/permissions_service.dart';

final Provider<PermissionsService> permissionsServiceProvider = Provider<PermissionsService>((Ref ref) => PermissionsService(ref.watch(apiClientProvider)));

/// What managers and staff may do, for the admin's Permissions page.
final AutoDisposeFutureProvider<PermissionMatrix> permissionMatrixProvider = FutureProvider.autoDispose<PermissionMatrix>((Ref ref) => ref.watch(permissionsServiceProvider).get());
