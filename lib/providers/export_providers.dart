import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/export_models.dart';
import 'package:a2_stocks/online/export_service.dart';
import 'package:a2_stocks/online/online_providers.dart';

final Provider<ExportService> exportServiceProvider = Provider<ExportService>((Ref ref) => ExportService(ref.watch(apiClientProvider)));

/// The data sets with their sizes, the last export and the server's backup status.
final AutoDisposeFutureProvider<ExportOverview> exportOverviewProvider = FutureProvider.autoDispose<ExportOverview>((Ref ref) => ref.watch(exportServiceProvider).overview());
