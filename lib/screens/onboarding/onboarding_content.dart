import 'package:flutter/material.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/user_role.dart';

/// One page of the welcome guide.
class OnboardingStep {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
    this.points = const <String>[],
    this.asksRegister = false,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Short bullet lines under the text.
  final List<String> points;

  /// Shows the "I use a cash register" switch under the text (the admin's guide).
  final bool asksRegister;
}

OnboardingStep _offline(AppLocalizations l10n) => OnboardingStep(
  icon: Icons.cloud_sync_outlined,
  title: l10n.onboardingContentWorksWithOrWithout,
  body: l10n.onboardingContentOnPhonesAndComputers,
  points: <String>[
    l10n.onboardingContentTheChipAtThe,
    l10n.onboardingContentIfTheServerRefuses,
    l10n.onboardingContentSalesMadeOfflineAre,
  ],
);

OnboardingStep _profile(AppLocalizations l10n) => OnboardingStep(
  icon: Icons.account_circle_outlined,
  title: l10n.onboardingContentYourProfile,
  body: l10n.onboardingContentOpenSettingsToAdd,
);

List<OnboardingStep> _staff(AppLocalizations l10n) => <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: l10n.onboardingContentWelcomeToA2Stocks,
        body: l10n.onboardingContentYouAreSignedIn3,
      ),
      OnboardingStep(
        icon: Icons.point_of_sale_outlined,
        title: l10n.onboardingContentSelling,
        body: l10n.onboardingContentOpenSalesOrdersTo,
        points: <String>[
          l10n.onboardingContentChooseTheCustomerAdd,
          l10n.onboardingContentRecordThePaymentNow,
          l10n.onboardingContentMoveAnOrderAlong,
        ],
      ),
      OnboardingStep(
        icon: Icons.inventory_2_outlined,
        title: l10n.onboardingContentProductsAndStock,
        body: l10n.onboardingContentLookUpProductsPrices,
        points: <String>[
          l10n.onboardingContentRedNumbersInStock,
          l10n.onboardingContentYouCanAddPhotos,
        ],
      ),
      OnboardingStep(
        icon: Icons.groups_outlined,
        title: l10n.moduleCustomers,
        body: l10n.onboardingContentAddACustomerWhen,
      ),
      _offline(l10n),
      _profile(l10n),
    ];

List<OnboardingStep> _manager(AppLocalizations l10n) => <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: l10n.onboardingContentWelcomeToA2Stocks,
        body: l10n.onboardingContentYouAreSignedIn2,
      ),
      OnboardingStep(
        icon: Icons.dashboard_outlined,
        title: l10n.onboardingContentYourDashboard,
        body: l10n.onboardingContentTheHomeScreenShows,
      ),
      OnboardingStep(
        icon: Icons.point_of_sale_outlined,
        title: l10n.onboardingContentSalesAndOnlineOrders,
        body: l10n.onboardingContentSalesOrdersHoldsEvery,
        points: <String>[
          l10n.onboardingContentOnlineOrdersAreMarked,
          l10n.onboardingContentOnlyYouAndAdmins,
        ],
      ),
      OnboardingStep(
        icon: Icons.shopping_cart_checkout_outlined,
        title: l10n.onboardingContentBuyingStock,
        body: l10n.onboardingContentVendorsAndPurchasesRecord,
      ),
      OnboardingStep(
        icon: Icons.fact_check_outlined,
        title: l10n.onboardingContentStockAndAudits,
        body: l10n.onboardingContentCountTheShelfIn,
        points: <String>[l10n.onboardingContentSetAnAlertLevel],
      ),
      OnboardingStep(
        icon: Icons.add_a_photo_outlined,
        title: l10n.onboardingContentPhotos,
        body: l10n.onboardingContentAddPhotosToProducts2,
      ),
      _offline(l10n),
      _profile(l10n),
    ];

List<OnboardingStep> _admin(AppLocalizations l10n) => <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: l10n.onboardingContentWelcomeToA2Stocks,
        body: l10n.onboardingContentYouAreSignedIn,
      ),
      OnboardingStep(
        icon: Icons.checklist_outlined,
        title: l10n.onboardingContentFirstSetupChecklist,
        body: l10n.onboardingContentDoTheseOnceIn,
        points: <String>[
          l10n.onboardingContent1SettingsOnlineStore,
          l10n.onboardingContent2SettingsOnlineStore,
          l10n.onboardingContent3CategoriesStartFrom,
          l10n.onboardingContent4VendorsAndCustomers,
          l10n.onboardingContent5PurchasesToPut,
          l10n.onboardingContent6UsersALogin,
        ],
      ),
      OnboardingStep(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.onboardingContentCashRegister,
        body: l10n.onboardingContentCashRegisterBody,
        points: <String>[l10n.onboardingContentCashRegisterNoRegister],
        asksRegister: true,
      ),
      OnboardingStep(
        icon: Icons.people_outline,
        title: l10n.onboardingContentYourTeam,
        body: l10n.onboardingContentCreateALoginFor,
        points: <String>[
          l10n.onboardingContentStaffSellRecordPayments,
          l10n.onboardingContentManagerEverythingStaffDo,
          l10n.onboardingContentAdminEverythingPlusUsers,
          l10n.onboardingContentAPersonWhoLeaves,
        ],
      ),
      OnboardingStep(
        icon: Icons.storefront_outlined,
        title: l10n.onboardingContentTheOnlineStore,
        body: l10n.onboardingContentCustomersOrderOnYour,
        points: <String>[
          l10n.onboardingContentOnlyActiveProductsWith,
          l10n.onboardingContentOrdersArriveHereAs,
          l10n.onboardingContentSwitchTheStoreOff,
          l10n.onboardingContentWithEMailSet,
        ],
      ),
      OnboardingStep(
        icon: Icons.history_outlined,
        title: l10n.onboardingContentActivityLogs,
        body: l10n.onboardingContentEveryChangeIsRecorded,
      ),
      OnboardingStep(
        icon: Icons.add_a_photo_outlined,
        title: l10n.onboardingContentPhotos,
        body: l10n.onboardingContentAddPhotosToProducts,
      ),
      _offline(l10n),
      _profile(l10n),
    ];

/// The welcome guide for a role. Everyone sees the pages that matter to them.
List<OnboardingStep> onboardingStepsFor(UserRole role, AppLocalizations l10n) {
  switch (role) {
    case UserRole.admin:
      return _admin(l10n);
    case UserRole.manager:
      return _manager(l10n);
    case UserRole.staff:
      return _staff(l10n);
  }
}
