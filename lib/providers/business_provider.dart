import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/currency.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/online/business_service.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

/// Raised whenever the business is changed from inside the app (a new shop name,
/// phone or currency), so [businessProvider] reads the session again.
final StateProvider<int> _businessRevisionProvider = StateProvider<int>((Ref ref) => 0);

/// The business the signed-in user works for: its shop name and phone for
/// receipts, its own walk-in customer, and its currency. The server names them at
/// sign-in and the app keeps them with the session, so this also works offline.
///
/// Until the server has said (a session saved before businesses existed), it is
/// MQ Sports, the only business there was.
///
/// Reading it also points [MoneyFormat] at the business's currency, and
/// [AppColors] at its accent colour, so every amount and every button uses them.
final Provider<BusinessInfo> businessProvider = Provider<BusinessInfo>((Ref ref) {
  // Re-read whenever the signed-in user is (a new sign-in, or a fresh `/v1/auth/me`),
  // and whenever the app itself changed the business.
  ref.watch(currentUserProvider);
  ref.watch(_businessRevisionProvider);
  final BusinessInfo business = ref.watch(apiClientProvider).currentBusiness ?? BusinessInfo.mqSports;
  MoneyFormat.use(business.currency);
  AppColors.useBrand(AppColors.tryParseHex(business.brandColor));
  return business;
});

/// Saves a changed description of the business with the session and applies it
/// everywhere (receipts, amounts). Call it after the server accepted the change.
final Provider<Future<void> Function(BusinessInfo business)> businessUpdaterProvider =
    Provider<Future<void> Function(BusinessInfo business)>((Ref ref) {
  return (BusinessInfo business) async {
    await ref.read(apiClientProvider).rememberBusiness(business);
    ref.read(_businessRevisionProvider.notifier).state++;
  };
});

/// Changes to the business itself (currency, colour, cash register). Needs a connection.
final Provider<BusinessService> businessServiceProvider =
    Provider<BusinessService>((Ref ref) => BusinessService(ref.watch(apiClientProvider)));
