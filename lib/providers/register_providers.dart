import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/models/register_day.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/register_service.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/sync_controller.dart';

final Provider<RegisterService> registerServiceProvider =
    Provider<RegisterService>((Ref ref) => RegisterService(ref.watch(apiClientProvider)));

/// One day at the register: "YYYY-MM-DD", or null for today. It is read again
/// whenever the app has synced (a payment from another device changes the cash).
final AutoDisposeFutureProviderFamily<RegisterDay, String?> registerDayProvider =
    FutureProvider.autoDispose.family<RegisterDay, String?>((Ref ref, String? date) {
  ref.watch(syncTickProvider);
  return ref.watch(registerServiceProvider).day(date: date);
});

/// Past closings, newest first.
final AutoDisposeFutureProvider<List<RegisterClosing>> registerClosingsProvider =
    FutureProvider.autoDispose<List<RegisterClosing>>((Ref ref) {
  ref.watch(syncTickProvider);
  return ref.watch(registerServiceProvider).closings();
});

/// Actions on this device the server has not taken over yet. The day's cash is only
/// complete once they are uploaded, so the day cannot be closed before. The web has
/// no queue (everything is sent at once).
final Provider<int> registerUnsentProvider = Provider<int>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return 0;
  }
  return ref.watch(syncSummaryProvider).waiting;
});
