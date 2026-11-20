// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'A2 Stocks';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonSomethingWentWrong => 'Something went wrong.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInToContinue => 'Sign in to continue';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authEmailRequired => 'Email is required.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String authError(Object error) {
    return 'Authentication error: $error';
  }

  @override
  String get accessNotRegistered =>
      'Your account is not registered in A2 Stocks. Contact your administrator.';

  @override
  String get accessInactive =>
      'Your account is inactive. Contact your administrator.';

  @override
  String get accessCouldNotVerify => 'Your account could not be verified.';

  @override
  String get categoriesStatus => 'Status';

  @override
  String get categoriesProducts => 'Products';

  @override
  String get categoriesParent => 'Parent';

  @override
  String get categoriesCategorySubcategory => 'Category / Subcategory';

  @override
  String categoriesDirectlyInInIts(
      Object directProducts, Object name, Object productsInSubcategories) {
    return '$directProducts directly in $name\n$productsInSubcategories in its subcategories';
  }

  @override
  String get categoriesSubcategories => 'Subcategories';

  @override
  String get categoriesCategory => 'Category';

  @override
  String get categoriesNoCategoriesMatch => 'No categories match.';

  @override
  String get categoriesAddCategory => 'Add category';

  @override
  String get categoriesStarterPacks => 'Starter packs';

  @override
  String get categoriesCategories => 'Categories';

  @override
  String get categoriesSearchCategories => 'Search categories';

  @override
  String get categoriesWithoutProducts => 'Without products';

  @override
  String get categoriesSubcategoriesInTotal => 'Subcategories in total';

  @override
  String get categoriesMainCategories => 'Main categories';

  @override
  String get categoriesStartFromATemplate => 'Start from a template';

  @override
  String get categoriesStartFromAReady =>
      'Start from a ready-made set for your kind of business, or add them one by one.';

  @override
  String get categoriesNoCategoriesYet => 'No categories yet.';

  @override
  String get categoriesDelete => 'Delete';

  @override
  String get categoriesEdit => 'Edit';

  @override
  String get categoriesAddSubcategory => 'Add subcategory';

  @override
  String get categoriesActions => 'Actions';

  @override
  String get categoriesCancel => 'Cancel';

  @override
  String categoriesDelete2(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get categoriesDeleteCategory => 'Delete category';

  @override
  String categoriesAddedCategories(Object created, Object already) {
    return 'Added $created categories$already.';
  }

  @override
  String get categoryFormActive => 'Active';

  @override
  String get categoryFormDescriptionOptional => 'Description (optional)';

  @override
  String get categoryFormNoneTopLevel => 'None (top level)';

  @override
  String get categoryFormParentCategory => 'Parent category';

  @override
  String get categoryFormName => 'Name';

  @override
  String get categoryFormCategoryPhoto => 'Category photo';

  @override
  String get productsAddProduct => 'Add product';

  @override
  String get productsInactive => 'Inactive';

  @override
  String get productsSearchNameBrandSku => 'Search name, brand, SKU or barcode';

  @override
  String get productsBrands => 'Brands';

  @override
  String get productsVariants => 'Variants';

  @override
  String productsDeleteAndItsVariant(Object name, int length) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length variants',
      one: '$length variant',
    );
    return 'Delete \"$name\" and its $_temp0?';
  }

  @override
  String get productsDeleteProduct => 'Delete product';

  @override
  String get productFormAddAtLeastOne => 'Add at least one variant.';

  @override
  String get productFormAddVariant => 'Add variant';

  @override
  String productFormVariants(Object length) {
    return 'Variants ($length)';
  }

  @override
  String get productFormBrandOptional => 'Brand (optional)';

  @override
  String get productFormProductName => 'Product name';

  @override
  String get productFormRemoveVariant => 'Remove variant';

  @override
  String get starterPackPickTheKindOf =>
      'Pick the kind of business you run and we will add a ready-made set of categories. You can rename, move or delete any of them afterwards.';

  @override
  String starterPackStarterPacksNeedA(Object value) {
    return '$value\nStarter packs need a connection to the server.';
  }

  @override
  String get starterPackClose => 'Close';

  @override
  String get starterPackBackToTheList => 'Back to the list';

  @override
  String get variantSaveVariant => 'Save variant';

  @override
  String get variantAddAttribute => 'Add attribute';

  @override
  String get variantRemoveAttribute => 'Remove attribute';

  @override
  String get variantSmall => 'Small';

  @override
  String get variantValue => 'Value';

  @override
  String get variantSize => 'Size';

  @override
  String get variantAttributes => 'Attributes';

  @override
  String get variantFlagThisVariantWhen =>
      'Flag this variant when stock is at or below this number. 0 = no alert.';

  @override
  String get variantLowStockAlertLevel => 'Low-stock alert level';

  @override
  String get variantWholesalePrice => 'Wholesale price';

  @override
  String get variantCostPrice => 'Cost price';

  @override
  String get variantAddsASeparateWholesale => 'Adds a separate wholesale price';

  @override
  String get variantWholesaleVariant => 'Wholesale variant';

  @override
  String get variantBarcodeOptional => 'Barcode (optional)';

  @override
  String get variantVariantNameOptional => 'Variant name (optional)';

  @override
  String get variantAutoCreateSku => 'Auto-create SKU';

  @override
  String get variantSku => 'SKU';

  @override
  String get dashboardTopCategories => 'Top categories';

  @override
  String dashboardOrderS(int value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value orders',
      one: '$value order',
    );
    return '$_temp0';
  }

  @override
  String get dashboardTopCustomers => 'Top customers';

  @override
  String get dashboardRecentSales => 'Recent sales';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardLowStock => 'Low stock';

  @override
  String get dashboardTopSelling => 'Top selling';

  @override
  String get dashboardOverallInformation => 'Overall information';

  @override
  String get dashboardWalkInSalesHave =>
      'Walk-in sales have no customer record, so they are counted on their own and are never new or returning.';

  @override
  String get dashboardNewVsReturningCustomers => 'New vs returning customers';

  @override
  String get dashboardTotalSales => 'Total sales  ';

  @override
  String get dashboardSales => 'Sales';

  @override
  String get dashboardViewStock => 'View stock';

  @override
  String dashboardHasLeft(Object onHand, Object more) {
    return ' has $onHand left$more. ';
  }

  @override
  String get dashboardRunningLow => 'Running low: ';

  @override
  String get dashboardUnitsInStock => 'Units in stock';

  @override
  String get dashboardPotentialMargin => 'Potential margin';

  @override
  String get dashboardStockAtRetail => 'Stock at retail';

  @override
  String get dashboardStockAtCost => 'Stock at cost';

  @override
  String get dashboardPendingOrders => 'Pending orders';

  @override
  String get dashboardSalesThisMonth => 'Sales this month';

  @override
  String get dashboardSalesToday => 'Sales today';

  @override
  String dashboardYouHaveOrderS(int ordersToday, Object value) {
    String _temp0 = intl.Intl.pluralLogic(
      ordersToday,
      locale: localeName,
      other: '$ordersToday orders',
      one: '$ordersToday order',
    );
    return 'You have $_temp0 today · $value';
  }

  @override
  String dashboardWelcome(Object value) {
    return 'Welcome, $value';
  }

  @override
  String get dashboardNoModulesAvailableFor =>
      'No modules available for your role yet.';

  @override
  String get homePos => 'POS';

  @override
  String get homeMenu => 'Menu';

  @override
  String activityLogsAllS(Object value) {
    return 'All ${value}s';
  }

  @override
  String activityLogsLinked(Object related) {
    return '$related linked';
  }

  @override
  String get activityLogsActivityLogs => 'Activity Logs';

  @override
  String get activityLogsClear => 'Clear';

  @override
  String get activityLogsLinkedEntries => 'Linked entries';

  @override
  String get activityLogsUser => 'User';

  @override
  String get activityLogsModule => 'Module';

  @override
  String get activityLogsType => 'Type';

  @override
  String get activityLogsAllLevels => 'All levels';

  @override
  String get activityLogsSearchSummaryRecordUser =>
      'Search summary, record, user, field or #id…';

  @override
  String get activityLogsOnlyAdminsCanView =>
      'Only admins can view the activity logs.';

  @override
  String get activityLogsShowLinked => 'Show linked';

  @override
  String get activityLogsCopy => 'Copy';

  @override
  String get activityLogsLogCopied => 'Log copied.';

  @override
  String get activityLogsChanges => 'Changes';

  @override
  String get onboardingContentAddPhotosToProducts =>
      'Add photos to products (several each), categories, customers, vendors and users. Your own photo is in Settings.';

  @override
  String get onboardingContentPhotos => 'Photos';

  @override
  String get onboardingContentEveryChangeIsRecorded =>
      'Every change is recorded with who did it and when. Open Activity Logs to see sales, price changes, logins and more.';

  @override
  String get onboardingContentActivityLogs => 'Activity logs';

  @override
  String get onboardingContentCustomersOrderOnYour =>
      'Customers order on your website and pay cash on delivery.';

  @override
  String get onboardingContentTheOnlineStore => 'The online store';

  @override
  String get onboardingContentCreateALoginFor =>
      'Create a login for everyone under Users. Nobody should share one.';

  @override
  String get onboardingContentYourTeam => 'Your team';

  @override
  String get onboardingContentDoTheseOnceIn => 'Do these once, in this order:';

  @override
  String get onboardingContentFirstSetupChecklist => 'First setup checklist';

  @override
  String get onboardingContentYouAreSignedIn =>
      'You are signed in as Admin: you can see and change everything. Here is how to get the shop ready.';

  @override
  String get onboardingContentWelcomeToA2Stocks => 'Welcome to A2 Stocks';

  @override
  String get onboardingContentAddPhotosToProducts2 =>
      'Add photos to products, categories, customers and vendors. Product photos appear in the online store.';

  @override
  String get onboardingContentCountTheShelfIn =>
      'Count the shelf in Stock Audit; confirming it corrects the system to what you counted.';

  @override
  String get onboardingContentStockAndAudits => 'Stock and audits';

  @override
  String get onboardingContentVendorsAndPurchasesRecord =>
      'Vendors and Purchases record what you buy and what you owe. Confirming a purchase adds the stock.';

  @override
  String get onboardingContentBuyingStock => 'Buying stock';

  @override
  String get onboardingContentSalesOrdersHoldsEvery =>
      'Sales & Orders holds every order: from the counter and from the online store.';

  @override
  String get onboardingContentSalesAndOnlineOrders => 'Sales and online orders';

  @override
  String get onboardingContentTheHomeScreenShows =>
      'The home screen shows today\'s and this month\'s sales, what customers owe, low stock and the best sellers.';

  @override
  String get onboardingContentYourDashboard => 'Your dashboard';

  @override
  String get onboardingContentYouAreSignedIn2 =>
      'You are signed in as Manager: you run the shop day to day. This tour shows where things are.';

  @override
  String get onboardingContentAddACustomerWhen =>
      'Add a customer when someone new buys. Their balance shows what they owe and the payments they made.';

  @override
  String get onboardingContentCustomers => 'Customers';

  @override
  String get onboardingContentLookUpProductsPrices =>
      'Look up products, prices and photos under Products, and what is on the shelf under Stock.';

  @override
  String get onboardingContentProductsAndStock => 'Products and stock';

  @override
  String get onboardingContentOpenSalesOrdersTo =>
      'Open Sales & Orders to make a sale.';

  @override
  String get onboardingContentSelling => 'Selling';

  @override
  String get onboardingContentYouAreSignedIn3 =>
      'You are signed in as Staff. This quick tour shows what you can do. It takes a minute.';

  @override
  String get onboardingContentOpenSettingsToAdd =>
      'Open Settings to add your own photo and to see this guide again whenever you like.';

  @override
  String get onboardingContentYourProfile => 'Your profile';

  @override
  String get onboardingContentOnPhonesAndComputers =>
      'On phones and computers the app keeps working when the internet is down and sends your work to the shop\'s server when the connection returns. On the web version a connection is needed all the time.';

  @override
  String get onboardingContentWorksWithOrWithout =>
      'Works with or without internet';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String onboardingWelcome(Object label) {
    return 'Welcome · $label';
  }

  @override
  String get customersAddCustomer => 'Add customer';

  @override
  String get customersNoCustomersYet => 'No customers yet.';

  @override
  String get ledgerEntrySaveEntry => 'Save entry';

  @override
  String get ledgerEntryReferenceReceiptNoOptional =>
      'Reference / receipt no. (optional)';

  @override
  String get ledgerEntryDate => 'Date';

  @override
  String get ledgerEntryAmount => 'Amount';

  @override
  String get ledgerEntryAddLedgerEntry => 'Add ledger entry';

  @override
  String get partyDetailAddEntry => 'Add entry';

  @override
  String get partyDetailDeleteEntry => 'Delete entry';

  @override
  String partyDetailBal(Object value) {
    return 'Bal $value';
  }

  @override
  String get partyDetailNoLedgerEntriesYet => 'No ledger entries yet.';

  @override
  String get partyDetailOpeningBalance => 'Opening balance';

  @override
  String get partyDetailLedger => 'Ledger';

  @override
  String get partyDetailThisRecordNoLonger => 'This record no longer exists.';

  @override
  String get partyFormInactivePartiesAreHidden =>
      'Inactive parties are hidden from pickers.';

  @override
  String get partyFormNotesOptional => 'Notes (optional)';

  @override
  String get partyForm0MeansNoLimit => '0 means no limit.';

  @override
  String get partyFormCreditLimit => 'Credit limit';

  @override
  String get partyFormCityOptional => 'City (optional)';

  @override
  String get partyFormAddressOptional => 'Address (optional)';

  @override
  String get partyFormEmailOptional => 'Email (optional)';

  @override
  String get partyFormPhone => 'Phone';

  @override
  String get partyFormContactPersonOptional => 'Contact person (optional)';

  @override
  String get vendorsAddVendor => 'Add vendor';

  @override
  String get vendorsVendors => 'Vendors';

  @override
  String get vendorsNoVendorsYet => 'No vendors yet.';

  @override
  String get heldSalesResume => 'Resume';

  @override
  String get heldSalesNoSalesOnHold => 'No sales on hold.';

  @override
  String get heldSalesHeldSales => 'Held sales';

  @override
  String get posPaymentCompleteSale => 'Complete sale';

  @override
  String get posPaymentBack => 'Back';

  @override
  String posPaymentGiveChange(Object prefix, Object value) {
    return 'Give change: $prefix$value';
  }

  @override
  String get posPaymentFullyPaid => 'Fully paid';

  @override
  String get posPaymentAddPayment => 'Add payment';

  @override
  String get posPaymentExact => 'Exact';

  @override
  String posPaymentLeftToPay(Object prefix, Object value) {
    return 'Left to pay: $prefix$value';
  }

  @override
  String get posPaymentRemoveThisPayment => 'Remove this payment';

  @override
  String posPaymentPay(Object prefix, Object value) {
    return 'Pay $prefix$value';
  }

  @override
  String get posYourLoginCannotMake => 'Your login cannot make sales.';

  @override
  String get posHold => 'Hold';

  @override
  String get posTotalPayable => 'Total Payable';

  @override
  String posItems(Object units) {
    return 'Items : $units';
  }

  @override
  String get posNoProductsSelected => 'No Products Selected';

  @override
  String get posClearSale => 'Clear sale';

  @override
  String get posNewSale => 'New sale';

  @override
  String get posOrderList => 'Order List';

  @override
  String get posApply => 'Apply';

  @override
  String get posNoProductsFound => 'No products found.';

  @override
  String get posAll => 'All';

  @override
  String posWelcome(Object who) {
    return 'Welcome, $who';
  }

  @override
  String get posSearchOrScanBarcode =>
      'Search, or scan barcode / SKU and press Enter';

  @override
  String get posDashboard => 'Dashboard';

  @override
  String posBalanceDue(Object prefix, Object value) {
    return 'Balance due: $prefix$value';
  }

  @override
  String get posSaleComplete => 'Sale complete';

  @override
  String get posCustomer => 'Customer';

  @override
  String get purchasesNewPurchase => 'New purchase';

  @override
  String get purchasesPurchases => 'Purchases';

  @override
  String purchasesOfPurchaseSShown(Object length, int length2) {
    String _temp0 = intl.Intl.pluralLogic(
      length2,
      locale: localeName,
      other: '$length2 purchases',
      one: '$length2 purchase',
    );
    return '$length of $_temp0 shown';
  }

  @override
  String get purchasesSearchPurchaseNoVendor =>
      'Search purchase no., vendor, invoice…';

  @override
  String get purchasesNotFullyPaid => 'Not fully paid';

  @override
  String get purchasesOwedToVendors => 'Owed to vendors';

  @override
  String get purchasesTotalPurchased => 'Total purchased';

  @override
  String get purchaseDetailSavePayment => 'Save payment';

  @override
  String get purchaseDetailNoteOptional => 'Note (optional)';

  @override
  String purchaseDetailDue(Object value) {
    return 'Due: $value';
  }

  @override
  String get purchaseDetailRecordPayment => 'Record payment';

  @override
  String get purchaseDetailNoPaymentsRecordedYet => 'No payments recorded yet.';

  @override
  String get purchaseDetailPayments => 'Payments';

  @override
  String purchaseDetailSku(Object sku) {
    return 'SKU $sku';
  }

  @override
  String purchaseDetailItemsUnits(Object length, Object totalUnits) {
    return 'Items ($length · $totalUnits units)';
  }

  @override
  String get purchaseDetailThisPurchaseNoLonger =>
      'This purchase no longer exists.';

  @override
  String get purchaseDetailPurchase => 'Purchase';

  @override
  String get purchaseFormConfirmingAddsTheQuantities =>
      'Confirming adds the quantities to stock and posts the purchase to the vendor ledger. It is uploaded to the cloud as one atomic change when you sync.';

  @override
  String get purchaseFormConfirmPurchase => 'Confirm purchase';

  @override
  String get purchaseFormPayLater => 'Pay later';

  @override
  String get purchaseFormPaidInFull => 'Paid in full';

  @override
  String get purchaseFormPaidNow => 'Paid now';

  @override
  String purchaseFormTotal(Object value) {
    return 'Total $value';
  }

  @override
  String get purchaseFormAddItem => 'Add item';

  @override
  String purchaseFormLineTotal(Object value) {
    return 'Line total $value';
  }

  @override
  String purchaseFormCatalog(Object value) {
    return 'Catalog $value';
  }

  @override
  String get purchaseFormBuyingPrice => 'Buying price';

  @override
  String get purchaseFormQuantity => 'Quantity';

  @override
  String get purchaseFormRemoveItem => 'Remove item';

  @override
  String get purchaseFormAddAtLeastOne => 'Add at least one item.';

  @override
  String get purchaseFormSupplierInvoiceNoOptional =>
      'Supplier invoice no. (optional)';

  @override
  String get purchaseFormConfirm => 'Confirm';

  @override
  String purchaseFormVendorItemSUnit(Object name, int length, int units,
      Object value, Object value2, Object value3) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length items',
      one: '$length item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      units,
      locale: localeName,
      other: '$units units',
      one: '$units unit',
    );
    return 'Vendor: $name\n$_temp0, $_temp1 will be added to stock.\n\nTotal: $value\nPaid now: $value2\nDue: $value3';
  }

  @override
  String get ordersNewOrder => 'New order';

  @override
  String get ordersSalesOrders => 'Sales & Orders';

  @override
  String ordersOfOrderSShown(Object length, int length2) {
    String _temp0 = intl.Intl.pluralLogic(
      length2,
      locale: localeName,
      other: '$length2 orders',
      one: '$length2 order',
    );
    return '$length of $_temp0 shown';
  }

  @override
  String get ordersAllTypes => 'All types';

  @override
  String get ordersSearchOrderNoOr => 'Search order no. or customer…';

  @override
  String get ordersOpenOrders => 'Open orders';

  @override
  String get ordersToCollect => 'To collect';

  @override
  String get ordersTotalSales => 'Total sales';

  @override
  String get orderDetailReceipt => 'Receipt';

  @override
  String get orderDetailNoHistoryRecorded => 'No history recorded.';

  @override
  String get orderDetailStatusHistory => 'Status history';

  @override
  String get orderDetailMessageOnWhatsapp => 'Message on WhatsApp';

  @override
  String get orderDetailCancelOrder => 'Cancel order';

  @override
  String orderDetailMarkAs(Object label) {
    return 'Mark as $label';
  }

  @override
  String get orderDetailCancelledTheStockWas =>
      'Cancelled. The stock was returned and the ledger charge reversed.';

  @override
  String get orderDetailThisOrderNoLonger => 'This order no longer exists.';

  @override
  String get orderDetailOrder => 'Order';

  @override
  String get orderDetailKeepOrder => 'Keep order';

  @override
  String orderDetailWillBeCancelledUnit(
      Object orderNo, int totalUnits, Object customerName) {
    String _temp0 = intl.Intl.pluralLogic(
      totalUnits,
      locale: localeName,
      other: '$totalUnits units',
      one: '$totalUnits unit',
    );
    return '$orderNo will be cancelled. $_temp0 go back into stock and the charge on $customerName\'s ledger is reversed. Money already received stays on the ledger as customer credit.';
  }

  @override
  String get orderDetailCancelThisOrder => 'Cancel this order?';

  @override
  String get orderDetailWhatsappCouldNotBe =>
      'WhatsApp could not be opened on this device.';

  @override
  String get orderDetailThisCustomerHasNo =>
      'This customer has no usable phone number. Add one to their record.';

  @override
  String get orderFormConfirmingTakesTheQuantities =>
      'Confirming takes the quantities out of stock and posts the order to the customer ledger. It is uploaded to the cloud as one atomic change when you sync.';

  @override
  String get orderFormConfirmOrder => 'Confirm order';

  @override
  String get orderFormDiscountOnTheWhole => 'Discount on the whole order';

  @override
  String get orderFormSaleType => 'Sale type';

  @override
  String get orderFormLineDiscount => 'Line discount';

  @override
  String get orderFormSellingPrice => 'Selling price';

  @override
  String orderFormCustomerSaleTypeItem(Object name, Object label, int length,
      int units, Object value, Object value2, Object value3) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length items',
      one: '$length item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      units,
      locale: localeName,
      other: '$units units',
      one: '$units unit',
    );
    return 'Customer: $name\nSale type: $label\n$_temp0, $_temp1 will be taken out of stock.\n\nTotal: $value\nPaid now: $value2\nDue: $value3';
  }

  @override
  String get orderFormAmt => 'Amt';

  @override
  String get settingsSendTestEMail => 'Send test e-mail';

  @override
  String get settingsSaveSettings => 'Save settings';

  @override
  String get settingsWhenOffTheWebsite =>
      'When off, the website shows a closed notice and takes no orders.';

  @override
  String get settingsStoreIsOpen => 'Store is open';

  @override
  String get settingsOnlyAnAdminCan => 'Only an admin can change these.';

  @override
  String get settingsOnlineStore => 'Online store';

  @override
  String get settingsSend => 'Send';

  @override
  String get settingsSendTo => 'Send to';

  @override
  String settingsTheStoreSettingsNeed(Object value) {
    return '$value\nThe store settings need a connection to the server.';
  }

  @override
  String get settingsCraftedWithLoveBy => 'Crafted with love by A2 Devs.';

  @override
  String get settingsPosInventorySoftware => 'POS & Inventory Software';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsAmountsAlreadyRecordedAre =>
      'Amounts already recorded are not converted: they keep their numbers.';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsShopName => 'Shop name';

  @override
  String get settingsButtonsSelectionsAndCharts =>
      'Buttons, selections and charts. A2 Stocks teal unless you pick your own.';

  @override
  String get settingsBrandColour => 'Brand colour';

  @override
  String get settingsLogo => 'Logo';

  @override
  String get settingsShopDetails => 'Shop details';

  @override
  String settingsTheShopDetailsNeed(Object value) {
    return '$value\nThe shop details need a connection to the server.';
  }

  @override
  String get settingsYourPhoto => 'Your photo';

  @override
  String get settingsSettings => 'Settings';

  @override
  String settingsAShortTourOf(Object label) {
    return 'A short tour of what you can do as $label.';
  }

  @override
  String get settingsWelcomeGuide => 'Welcome guide';

  @override
  String get settingsSomethingWentWrongPlease =>
      'Something went wrong. Please try again.';

  @override
  String get stockAuditNoStockAuditsYet => 'No stock audits yet.';

  @override
  String get stockAuditAuditHistory => 'Audit history';

  @override
  String get stockAuditOneMore => 'One more';

  @override
  String get stockAuditOneLess => 'One less';

  @override
  String get stockAuditEachDifferenceBecomesA =>
      'Each difference becomes a stock adjustment and is uploaded as one atomic change when you sync.';

  @override
  String get stockAuditApplyCount => 'Apply count';

  @override
  String stockAuditCountedDifferenceS(Object length, int differences) {
    String _temp0 = intl.Intl.pluralLogic(
      differences,
      locale: localeName,
      other: '$differences differences',
      one: '$differences difference',
    );
    return '$length counted · $_temp0';
  }

  @override
  String get stockAuditReasonNoteOptional => 'Reason / note (optional)';

  @override
  String get stockAuditNoItemsToShow => 'No items to show.';

  @override
  String get stockAuditClearCounts => 'Clear counts';

  @override
  String stockAuditCountedOnly(Object length) {
    return 'Counted only ($length)';
  }

  @override
  String get stockAuditSearchProductSkuBarcode =>
      'Search product, SKU, barcode…';

  @override
  String get stockAuditStockAudit => 'Stock audit';

  @override
  String get stockAuditOnlyAdminsAndManagers =>
      'Only admins and managers can count and adjust stock.';

  @override
  String get stockAuditStockCountApplied => 'Stock count applied.';

  @override
  String stockAuditItemSWillBe(int length) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length items',
      one: '$length item',
    );
    return '$_temp0 will be adjusted:';
  }

  @override
  String get stockAuditEveryCountedQuantityMatches =>
      'Every counted quantity matches the system, so nothing will be adjusted.';

  @override
  String get stockAuditApplyStockCount => 'Apply stock count';

  @override
  String stockItemSHaveNegative(int negativeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      negativeCount,
      locale: localeName,
      other: '$negativeCount items',
      one: '$negativeCount item',
    );
    return '$_temp0 have negative stock. More was sold than was in stock, for example on two devices before they synced. Check the stock ledger and add a correction.';
  }

  @override
  String stockItemSUnitS(int length, int totalUnits) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length items',
      one: '$length item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalUnits,
      locale: localeName,
      other: '$totalUnits units',
      one: '$totalUnits unit',
    );
    return '$_temp0 · $_temp1 in stock';
  }

  @override
  String get stockOutOfStock => 'Out of stock';

  @override
  String get stockStockValueCost => 'Stock value (cost)';

  @override
  String get stockAudit => 'Audit';

  @override
  String get stockStock => 'Stock';

  @override
  String get syncDiscard => 'Discard';

  @override
  String get syncRetry => 'Retry';

  @override
  String syncWaitingForTheServer(Object length) {
    return 'Waiting for the server ($length)';
  }

  @override
  String get syncNothingIsWaitingTo => 'Nothing is waiting to be uploaded.';

  @override
  String get syncDownloadEverythingAgain => 'Download everything again';

  @override
  String get syncMore => 'More';

  @override
  String get syncSync => 'Sync';

  @override
  String get syncDownloadAgain => 'Download again';

  @override
  String get syncThisReplacesThisDevice =>
      'This replaces this device\'s copy of the data with the server\'s. Changes that are waiting to be uploaded are kept.';

  @override
  String get syncDownloadEverythingAgain2 => 'Download everything again?';

  @override
  String get usersAddUser => 'Add user';

  @override
  String get usersUsers => 'Users';

  @override
  String get usersManagersStaff => 'Managers & staff';

  @override
  String get usersAdmins => 'Admins';

  @override
  String get usersNoUsersYet => 'No users yet.';

  @override
  String get usersDeleteUser => 'Delete user';

  @override
  String get userFormRole => 'Role';

  @override
  String get userFormPhoneOptional => 'Phone (optional)';

  @override
  String get userFormShareItWithThe =>
      'Share it with the user so they can sign in.';

  @override
  String get userFormInitialPassword => 'Initial password';

  @override
  String get userFormEmailLogin => 'Email (login)';

  @override
  String get userFormFullName => 'Full name';

  @override
  String get userFormProfilePhoto => 'Profile photo';

  @override
  String get businessBrandCraftedWithLoveBy => 'Crafted with love by';

  @override
  String get businessBrandPoweredBy => 'Powered by';

  @override
  String get logoutButtonSignOutFailed => 'Sign out failed.';

  @override
  String orderReceiptCardDue(Object value) {
    return 'Due $value';
  }

  @override
  String get orderReceiptCardTotal => 'Total';

  @override
  String get orderReceiptCardNoItems => 'No items';

  @override
  String get partyListNoMatchesTryChanging =>
      'No matches. Try changing the search or filters.';

  @override
  String get partyListShowInactive => 'Show inactive';

  @override
  String get partyListOverCreditLimit => 'Over credit limit';

  @override
  String get partyListWithBalance => 'With balance';

  @override
  String get partyListSearchNamePhoneCity => 'Search name, phone, city…';

  @override
  String get partyListSettled => 'Settled';

  @override
  String get partyListWithABalance => 'With a balance';

  @override
  String get partyPickerSelectCustomer => 'Select customer';

  @override
  String get partyPickerSelectVendor => 'Select vendor';

  @override
  String get photoWidgetsDeletePhoto => 'Delete photo';

  @override
  String get photoWidgetsMakeMainPhoto => 'Make main photo';

  @override
  String get photoWidgetsMain => 'Main';

  @override
  String get photoWidgetsNoPhotosYetThe =>
      'No photos yet. The first photo is the main one shown in the shop and on the online store.';

  @override
  String get photoWidgetsAddPhoto => 'Add photo';

  @override
  String photoWidgetsOf10(Object length) {
    return '($length of 10)';
  }

  @override
  String photoWidgetsSaveFirstThenOpen(Object what) {
    return 'Save first, then open this again to add $what.';
  }

  @override
  String get photoWidgetsRemove => 'Remove';

  @override
  String get photoWidgetsThePhotoCouldNot =>
      'The photo could not be saved. Please try again.';

  @override
  String get receiptActionsWhatsapp => 'WhatsApp';

  @override
  String get receiptActionsSharePdf => 'Share PDF';

  @override
  String get receiptActionsViewReceipt => 'View receipt';

  @override
  String get receiptActionsPrintReceipt => 'Print Receipt';

  @override
  String get receiptActionsOpenWhatsapp => 'Open WhatsApp';

  @override
  String get receiptActionsCustomerPhone => 'Customer phone';

  @override
  String get receiptActionsWhatsappNumber => 'WhatsApp number';

  @override
  String get receiptActionsThatIsNotA => 'That is not a usable phone number.';

  @override
  String get receiptActionsThatDidNotWork =>
      'That did not work on this device. Please try again.';

  @override
  String get receiptThankYouForShopping =>
      'Thank you for shopping with us. Please come again.';

  @override
  String receiptDiscount(Object value) {
    return 'Discount -$value';
  }

  @override
  String get receiptQty => 'Qty';

  @override
  String get receiptPrice => 'Price';

  @override
  String get receiptItem => '# Item';

  @override
  String get receiptSalesReceipt => 'Sales Receipt';

  @override
  String receiptPhoneNumber(Object shopPhone) {
    return 'Phone Number : $shopPhone';
  }

  @override
  String variantPickerStock(Object onHand) {
    return 'Stock $onHand';
  }

  @override
  String get variantPickerNoMatchingItems => 'No matching items.';

  @override
  String get variantPickerSelectItem => 'Select item';

  @override
  String get dateLong => 'EEEE, d MMMM y';

  @override
  String get dateShort => 'EEE, d MMMM y';

  @override
  String get categoriesNoSubcategoriesMatch => 'No subcategories match.';

  @override
  String get categoriesNoSubcategoriesYet => 'No subcategories yet.';

  @override
  String get categoriesCategoriesWithNothingIn =>
      'categories with nothing in them';

  @override
  String categoriesYouAlreadyHadWere(Object skipped) {
    return ' ($skipped you already had were left as they are)';
  }

  @override
  String get categoryFormCreateCategory => 'Create category';

  @override
  String get categoryFormSaveChanges => 'Save changes';

  @override
  String get categoryFormNameIsRequired => 'Name is required.';

  @override
  String get categoryFormEditCategory => 'Edit category';

  @override
  String get productsNoProductsMatchYour => 'No products match your search.';

  @override
  String get productsNoProductsYet => 'No products yet.';

  @override
  String productsInactive2(Object value) {
    return '$value inactive';
  }

  @override
  String get productFormCreateProduct => 'Create product';

  @override
  String get productFormChooseACategory => 'Choose a category.';

  @override
  String get productFormCreateACategoryFirst => 'Create a category first.';

  @override
  String get productFormEditProduct => 'Edit product';

  @override
  String get productFormProduct => 'Product';

  @override
  String productFormCostSale(Object cost, Object sale) {
    return 'Cost $cost · Sale $sale';
  }

  @override
  String productFormCostWholesaleRetail(
      Object cost, Object value, Object sale) {
    return 'Cost $cost · Wholesale $value · Retail $sale';
  }

  @override
  String starterPackAddCategories(Object toAdd) {
    return 'Add $toAdd categories';
  }

  @override
  String get starterPackNothingNewToAdd => 'Nothing new to add';

  @override
  String get starterPackYouAlreadyHaveEverything =>
      'You already have everything you ticked.';

  @override
  String get starterPackTickAtLeastOne => 'Tick at least one group.';

  @override
  String get starterPackSelectAll => 'Select all';

  @override
  String get starterPackSelectNone => 'Select none';

  @override
  String get starterPackOtherKindsOfStore => 'Other kinds of store';

  @override
  String get starterPackStoresLikeYours => 'Stores like yours';

  @override
  String get starterPackStarterCategories => 'Starter categories';

  @override
  String get variantEnter0OrA => 'Enter 0 or a whole number.';

  @override
  String get variantSalePrice => 'Sale price';

  @override
  String get variantRetailPrice => 'Retail price';

  @override
  String get variantSkuIsRequired => 'SKU is required.';

  @override
  String get variantVariant => 'Variant';

  @override
  String get variantEnterTheProductName =>
      'Enter the product name or an attribute value first.';

  @override
  String get variantEnterAValidPrice => 'Enter a valid price.';

  @override
  String get dashboardNoCategorySalesYet => 'No category sales yet.';

  @override
  String get dashboardNoNamedCustomersHave =>
      'No named customers have bought yet.';

  @override
  String get dashboardWalkInCustomer => 'Walk-in customer';

  @override
  String get dashboardNoSalesYet => 'No sales yet.';

  @override
  String dashboardLeft(Object value) {
    return '$value left';
  }

  @override
  String get dashboardNothingIsRunningLow => 'Nothing is running low.';

  @override
  String dashboardSold(Object value) {
    return '$value sold';
  }

  @override
  String get dashboardNoSalesInThis => 'No sales in this period yet.';

  @override
  String get dashboardOrders => 'Orders';

  @override
  String get dashboardNoNamedCustomersBought =>
      'No named customers bought in this period.';

  @override
  String get dashboardWalkInOrders => 'Walk-in orders';

  @override
  String dashboardOfBuyers(Object returningPercent) {
    return '$returningPercent% of buyers';
  }

  @override
  String get dashboardReturningCustomers => 'Returning customers';

  @override
  String get dashboardFirstOrderInThis => 'first order in this period';

  @override
  String get dashboardNewCustomers => 'New customers';

  @override
  String dashboardAndMore(Object value) {
    return ' and $value more';
  }

  @override
  String get dashboardAtOrBelowAlert => 'at or below alert level';

  @override
  String get dashboardAllAboveAlertLevel => 'All above alert level';

  @override
  String dashboardProcessingShipped(
      Object processingOrders, Object shippedOrders) {
    return '$processingOrders processing · $shippedOrders shipped';
  }

  @override
  String dashboardOrderS2(int ordersMonth) {
    String _temp0 = intl.Intl.pluralLogic(
      ordersMonth,
      locale: localeName,
      other: '$ordersMonth orders',
      one: '$ordersMonth order',
    );
    return '$_temp0';
  }

  @override
  String dashboardOrderS3(int ordersToday) {
    String _temp0 = intl.Intl.pluralLogic(
      ordersToday,
      locale: localeName,
      other: '$ordersToday orders',
      one: '$ordersToday order',
    );
    return '$_temp0';
  }

  @override
  String get homeCollapseMenu => 'Collapse menu';

  @override
  String get homeExpandMenu => 'Expand menu';

  @override
  String get homeHome => 'Home';

  @override
  String activityLogsChangeS(int length) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length changes',
      one: '$length change',
    );
    return '$_temp0';
  }

  @override
  String get activityLogsLoadFromCloud => 'Load from cloud';

  @override
  String get activityLogsRefreshCloud => 'Refresh cloud';

  @override
  String get activityLogsNoLogsMatchThe => 'No logs match the filters.';

  @override
  String get activityLogsNoLogsOnThis => 'No logs on this device yet.';

  @override
  String activityLogsModuleRecord(
      Object module, Object entityLabel, Object entityId) {
    return 'Module: $module  Record: $entityLabel ($entityId)';
  }

  @override
  String activityLogsUser2(Object userName, Object userRole) {
    return 'User: $userName $userRole';
  }

  @override
  String get activityLogsRemoved => '(removed)';

  @override
  String get activityLogsNone => '(none)';

  @override
  String get activityLogsLogId => 'Log id';

  @override
  String get activityLogsGroup => 'Group';

  @override
  String get activityLogsRecordId => 'Record id';

  @override
  String get activityLogsRecord => 'Record';

  @override
  String get activityLogsLevelType => 'Level / type';

  @override
  String get activityLogsTime => 'Time';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get ledgerEntryEnterAnAmountGreater =>
      'Enter an amount greater than zero.';

  @override
  String partyDetailRef(Object reference) {
    return 'Ref $reference';
  }

  @override
  String partyDetailCreditLimit(Object value) {
    return 'Credit limit $value';
  }

  @override
  String partyDetailOverTheCreditLimit(Object value) {
    return 'Over the credit limit of $value';
  }

  @override
  String partyDetailDeleteThisOf(Object value, Object value2) {
    return 'Delete this $value of $value2?';
  }

  @override
  String partyDetailDelete(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String partyDetailDelete2(Object value) {
    return 'Delete $value';
  }

  @override
  String partyFormCreate(Object noun) {
    return 'Create $noun';
  }

  @override
  String get partyFormEnterAValidAmount => 'Enter a valid amount.';

  @override
  String get partyFormPositiveYouOweThe =>
      'Positive: you owe the vendor. Negative: advance paid.';

  @override
  String get partyFormPositiveTheCustomerOwes =>
      'Positive: the customer owes you. Negative: advance received.';

  @override
  String get partyFormEnterAValidPhone => 'Enter a valid phone number.';

  @override
  String get partyFormNameBusinessName => 'Name / business name';

  @override
  String get partyFormNameShopName => 'Name / shop name';

  @override
  String get partyFormVendorPhotoLogo => 'Vendor photo / logo';

  @override
  String get partyFormCustomerPhotoShopFront => 'Customer photo / shop front';

  @override
  String partyFormAdd(Object noun) {
    return 'Add $noun';
  }

  @override
  String partyFormEdit(Object noun) {
    return 'Edit $noun';
  }

  @override
  String heldSalesAndMore(Object names, Object more) {
    return '$names and $more more';
  }

  @override
  String heldSalesDAgo(Object inDays) {
    return '$inDays d ago';
  }

  @override
  String heldSalesHAgo(Object inHours) {
    return '$inHours h ago';
  }

  @override
  String heldSalesMinAgo(Object inMinutes) {
    return '$inMinutes min ago';
  }

  @override
  String get heldSalesJustNow => 'just now';

  @override
  String posPaymentSellWithDue(Object prefix, Object value) {
    return 'Sell with $prefix$value due';
  }

  @override
  String get posPaymentSellOnCredit => 'Sell on credit';

  @override
  String get posPaymentTransactionNo => 'Transaction no.';

  @override
  String get posPaymentBankAndTransactionNo => 'Bank and transaction no.';

  @override
  String get posPaymentCashReceived => 'Cash received';

  @override
  String posPlaceOrder(Object prefix, Object value) {
    return 'Place Order · $prefix$value';
  }

  @override
  String get posPlaceOrder2 => 'Place Order';

  @override
  String get posBank => 'Bank';

  @override
  String get posDiscount => 'Discount';

  @override
  String get posSubTotal => 'Sub Total';

  @override
  String get posOrderDetails => 'Order Details';

  @override
  String get posMayPayNowOr => 'May pay now or later';

  @override
  String get posPaysInFullNow => 'Pays in full now';

  @override
  String get posCustomerInformation => 'Customer Information';

  @override
  String get posHeld => 'Held';

  @override
  String posHeld2(Object heldCount) {
    return 'Held ($heldCount)';
  }

  @override
  String posDiscountOn(Object productName) {
    return 'Discount on $productName';
  }

  @override
  String get posDiscountOnTheWhole => 'Discount on the whole sale';

  @override
  String posLeft(Object onHand) {
    return '$onHand left';
  }

  @override
  String get posPayment => 'Payment';

  @override
  String get posVoid => 'Void';

  @override
  String get posViewOrders => 'View Orders';

  @override
  String posSale(Object prefix, Object value) {
    return 'Sale · $prefix$value';
  }

  @override
  String get posSale2 => 'Sale';

  @override
  String get posHeldSaleResumedThe =>
      'Held sale resumed. The previous sale is now on hold.';

  @override
  String get posHeldSaleResumed => 'Held sale resumed.';

  @override
  String get posSalePutOnHold => 'Sale put on hold. Find it under \"Held\".';

  @override
  String get posTheSaleCouldNot => 'The sale could not be completed.';

  @override
  String get posTheWalkInCustomer =>
      'The walk-in customer is not on this device yet. Sync once, then try again.';

  @override
  String posNoProductWithBarcode(Object value) {
    return 'No product with barcode or SKU \"$value\".';
  }

  @override
  String posHasNoActiveVariant(Object name) {
    return '\"$name\" has no active variant.';
  }

  @override
  String posOnlyOfInStock(Object onHand, Object name, Object label) {
    return 'Only $onHand of \"$name · $label\" in stock.';
  }

  @override
  String posIsOutOfStock(Object name, Object label) {
    return '\"$name · $label\" is out of stock.';
  }

  @override
  String purchasesInv(Object invoiceNo) {
    return 'Inv $invoiceNo';
  }

  @override
  String purchasesItemS(int length) {
    String _temp0 = intl.Intl.pluralLogic(
      length,
      locale: localeName,
      other: '$length items',
      one: '$length item',
    );
    return '$_temp0';
  }

  @override
  String get purchasesNoPurchasesMatchYour => 'No purchases match your search.';

  @override
  String get purchasesNoPurchasesYet => 'No purchases yet.';

  @override
  String get purchaseDetailMoreThanTheAmount => 'More than the amount due.';

  @override
  String get purchaseDetailDue2 => 'Due';

  @override
  String get purchaseDetailPaid => 'Paid';

  @override
  String purchaseDetailInvoice(Object invoiceNo) {
    return 'Invoice $invoiceNo';
  }

  @override
  String get purchaseFormMoreThanThePurchase => 'More than the purchase total.';

  @override
  String get purchaseFormInvalidPrice => 'Invalid price';

  @override
  String get purchaseFormAtLeast1 => 'At least 1';

  @override
  String get purchaseFormItemsAndQuantities => 'Items and quantities';

  @override
  String get purchaseFormChooseAVendor => 'Choose a vendor.';

  @override
  String get purchaseFormVendor => 'Vendor';

  @override
  String get ordersNoOrdersMatchYour => 'No orders match your search.';

  @override
  String get ordersNoOrdersYet => 'No orders yet.';

  @override
  String get ordersNotYetDelivered => 'not yet delivered';

  @override
  String ordersOrderS(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '$count order',
    );
    return '$_temp0';
  }

  @override
  String ordersOrderS2(int todayCount) {
    String _temp0 = intl.Intl.pluralLogic(
      todayCount,
      locale: localeName,
      other: '$todayCount orders',
      one: '$todayCount order',
    );
    return '$_temp0';
  }

  @override
  String get orderDetailEnterTheTransactionNumber =>
      'Enter the transaction number.';

  @override
  String orderDetailDiscount(Object value) {
    return 'Discount $value';
  }

  @override
  String orderDetailSku(Object sku) {
    return 'SKU $sku';
  }

  @override
  String orderDetailBy(Object byName) {
    return 'by $byName';
  }

  @override
  String get orderDetailDelivery => 'Delivery';

  @override
  String get orderDetailDiscountsLinesAndOrder => 'Discounts (lines and order)';

  @override
  String get orderDetailSubtotal => 'Subtotal';

  @override
  String get orderFormMoreThanTheOrder => 'More than the order total.';

  @override
  String get orderFormOrderDiscount => 'Order discount';

  @override
  String get orderFormItemsQuantitiesAndPrices =>
      'Items, quantities and prices';

  @override
  String get orderFormChooseACustomer => 'Choose a customer.';

  @override
  String orderFormSellingBelowTheCost(Object value) {
    return 'Selling below the cost price ($value).';
  }

  @override
  String orderFormSkuInStock(Object sku, Object onHand) {
    return 'SKU $sku · In stock: $onHand';
  }

  @override
  String orderFormSkuOnlyInStock(Object sku, Object onHand, Object requested) {
    return 'SKU $sku · Only $onHand in stock, $requested requested';
  }

  @override
  String get orderFormMoreThanTheAmount => 'More than the amount';

  @override
  String get orderFormMax100 => 'Max 100%';

  @override
  String get orderFormInvalidDiscount => 'Invalid discount';

  @override
  String get settingsEnterAWholeNumber => 'Enter a whole number, 0 or more.';

  @override
  String get settingsCustomersNeverSeeExact =>
      'Customers never see exact numbers.';

  @override
  String get settingsShowLowStockAt => 'Show \"Low stock\" at or below';

  @override
  String get settingsStockDisplay => 'Stock display';

  @override
  String get settings0NeverFree => '0 = never free';

  @override
  String get settingsFreeDeliveryFrom => 'Free delivery from';

  @override
  String get settingsDeliveryFee => 'Delivery fee';

  @override
  String get settingsForExampleDeliveryTimes => 'For example delivery times.';

  @override
  String get settingsNoteAtCheckout => 'Note at checkout';

  @override
  String get settingsCheckoutDelivery => 'Checkout & delivery';

  @override
  String get settingsLeaveEmptyForNo => 'Leave empty for no alerts.';

  @override
  String get settingsSendNewOrderAlerts => 'Send new-order alerts to (e-mail)';

  @override
  String get settingsShownInTheWebsite => 'Shown in the website footer.';

  @override
  String get settingsContactPhone => 'Contact phone';

  @override
  String get settingsEnterTheStoreName => 'Enter the store name.';

  @override
  String get settingsStoreName => 'Store name';

  @override
  String get settingsContactAlerts => 'Contact & alerts';

  @override
  String get settingsEMailIsNot =>
      'E-mail is not set up on the server yet (SMTP_HOST is empty). See docs/deploy.md.';

  @override
  String get settingsTheMailServerRefused =>
      'The mail server refused or could not be reached. Check the SMTP settings on the server.';

  @override
  String settingsTestEMailSent(Object address) {
    return 'Test e-mail sent to $address. Check the inbox (and the spam folder).';
  }

  @override
  String get settingsEnterAValidE => 'Enter a valid e-mail address.';

  @override
  String get settingsSavedTheStoreIs =>
      'Saved. The store is closed: it takes no orders.';

  @override
  String get settingsSavedTheStoreIs2 => 'Saved. The store is open.';

  @override
  String get settingsEnterAnAmountOf => 'Enter an amount of 0 or more.';

  @override
  String get settingsSlate => 'Slate';

  @override
  String get settingsDarkTeal => 'Dark teal';

  @override
  String get settingsGreen => 'Green';

  @override
  String get settingsGold => 'Gold';

  @override
  String get settingsOrange => 'Orange';

  @override
  String get settingsRed => 'Red';

  @override
  String get settingsPink => 'Pink';

  @override
  String get settingsMagenta => 'Magenta';

  @override
  String get settingsViolet => 'Violet';

  @override
  String get settingsBlue => 'Blue';

  @override
  String get settingsA2StocksTeal => 'A2 Stocks teal';

  @override
  String get settingsEnterTheShopName => 'Enter the shop name.';

  @override
  String get settingsPrintedAtTheTop =>
      'Printed at the top of your receipts and in messages to customers.';

  @override
  String get settingsTheCurrencyEveryAmount =>
      'The currency every amount in the app is written in.';

  @override
  String get settingsTheWelcomeTour => 'The welcome tour';

  @override
  String get settingsHelpGuide => 'Help & guide';

  @override
  String get settingsCurrencyAndReceiptDetails =>
      'Currency and receipt details';

  @override
  String get settingsOpeningDeliveryAndAlerts => 'Opening, delivery and alerts';

  @override
  String get settingsYourNameEMail => 'Your name, e-mail and photo';

  @override
  String get settingsProfile => 'Profile';

  @override
  String stockAuditBy(Object countedByName) {
    return 'by $countedByName';
  }

  @override
  String stockLowStock(Object lowCount) {
    return 'Low stock ($lowCount)';
  }

  @override
  String get stockInStock => 'In stock';

  @override
  String stockItemS(int items) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items items',
      one: '$items item',
    );
    return '$_temp0';
  }

  @override
  String get syncSyncNow => 'Sync now';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String syncLastChecked(Object value) {
    return 'Last checked $value.';
  }

  @override
  String get syncNothingIsWaiting => 'Nothing is waiting.';

  @override
  String get syncInStepWithThe => 'In step with the server';

  @override
  String get syncTheyAreUploadedAutomatically =>
      'They are uploaded automatically in a few seconds.';

  @override
  String syncChangeSToUpload(int waiting) {
    String _temp0 = intl.Intl.pluralLogic(
      waiting,
      locale: localeName,
      other: '$waiting changes',
      one: '$waiting change',
    );
    return '$_temp0 to upload';
  }

  @override
  String get syncEverythingYouDoIs =>
      'Everything you do is saved on this device and uploaded later.';

  @override
  String syncChangeSAreSaved(int waiting) {
    String _temp0 = intl.Intl.pluralLogic(
      waiting,
      locale: localeName,
      other: '$waiting changes',
      one: '$waiting change',
    );
    return '$_temp0 are saved on this device and are uploaded automatically when the connection is back.';
  }

  @override
  String get syncYouAreOffline => 'You are offline';

  @override
  String get syncTheServerCannotBe => 'The server cannot be reached';

  @override
  String get syncTheServerRefusedThem =>
      'The server refused them. Retry them, or discard them below.';

  @override
  String syncChangeSNeedAttention(int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$failed changes',
      one: '$failed change',
    );
    return '$_temp0 need attention';
  }

  @override
  String get syncPleaseKeepTheApp => 'Please keep the app open.';

  @override
  String syncRefused(Object error) {
    return 'Refused: $error';
  }

  @override
  String get syncUploadedWaitingForThe =>
      'Uploaded, waiting for the server\'s copy';

  @override
  String syncWaitingToUpload(Object value) {
    return 'Waiting to upload · $value';
  }

  @override
  String usersManagerSStaff(int managers, Object staff) {
    String _temp0 = intl.Intl.pluralLogic(
      managers,
      locale: localeName,
      other: '$managers managers',
      one: '$managers manager',
    );
    return '$_temp0, $staff staff';
  }

  @override
  String usersTurnedOff(Object value) {
    return '$value turned off';
  }

  @override
  String get usersActivate => 'Activate';

  @override
  String get usersDeactivate => 'Deactivate';

  @override
  String usersYou(Object name) {
    return '$name (you)';
  }

  @override
  String get userFormCreateUser => 'Create user';

  @override
  String get userFormInactiveUsersCannotUse =>
      'Inactive users cannot use the app.';

  @override
  String get userFormYouCannotDeactivateYourself =>
      'You cannot deactivate yourself.';

  @override
  String get userFormYouCannotChangeYour => 'You cannot change your own role.';

  @override
  String get userFormUseAtLeast6 => 'Use at least 6 characters.';

  @override
  String get userFormTheLoginEmailCannot =>
      'The login email cannot be changed.';

  @override
  String get userFormEditUser => 'Edit user';

  @override
  String get logoutButtonDoYouWantTo => 'Do you want to sign out of A2 Stocks?';

  @override
  String logoutButtonYouHaveChangeS(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '$pendingCount changes',
      one: '$pendingCount change',
    );
    return 'You have $_temp0 that were not uploaded. They stay on this device and are uploaded when you sign in again with a connection. Sign out anyway?';
  }

  @override
  String get onlineStatusChipNoConnection => 'No connection';

  @override
  String get onlineStatusChipOnline => 'Online';

  @override
  String get orderReceiptCardUnpaid => 'Unpaid';

  @override
  String get orderReceiptCardPartlyPaid => 'Partly paid';

  @override
  String get orderReceiptCardCancelled => 'Cancelled';

  @override
  String get partyListNoCity => 'No city';

  @override
  String get partyListNoPhone => 'No phone';

  @override
  String get partyListOverLimit => 'Over limit';

  @override
  String partyListWithABalance2(Object withBalance) {
    return '$withBalance with a balance';
  }

  @override
  String get partyListToPay => 'To pay';

  @override
  String get partyListNothingHereYet => 'Nothing here yet.';

  @override
  String get partyPickerWalkInCustomerNo => 'Walk-in customer (no account)';

  @override
  String get photoWidgetsAPhoto => 'a photo';

  @override
  String get photoWidgetsChangePhoto => 'Change photo';

  @override
  String get photoWidgetsPhoto => 'Photo';

  @override
  String receiptActionsReceipt(Object orderNo) {
    return 'Receipt $orderNo';
  }

  @override
  String get receiptDue => 'Due :';

  @override
  String get receiptChange => 'Change :';

  @override
  String get receiptDelivery => 'Delivery :';

  @override
  String get receiptDiscount2 => 'Discount :';

  @override
  String get receiptSubTotal => 'Sub Total :';

  @override
  String get receiptReceiptNo => 'Receipt No';

  @override
  String get receiptServedBy => 'Served by';

  @override
  String get syncStatusChipSynced => 'Synced';

  @override
  String syncStatusChipToUpload(Object waiting) {
    return '$waiting to upload';
  }

  @override
  String get syncStatusChipOffline => 'Offline';

  @override
  String syncStatusChipWaitingOffline(Object waiting) {
    return '$waiting waiting (offline)';
  }

  @override
  String syncStatusChipNeedAttention(Object failed) {
    return '$failed need attention';
  }

  @override
  String get syncStatusChipSyncing => 'Syncing';

  @override
  String variantPickerSkuCost(Object sku, Object value) {
    return 'SKU $sku · Cost $value';
  }

  @override
  String variantPickerSkuPrice(Object sku, Object value) {
    return 'SKU $sku · Price $value';
  }

  @override
  String get moduleCategories => 'Categories';

  @override
  String get moduleProducts => 'Products';

  @override
  String get moduleCustomers => 'Customers';

  @override
  String get moduleVendors => 'Vendors';

  @override
  String get modulePurchases => 'Purchases';

  @override
  String get modulePos => 'POS';

  @override
  String get moduleSalesOrders => 'Sales & Orders';

  @override
  String get moduleStock => 'Stock';

  @override
  String get moduleActivityLogs => 'Activity Logs';

  @override
  String get moduleSettings => 'Settings';

  @override
  String get moduleUsers => 'Users';

  @override
  String get moduleGroupMain => 'Main';

  @override
  String get moduleGroupInventory => 'Inventory';

  @override
  String get moduleGroupSales => 'Sales';

  @override
  String get moduleGroupPurchasing => 'Purchasing';

  @override
  String get moduleGroupSystem => 'System';

  @override
  String countProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0';
  }

  @override
  String countSubcategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '$count subcategory',
    );
    return '$_temp0';
  }

  @override
  String countVariants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variants',
      one: '$count variant',
    );
    return '$_temp0';
  }

  @override
  String categoriesTipHeader(String name, String subcategories) {
    return '$name · $subcategories';
  }

  @override
  String categoriesTipChild(String name, String products) {
    return '•  $name — $products';
  }

  @override
  String categoriesTipTotal(String products, Object direct, String name) {
    return 'Total: $products ($direct directly in $name)';
  }

  @override
  String get productsUncategorized => 'Uncategorized';

  @override
  String productsSubtitle(String category, String variants, String price) {
    return '$category · $variants · $price';
  }

  @override
  String productFormSku(String sku) {
    return 'SKU $sku';
  }

  @override
  String productFormSkuInactive(String sku) {
    return 'SKU $sku · Inactive';
  }

  @override
  String starterPackSimilarAll(String matched) {
    return 'Your store looks similar: you already have $matched. You have all of this pack.';
  }

  @override
  String starterPackSimilarSome(String matched, int have, int total) {
    return 'Your store looks similar: you already have $matched. $have of $total categories are already added; add the rest.';
  }

  @override
  String starterPackWillAdd(int toAdd) {
    String _temp0 = intl.Intl.pluralLogic(
      toAdd,
      locale: localeName,
      other: '$toAdd new categories will be added.',
      one: '1 new category will be added.',
    );
    return '$_temp0';
  }

  @override
  String starterPackWillAddLeft(int toAdd, int have) {
    String _temp0 = intl.Intl.pluralLogic(
      toAdd,
      locale: localeName,
      other:
          '$toAdd new categories will be added ($have you already have are left as they are).',
      one:
          '1 new category will be added ($have you already have are left as they are).',
    );
    return '$_temp0';
  }

  @override
  String activityLogsCount(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total logs',
      one: '1 log',
    );
    return '$shown of $_temp0';
  }

  @override
  String activityLogsErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return ' · $_temp0';
  }

  @override
  String activityLogsNotUploaded(int count) {
    return ' · $count not uploaded yet';
  }

  @override
  String heldSalesItemsTotal(int units, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      units,
      locale: localeName,
      other: '$units items',
      one: '1 item',
    );
    return '$_temp0 · $total';
  }

  @override
  String posInStockCount(int count) {
    return '$count in stock';
  }

  @override
  String purchaseFormSkuInStock(String sku, int count) {
    return 'SKU $sku · In stock now: $count';
  }

  @override
  String orderDetailSaleLine(String date, String type) {
    return '$date · $type sale';
  }

  @override
  String orderDetailSaleLineOnline(String date, String type) {
    return '$date · $type sale · Online store';
  }

  @override
  String stockAuditSystemLine(String sku, int onHand) {
    return 'SKU $sku · System $onHand';
  }

  @override
  String stockAuditSystemLineInactive(String sku, int onHand) {
    return 'SKU $sku · System $onHand · inactive';
  }

  @override
  String stockAuditDifference(String variance) {
    return 'Difference $variance';
  }

  @override
  String stockAuditItemLine(String product, String variant, String sku,
      int system, int counted, String variance) {
    return '$product · $variant ($sku): system $system, counted $counted ($variance)';
  }

  @override
  String stockCostLine(String sku, String cost) {
    return 'SKU $sku · Cost $cost';
  }

  @override
  String stockCostAlertLine(String sku, String cost, int alert) {
    return 'SKU $sku · Cost $cost · Alert at $alert';
  }

  @override
  String usersDeleteUserMessage(String name) {
    return 'Delete $name? They will lose access to the app immediately. Their login remains in Firebase Authentication but cannot open the app. To block access but keep the record, deactivate the user instead.';
  }

  @override
  String orderReceiptMoreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more items',
      one: '1 more item',
    );
    return '+ $_temp0';
  }

  @override
  String get onboardingContentWithEMailSet =>
      'With e-mail set up, shoppers get a confirmation and you get an alert for each new order.';

  @override
  String get onboardingContentSwitchTheStoreOff =>
      'Switch the store off in Settings to stop taking orders.';

  @override
  String get onboardingContentOrdersArriveHereAs =>
      'Orders arrive here as \"Online store\" with the delivery address; the stock is taken out at once.';

  @override
  String get onboardingContentOnlyActiveProductsWith =>
      'Only active products with a price and a category that is active are shown.';

  @override
  String get onboardingContentAPersonWhoLeaves =>
      'A person who leaves is switched off, never deleted, so history stays correct.';

  @override
  String get onboardingContentAdminEverythingPlusUsers =>
      'Admin: everything, plus users, activity logs and the store settings.';

  @override
  String get onboardingContentManagerEverythingStaffDo =>
      'Manager: everything staff do, plus vendors, purchases, stock audits, the dashboard, and cancelling orders.';

  @override
  String get onboardingContentStaffSellRecordPayments =>
      'Staff: sell, record payments, look up stock and products.';

  @override
  String get onboardingContent6UsersALogin =>
      '6. Users: a login for each person, with the right role.';

  @override
  String get onboardingContent5PurchasesToPut =>
      '5. Purchases to put the first stock on the shelf (or a Stock Audit to count what you have).';

  @override
  String get onboardingContent4VendorsAndCustomers =>
      '4. Vendors and Customers; record opening balances if people already owe or are owed.';

  @override
  String get onboardingContent3CategoriesStartFrom =>
      '3. Categories (start from a ready-made Starter pack for your kind of business), then Products with their variants, prices and photos.';

  @override
  String get onboardingContent2SettingsOnlineStore =>
      '2. Settings > Online store > \"Send test e-mail\" to check that e-mail works.';

  @override
  String get onboardingContent1SettingsOnlineStore =>
      '1. Settings > Online store: store name, phone, delivery fee, free-delivery amount.';

  @override
  String get onboardingContentSetAnAlertLevel =>
      'Set an alert level on a variant to be warned before it runs out.';

  @override
  String get onboardingContentOnlyYouAndAdmins =>
      'Only you and admins can cancel an order; do it for fake or refused online orders so the stock comes back.';

  @override
  String get onboardingContentOnlineOrdersAreMarked =>
      'Online orders are marked \"Online store\" and already took their stock out.';

  @override
  String get onboardingContentYouCanAddPhotos =>
      'You can add photos to products you can open.';

  @override
  String get onboardingContentRedNumbersInStock =>
      'Red numbers in Stock mean the system thinks there is less than zero: tell your manager.';

  @override
  String get onboardingContentMoveAnOrderAlong =>
      'Move an order along: Pending, Processing, Shipped, Delivered.';

  @override
  String get onboardingContentRecordThePaymentNow =>
      'Record the payment now or later from the order.';

  @override
  String get onboardingContentChooseTheCustomerAdd =>
      'Choose the customer, add the products and quantities, and give a discount if allowed.';

  @override
  String get onboardingContentSalesMadeOfflineAre =>
      'Sales made offline are always recorded, even if the shelf turns out to be empty.';

  @override
  String get onboardingContentIfTheServerRefuses =>
      'If the server refuses something, it appears on the Sync screen with the reason; you can retry or discard it.';

  @override
  String get onboardingContentTheChipAtThe =>
      'The chip at the top shows what is waiting to be sent.';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get saleTypeRetail => 'Retail';

  @override
  String get saleTypeWholesale => 'Wholesale';

  @override
  String get partyTypeVendor => 'Vendor';

  @override
  String get partyTypeCustomer => 'Customer';

  @override
  String get balanceSettled => 'Settled';

  @override
  String get balanceToReceive => 'To receive';

  @override
  String get balanceAdvanceReceived => 'Advance received';

  @override
  String get balanceToPay => 'To pay';

  @override
  String get balanceAdvancePaid => 'Advance paid';

  @override
  String get ledgerSaleOnCredit => 'Sale on credit';

  @override
  String get ledgerPurchaseOnCredit => 'Purchase on credit';

  @override
  String get ledgerPaymentReceived => 'Payment received';

  @override
  String get ledgerPaymentMade => 'Payment made';

  @override
  String get vendorTypeManufacturer => 'Manufacturer';

  @override
  String get vendorTypeShop => 'Shop';

  @override
  String get vendorTypeOther => 'Other';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodEasypaisa => 'Easypaisa';

  @override
  String get paymentMethodJazzcash => 'JazzCash';

  @override
  String get paymentMethodBank => 'Bank transfer';

  @override
  String get paymentMethodUnknown => 'Payment';

  @override
  String get purchaseStatusPending => 'Pending';

  @override
  String get purchaseStatusPartial => 'Partial';

  @override
  String get purchaseStatusPaid => 'Paid';

  @override
  String get stockMovementPurchase => 'Purchase';

  @override
  String get stockMovementSale => 'Sale';

  @override
  String get stockMovementAdjustment => 'Adjustment';

  @override
  String get userRoleAdmin => 'Admin';

  @override
  String get userRoleManager => 'Manager';

  @override
  String get userRoleStaff => 'Staff';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelWarning => 'Warning';

  @override
  String get logLevelError => 'Error';

  @override
  String get logKindRecord => 'Record change';

  @override
  String get logKindAction => 'Action';

  @override
  String get logKindFailure => 'Failure';

  @override
  String get logKindSync => 'Sync';

  @override
  String get logKindSession => 'Session';

  @override
  String activityLogLoadedLogS(Object length) {
    return 'Loaded $length log(s).';
  }

  @override
  String get authControllerSignedOut => 'Signed out';

  @override
  String get authControllerSignedIn => 'Signed in';

  @override
  String catalogThisProductCannotBe(Object reason) {
    return 'This product cannot be deleted because $reason. Mark it inactive instead.';
  }

  @override
  String catalogHasStockHistoryAnd(Object label) {
    return '\"$label\" has stock history and cannot be removed. Mark it inactive instead.';
  }

  @override
  String get catalogTheSelectedCategoryNo =>
      'The selected category no longer exists.';

  @override
  String catalogSkuAlreadyBelongsTo(Object value, Object name) {
    return 'SKU \"$value\" already belongs to \"$name\".';
  }

  @override
  String catalogSkuIsUsedTwice(Object value) {
    return 'SKU \"$value\" is used twice in this product.';
  }

  @override
  String get catalogEveryVariantNeedsA => 'Every variant needs a SKU.';

  @override
  String get catalogProductNameIsRequired => 'Product name is required.';

  @override
  String catalogThisCategoryCannotBe(Object reason) {
    return 'This category cannot be deleted because $reason.';
  }

  @override
  String get catalogTheSelectedParentCategory =>
      'The selected parent category no longer exists.';

  @override
  String get catalogACategoryCannotBe =>
      'A category cannot be placed inside itself or its subcategories.';

  @override
  String catalogACategoryNamedAlready(Object value) {
    return 'A category named \"$value\" already exists here.';
  }

  @override
  String get catalogCategoryNameIsRequired => 'Category name is required.';

  @override
  String get catalogOnlyAdminsAndManagers =>
      'Only admins and managers can change the catalog.';

  @override
  String get catalogItHasStockHistory => 'it has stock history';

  @override
  String catalogItIsUsedBy(Object used) {
    return 'it is used by $used product(s)';
  }

  @override
  String get catalogItHasSubcategories => 'it has subcategories';

  @override
  String get dashboardInsightsUncategorised => 'Uncategorised';

  @override
  String get dashboardThisMonth => 'This month';

  @override
  String get dashboardToday => 'Today';

  @override
  String get localDataNoUserIsSigned =>
      'No user is signed in, so there is no database to open.';

  @override
  String get partiesThisEntryBelongsTo =>
      'This entry belongs to a purchase and cannot be deleted.';

  @override
  String get partiesThisPartyNoLonger => 'This party no longer exists.';

  @override
  String get partiesTheAmountMustBe => 'The amount must be greater than zero.';

  @override
  String partiesThisCustomerCannotBe(Object reason) {
    return 'This customer cannot be deleted because $reason. Deactivate it instead.';
  }

  @override
  String get partiesTheCreditLimitCannot =>
      'The credit limit cannot be negative.';

  @override
  String get partiesACustomerWithThis =>
      'A customer with this phone number already exists.';

  @override
  String get partiesCustomerNameIsRequired => 'Customer name is required.';

  @override
  String partiesThisVendorCannotBe(Object reason) {
    return 'This vendor cannot be deleted because $reason. Deactivate it instead.';
  }

  @override
  String get partiesAVendorWithThis =>
      'A vendor with this phone number already exists.';

  @override
  String partiesAVendorNamedAlready(Object value) {
    return 'A vendor named \"$value\" already exists.';
  }

  @override
  String get partiesVendorNameIsRequired => 'Vendor name is required.';

  @override
  String get partiesItHasOrders => 'it has orders';

  @override
  String get partiesItHasAnOpening => 'it has an opening balance';

  @override
  String get partiesItHasLedgerEntries => 'it has ledger entries';

  @override
  String get partiesOnlyAdminsAndManagers =>
      'Only admins and managers can change vendors, customers and ledgers.';

  @override
  String purchasingPaymentOfRecordedFor(
      Object value, Object purchaseNo, Object vendorName) {
    return 'Payment of $value recorded for purchase $purchaseNo ($vendorName).';
  }

  @override
  String purchasingThePaymentIsMore(Object value) {
    return 'The payment is more than the amount due ($value).';
  }

  @override
  String purchasingPurchaseConfirmedFromItem(
      Object purchaseNo,
      Object vendorName,
      Object length,
      Object totalUnits,
      Object value,
      Object value2) {
    return 'Purchase $purchaseNo confirmed from $vendorName: $length item(s), $totalUnits unit(s), total $value, paid now $value2. Stock added and the vendor ledger charged.';
  }

  @override
  String get purchasingTheAmountPaidMust =>
      'The amount paid must be between 0 and the purchase total.';

  @override
  String purchasingNoLongerExistsIn(Object productName) {
    return '\"$productName\" no longer exists in the catalog.';
  }

  @override
  String get purchasingABuyingPriceCannot =>
      'A buying price cannot be negative.';

  @override
  String get purchasingEveryItemNeedsA =>
      'Every item needs a quantity of at least 1.';

  @override
  String get purchasingThisVendorIsInactive => 'This vendor is inactive.';

  @override
  String get purchasingOnlyAdminsAndManagers =>
      'Only admins and managers can record purchases.';

  @override
  String salesPaymentOfRecordedFor(
      Object value, Object orderNo, Object customerName) {
    return 'Payment of $value recorded for order $orderNo ($customerName).';
  }

  @override
  String get salesACancelledOrderCannot =>
      'A cancelled order cannot take payments.';

  @override
  String salesOrderCancelledWasUnit(Object orderNo, Object label,
      Object totalUnits, Object value, Object customerName) {
    return 'Order $orderNo cancelled (was $label): $totalUnits unit(s) returned to stock and the $value charge on $customerName\'s ledger reversed.';
  }

  @override
  String salesAOrderCannotBe(Object value) {
    return 'A $value order cannot be cancelled.';
  }

  @override
  String salesOrderMovedFromTo(Object orderNo, Object label, Object label2) {
    return 'Order $orderNo moved from $label to $label2.';
  }

  @override
  String salesAOrderCannotChange(Object value) {
    return 'A $value order cannot change status.';
  }

  @override
  String salesOrderConfirmedForItem(
      Object orderNo,
      Object customerName,
      Object length,
      Object totalUnits,
      Object value,
      Object value2,
      Object value3) {
    return 'Order $orderNo confirmed for $customerName: $length item(s), $totalUnits unit(s), $value sale, total $value2, paid now $value3. Stock taken out and the customer ledger charged.';
  }

  @override
  String salesThisOrderWouldTake(Object name, Object value, Object value2) {
    return 'This order would take $name over the credit limit (limit $value, balance after $value2).';
  }

  @override
  String salesNotEnoughStockFor(Object productName, Object variantLabel,
      Object available, Object wanted) {
    return 'Not enough stock for \"$productName · $variantLabel\": $available available, $wanted requested.';
  }

  @override
  String salesIsInactive(Object productName, Object variantLabel) {
    return '\"$productName · $variantLabel\" is inactive.';
  }

  @override
  String get salesTheAmountPaidMust =>
      'The amount paid must be between 0 and the order total.';

  @override
  String get salesTheOrderDiscountMust =>
      'The order discount must be between 0 and the order subtotal.';

  @override
  String get salesEveryPaymentMustBe => 'Every payment must be more than zero.';

  @override
  String salesTheDiscountOnMust(Object productName) {
    return 'The discount on \"$productName\" must be between 0 and the line amount.';
  }

  @override
  String get salesASellingPriceCannot => 'A selling price cannot be negative.';

  @override
  String get salesThisCustomerIsInactive => 'This customer is inactive.';

  @override
  String get salesOnlyAdminsAndManagers =>
      'Only admins and managers can cancel orders.';

  @override
  String get salesYouAreNotAllowed => 'You are not allowed to change orders.';

  @override
  String get stockAuditEveryCountedQuantityMatches2 =>
      'Every counted quantity matches the system, so there is nothing to adjust.';

  @override
  String get stockAuditACountedItemNo =>
      'A counted item no longer exists in the catalog.';

  @override
  String get stockAuditTheSameItemWas => 'The same item was counted twice.';

  @override
  String get stockAuditACountedQuantityCannot =>
      'A counted quantity cannot be negative.';

  @override
  String get stockAuditEnterTheCountedQuantity =>
      'Enter the counted quantity of at least one item.';

  @override
  String get syncControllerEverythingIsInStep =>
      'Everything is in step with the server.';

  @override
  String syncControllerChangeSWereRefused(Object refused) {
    return '$refused change(s) were refused by the server. See the list below.';
  }

  @override
  String get syncControllerTheServerCannotBe =>
      'The server cannot be reached. Your work is saved on this device.';

  @override
  String syncControllerSyncFailed(Object e) {
    return 'Sync failed: $e';
  }

  @override
  String get usersYouCannotDeleteYour => 'You cannot delete your own account.';

  @override
  String get usersOnlyAnActiveAdmin => 'Only an active admin can delete users.';

  @override
  String get usersUserNotFound => 'User not found.';

  @override
  String get usersYouCannotChangeYour =>
      'You cannot change your own role or active status.';

  @override
  String get usersOnlyAnActiveAdmin2 =>
      'Only an active admin can update users.';

  @override
  String get usersOnlyAnActiveAdmin3 => 'Only an active admin can add users.';

  @override
  String get appExceptionsTheCloudDataChanged =>
      'The cloud data changed. Download the updates first.';

  @override
  String posPaymentPlanThatIsMoreThan(Object value) {
    return 'That is more than what is left to pay ($value).';
  }

  @override
  String posPaymentPlanEnterTheTransactionNumber(Object label) {
    return 'Enter the $label transaction number.';
  }

  @override
  String get posPaymentPlanEnterTheBankAnd =>
      'Enter the bank and transaction number.';

  @override
  String get posPaymentPlanTheSaleIsAlready =>
      'The sale is already fully paid.';

  @override
  String get posPaymentPlanEnterAnAmountAbove => 'Enter an amount above zero.';

  @override
  String get priceWarningsSalePriceIsLess =>
      'Sale price is less than the cost price.';

  @override
  String get priceWarningsWholesalePriceIsLess =>
      'Wholesale price is less than the cost price.';

  @override
  String get priceWarningsRetailPriceIsLess =>
      'Retail price is less than the wholesale price.';

  @override
  String get receiptThankYouForShopping2 => 'Thank you for shopping with us!';

  @override
  String receiptBalanceDue(Object value) {
    return 'Balance due: $value';
  }

  @override
  String receiptChange2(Object value) {
    return 'Change: $value';
  }

  @override
  String receiptTotal(Object value) {
    return '*Total: $value*';
  }

  @override
  String receiptDelivery2(Object value) {
    return 'Delivery: $value';
  }

  @override
  String receiptDiscount3(Object value) {
    return 'Discount: -$value';
  }

  @override
  String receiptItems(Object value) {
    return 'Items: $value';
  }

  @override
  String receiptCustomer(Object customerName) {
    return 'Customer: $customerName';
  }

  @override
  String receiptReceipt(Object orderNo) {
    return 'Receipt $orderNo';
  }

  @override
  String receiptTel(Object shopPhone) {
    return 'Tel: $shopPhone';
  }

  @override
  String receiptPdfDiscount(Object value) {
    return 'Discount -$value';
  }

  @override
  String receiptPdfPhoneNumber(Object shopPhone) {
    return 'Phone Number : $shopPhone';
  }

  @override
  String whatsappHelloYourOrder(Object who, Object orderNo, Object value,
      Object status, Object shopName) {
    return 'Hello$who, your order $orderNo ($value) $status. - $shopName';
  }

  @override
  String get whatsappHasBeenCancelled => 'has been cancelled';

  @override
  String get whatsappHasBeenDeliveredThank =>
      'has been delivered. Thank you for shopping with us!';

  @override
  String get whatsappIsOnItsWay => 'is on its way to you';

  @override
  String get whatsappIsBeingPrepared => 'is being prepared';

  @override
  String get whatsappHasBeenReceived => 'has been received';

  @override
  String get apiAuthServiceTheServerDidNot =>
      'The server did not return the new user.';

  @override
  String apiClientTheServerHadA(Object status) {
    return 'The server had a problem (error $status). Please try again.';
  }

  @override
  String get apiClientTooManyAttemptsPlease =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get apiClientYouAreNotAllowed => 'You are not allowed to do this.';

  @override
  String get apiClientIncorrectEmailOrPassword =>
      'Incorrect email or password.';

  @override
  String get apiClientTheServerRefusedThis =>
      'The server refused this request.';

  @override
  String apiClientCannotReachTheServer(Object _baseUrl, Object message) {
    return 'Cannot reach the server at $_baseUrl. Check your connection and try again. ($message)';
  }

  @override
  String get apiClientTheServerTookToo =>
      'The server took too long to answer. Please try again.';

  @override
  String get apiClientYourSessionEndedPlease =>
      'Your session ended. Please sign in again.';

  @override
  String get apiClientTheServerSentAn =>
      'The server sent an unexpected sign-in answer.';

  @override
  String apiCommandsRecordsOfCannotBe(Object collection) {
    return 'Records of \"$collection\" cannot be deleted.';
  }

  @override
  String apiCommandsRecordsOfCannotBe2(Object collection) {
    return 'Records of \"$collection\" cannot be saved directly.';
  }

  @override
  String get onlineRepositoriesUsersAreCreatedWith =>
      'Users are created with a login (email and password).';

  @override
  String get onlineRepositoriesAStockCountCannot =>
      'A stock count cannot be deleted.';

  @override
  String get onlineRepositoriesAStockCountIs =>
      'A stock count is created by confirming it.';

  @override
  String get onlineRepositoriesAnOrderCannotBe =>
      'An order cannot be deleted. Cancel it instead.';

  @override
  String get onlineRepositoriesAnOrderIsCreated =>
      'An order is created by confirming it.';

  @override
  String get onlineRepositoriesAConfirmedPurchaseCannot =>
      'A confirmed purchase cannot be deleted.';

  @override
  String get onlineRepositoriesAConfirmedPurchaseCannot2 =>
      'A confirmed purchase cannot be changed.';

  @override
  String get onlineRepositoriesStockChangesOnlyThrough =>
      'Stock changes only through purchases, sales and stock counts.';

  @override
  String get onlineRepositoriesLedgerEntriesCannotBe =>
      'Ledger entries cannot be edited. Delete the entry and add it again.';

  @override
  String get photoServiceThePhotoCouldNot =>
      'The photo could not be uploaded. Check your connection and try again.';

  @override
  String photoServiceThePhotoCouldNot2(Object statusCode) {
    return 'The photo could not be uploaded ($statusCode). Please try again.';
  }

  @override
  String get photoServiceTheServerDidNot =>
      'The server did not give an upload link.';

  @override
  String get photoServiceThisItemHasNot =>
      'This item has not reached the server yet. Wait for it to sync, then add the photo.';

  @override
  String get photoServiceChooseAPhoto => 'Choose a photo';

  @override
  String get photoServiceOnlyJpegPngOr =>
      'Only JPEG, PNG or WebP photos can be used.';

  @override
  String get photoServiceThatPhotoIsBigger =>
      'That photo is bigger than 10 MB. Please choose a smaller one.';

  @override
  String get photoServiceThatFileIsEmpty => 'That file is empty.';

  @override
  String localRepositoriesStockCount(Object auditNo) {
    return 'Stock count $auditNo';
  }

  @override
  String get localRepositoriesStockCount2 => 'Stock count';

  @override
  String localRepositoriesCancelOrder(Object orderNo) {
    return 'Cancel order $orderNo';
  }

  @override
  String localRepositoriesOrder(Object orderNo) {
    return 'Order $orderNo';
  }

  @override
  String localRepositoriesPurchase(Object purchaseNo) {
    return 'Purchase $purchaseNo';
  }

  @override
  String get localRepositoriesStockEntry => 'Stock entry';

  @override
  String localRepositoriesPaymentFor(Object value, Object reference) {
    return 'Payment $value for $reference';
  }

  @override
  String get localRepositoriesLedgerEntry => 'Ledger entry';

  @override
  String get currencyPkr => 'Pakistani rupee';

  @override
  String get currencyUsd => 'US dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get currencyGbp => 'British pound';

  @override
  String get currencyAed => 'UAE dirham';

  @override
  String get currencySar => 'Saudi riyal';

  @override
  String get currencyQar => 'Qatari riyal';

  @override
  String get currencyInr => 'Indian rupee';

  @override
  String get currencyBdt => 'Bangladeshi taka';

  @override
  String get currencyCad => 'Canadian dollar';

  @override
  String get currencyAud => 'Australian dollar';

  @override
  String stockAuditLogSummary(
      String auditNo, int items, int net, String netText, String note) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items items',
      one: '1 item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      net,
      locale: localeName,
      other: '$netText units',
      one: '$netText unit',
    );
    return 'Stock count $auditNo applied: $_temp0 adjusted, net $_temp1.$note';
  }

  @override
  String stockAuditLogNote(String note) {
    return ' Note: $note';
  }

  @override
  String starterPackMatchedOne(String a) {
    return '$a';
  }

  @override
  String starterPackMatchedTwo(String a, String b) {
    return '$a and $b';
  }

  @override
  String starterPackMatchedThree(String a, String b, String c) {
    return '$a, $b and $c';
  }

  @override
  String starterPackMatchedMore(String a, String b, String c, int more) {
    return '$a, $b, $c and $more more';
  }

  @override
  String countGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '$count group',
    );
    return '$_temp0';
  }

  @override
  String countCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '$count category',
    );
    return '$_temp0';
  }

  @override
  String starterPackSizeLine(String groups, String categories) {
    return '$groups · $categories';
  }

  @override
  String starterPackGroupHave(String subcategories) {
    return '$subcategories · you already have this one';
  }

  @override
  String get photoWidgetsPhotos => 'photos';

  @override
  String get apiErrorAuditsACountedItemNoLongerExists =>
      'A counted item no longer exists in the catalog.';

  @override
  String apiErrorAuditsAuditNumberAlreadyExists(String supplied) {
    return 'Audit number $supplied already exists.';
  }

  @override
  String get apiErrorAuditsCouldNotGenerateAnAuditNumber =>
      'Could not generate an audit number, try again.';

  @override
  String get apiErrorAuditsEveryCountedQuantityMatchesTheSystem =>
      'Every counted quantity matches the system, so there is nothing to adjust.';

  @override
  String get apiErrorAuditsStockAuditNotFound => 'Stock audit not found';

  @override
  String get apiErrorAuditsTheSameItemWasCountedTwice =>
      'The same item was counted twice.';

  @override
  String get apiErrorAuditsThisStockAuditAlreadyExists =>
      'This stock audit already exists.';

  @override
  String get apiErrorAuthAccountDisabled => 'Account is disabled';

  @override
  String get apiErrorAuthAccountDisabledToken => 'Account is disabled';

  @override
  String get apiErrorAuthInvalidEmailOrPassword => 'Invalid email or password';

  @override
  String get apiErrorAuthInvalidOrExpiredAccessToken =>
      'Invalid or expired access token';

  @override
  String get apiErrorAuthInvalidRefreshToken => 'Invalid refresh token';

  @override
  String get apiErrorAuthMissingAccessToken => 'Missing access token';

  @override
  String get apiErrorAuthRefreshTokenExpired => 'Refresh token expired';

  @override
  String get apiErrorAuthRefreshTokenWasAlreadyUsed =>
      'Refresh token was already used';

  @override
  String get apiErrorAuthYouDoNotHavePermissionFor =>
      'You do not have permission for this action';

  @override
  String get apiErrorCategoriesACategoryCannotBePlacedInside =>
      'A category cannot be placed inside itself or its subcategories.';

  @override
  String apiErrorCategoriesACategoryNamedAlreadyExistsHere(String name) {
    return 'A category named \"$name\" already exists here.';
  }

  @override
  String get apiErrorCategoriesCategoryNameIsRequired =>
      'Category name is required.';

  @override
  String get apiErrorCategoriesCategoryNotFound => 'Category not found';

  @override
  String get apiErrorCategoriesTheSelectedParentCategoryNoLonger =>
      'The selected parent category no longer exists.';

  @override
  String get apiErrorCategoriesDeleteHasSubcategories =>
      'This category cannot be deleted because it has subcategories.';

  @override
  String apiErrorCategoriesDeleteUsedByProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return 'This category cannot be deleted because it is used by $_temp0.';
  }

  @override
  String get apiErrorCustomersACustomerWithThisPhoneNumber =>
      'A customer with this phone number already exists.';

  @override
  String get apiErrorCustomersCustomerNameIsRequired =>
      'Customer name is required.';

  @override
  String get apiErrorCustomersCustomerNotFound => 'Customer not found';

  @override
  String get apiErrorCustomersDeleteHasLedgerEntries =>
      'This customer cannot be deleted because it has ledger entries. Deactivate it instead.';

  @override
  String get apiErrorCustomersDeleteHasOpeningBalance =>
      'This customer cannot be deleted because it has an opening balance. Deactivate it instead.';

  @override
  String get apiErrorCustomersDeleteHasOrders =>
      'This customer cannot be deleted because it has orders. Deactivate it instead.';

  @override
  String get apiErrorCustomersTheWalkInCustomerIsUsed =>
      'The walk-in customer is used by the POS and cannot be deleted.';

  @override
  String get apiErrorDbNotFound => 'Record not found.';

  @override
  String get apiErrorDbStillReferenced =>
      'This record is still referenced by other records.';

  @override
  String get apiErrorDbUnexpected => 'Unexpected database error';

  @override
  String get apiErrorDbUniqueViolation =>
      'A record with the same unique value already exists.';

  @override
  String get apiErrorIdempotencyARequestWithThisIdempotencyKey =>
      'A request with this Idempotency-Key is still in progress. Try again shortly.';

  @override
  String get apiErrorIdempotencyIdempotencyKeyIsTooLong200 =>
      'Idempotency-Key is too long (200 characters at most).';

  @override
  String get apiErrorIdempotencyPleaseRetryTheRequest =>
      'Please retry the request.';

  @override
  String get apiErrorIdempotencyThisIdempotencyKeyWasAlreadyUsed =>
      'This Idempotency-Key was already used for a different request.';

  @override
  String apiErrorImagesAProductCanHavePhotosAt(String max) {
    return 'A product can have $max photos at most.';
  }

  @override
  String get apiErrorImagesListEveryPhotoOfThisProduct =>
      'List every photo of this product exactly once.';

  @override
  String get apiErrorImagesPhotoNotFound => 'Photo not found';

  @override
  String get apiErrorImagesProductNotFound => 'Product not found';

  @override
  String get apiErrorImagesThatVariantDoesNotBelongTo =>
      'That variant does not belong to this product.';

  @override
  String get apiErrorImagesTheFileHasNotBeenUploaded =>
      'The file has not been uploaded yet.';

  @override
  String get apiErrorImagesTheUploadedFileDoesNotMatch =>
      'The uploaded file does not match the size that was declared.';

  @override
  String get apiErrorImagesTheUploadedFileIsNotA =>
      'The uploaded file is not a valid JPEG, PNG or WebP photo.';

  @override
  String get apiErrorLedgerLedgerEntryNotFound => 'Ledger entry not found';

  @override
  String get apiErrorLedgerOnlyAdminsAndManagersCanRead =>
      'Only admins and managers can read vendor ledgers.';

  @override
  String get apiErrorLedgerThisEntryBelongsToAPurchase =>
      'This entry belongs to a purchase and cannot be deleted.';

  @override
  String get apiErrorLedgerThisEntryBelongsToAnOrder =>
      'This entry belongs to an order and cannot be deleted.';

  @override
  String get apiErrorLedgerThisPartyNoLongerExists =>
      'This party no longer exists.';

  @override
  String get apiErrorOrdersACancelledOrderCannotTakePayments =>
      'A cancelled order cannot take payments.';

  @override
  String apiErrorOrdersCannotCancelInStatus(String status) {
    return 'A $status order cannot be cancelled.';
  }

  @override
  String apiErrorOrdersCannotChangeStatusInStatus(String status) {
    return 'A $status order cannot change status.';
  }

  @override
  String apiErrorOrdersAnOrderCannotMoveFromTo(String from, String to) {
    return 'An order cannot move from $from to $to.';
  }

  @override
  String get apiErrorOrdersCouldNotGenerateAnOrderNumber =>
      'Could not generate an order number, try again.';

  @override
  String apiErrorOrdersItemInactive(String name) {
    return '\"$name\" is inactive.';
  }

  @override
  String get apiErrorOrdersOrderNotFound => 'Order not found';

  @override
  String apiErrorOrdersOrderNumberAlreadyExists(String supplied) {
    return 'Order number $supplied already exists.';
  }

  @override
  String get apiErrorOrdersSendEitherTheAmountPaidOr =>
      'Send either the amount paid or the payments, not both.';

  @override
  String get apiErrorOrdersTheAmountPaidMustBeBetween =>
      'The amount paid must be between 0 and the order total.';

  @override
  String apiErrorOrdersTheDiscountOnMustBeBetween(String name) {
    return 'The discount on \"$name\" must be between 0 and the line amount.';
  }

  @override
  String get apiErrorOrdersTheOrderDiscountMustBeBetween =>
      'The order discount must be between 0 and the order subtotal.';

  @override
  String get apiErrorOrdersThisCustomerIsInactive =>
      'This customer is inactive.';

  @override
  String get apiErrorOrdersThisCustomerNoLongerExists =>
      'This customer no longer exists.';

  @override
  String get apiErrorOrdersThisOrderAlreadyExists =>
      'This order already exists.';

  @override
  String apiErrorOrdersThisOrderWouldTakeOverThe(
      String name, String limit, String balance) {
    return 'This order would take $name over the credit limit (limit $limit, balance after $balance).';
  }

  @override
  String get apiErrorOrdersUseTheCancelActionToCancel =>
      'Use the cancel action to cancel an order.';

  @override
  String get apiErrorPhotosAPhotoCanBe10Mb => 'A photo can be 10 MB at most.';

  @override
  String get apiErrorPhotosNotFound => 'Not found';

  @override
  String get apiErrorPhotosOnlyJpegPngOrWebpPhotos =>
      'Only JPEG, PNG or WebP photos are accepted.';

  @override
  String apiErrorPhotosPhotosBelongToOneOf(String kinds) {
    return 'Photos belong to one of: $kinds.';
  }

  @override
  String get apiErrorProductsAVariantIdAlreadyBelongsTo =>
      'A variant id already belongs to another product.';

  @override
  String get apiErrorProductsAVariantIdIsUsedTwice =>
      'A variant id is used twice.';

  @override
  String get apiErrorProductsEveryVariantNeedsASku =>
      'Every variant needs a SKU.';

  @override
  String apiErrorProductsVariantHasStockHistory(String name) {
    return '\"$name\" has stock history and cannot be removed. Mark it inactive instead.';
  }

  @override
  String get apiErrorProductsProductNameIsRequired =>
      'Product name is required.';

  @override
  String apiErrorProductsSkuAlreadyBelongsTo(String sku, String name) {
    return 'SKU \"$sku\" already belongs to \"$name\".';
  }

  @override
  String apiErrorProductsSkuIsUsedTwiceInThis(String sku) {
    return 'SKU \"$sku\" is used twice in this product.';
  }

  @override
  String get apiErrorProductsTheSelectedCategoryNoLongerExists =>
      'The selected category no longer exists.';

  @override
  String get apiErrorProductsDeleteHasStockHistory =>
      'This product cannot be deleted because it has stock history. Mark it inactive instead.';

  @override
  String get apiErrorPurchasesCouldNotGenerateAPurchaseNumber =>
      'Could not generate a purchase number, try again.';

  @override
  String apiErrorPurchasesItemNoLongerExistsInThe(String item) {
    return 'Item $item no longer exists in the catalog.';
  }

  @override
  String get apiErrorPurchasesPurchaseNotFound => 'Purchase not found';

  @override
  String apiErrorPurchasesPurchaseNumberAlreadyExists(String supplied) {
    return 'Purchase number $supplied already exists.';
  }

  @override
  String get apiErrorPurchasesTheAmountPaidMustBeBetween =>
      'The amount paid must be between 0 and the purchase total.';

  @override
  String apiErrorPurchasesThePaymentIsMoreThanThe(String due) {
    return 'The payment is more than the amount due ($due).';
  }

  @override
  String get apiErrorPurchasesThisPurchaseAlreadyExists =>
      'This purchase already exists.';

  @override
  String get apiErrorPurchasesThisVendorIsInactive =>
      'This vendor is inactive.';

  @override
  String get apiErrorPurchasesThisVendorNoLongerExists =>
      'This vendor no longer exists.';

  @override
  String get apiErrorRequestTooManyRequests =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get apiErrorRequestValidationFailed =>
      'Some of the values sent are not valid.';

  @override
  String get apiErrorStarterPacksChooseAtLeastOneGroupTo =>
      'Choose at least one group to add.';

  @override
  String apiErrorStarterPacksNotInThisPack(String names) {
    return 'Not in this pack: $names.';
  }

  @override
  String get apiErrorStarterPacksThereIsNoSuchStarterPack =>
      'There is no such starter pack.';

  @override
  String apiErrorStockNotEnoughStockForOnHand(
      String name, String quantity, String needed) {
    return 'Not enough stock for $name: $quantity on hand, $needed needed.';
  }

  @override
  String get apiErrorStoreAnAccountWithThisEmailAlready =>
      'An account with this email already exists. Please sign in.';

  @override
  String get apiErrorStoreAnItemInYourCartIs =>
      'An item in your cart is no longer available. Please review your cart.';

  @override
  String get apiErrorStoreEMailIsOnlySetUp =>
      'E-mail is only set up for the business that runs the online store.';

  @override
  String get apiErrorStorePleaseEnterAValidPhoneNumber =>
      'Please enter a valid phone number so we can reach you.';

  @override
  String get apiErrorStorePleaseOrderAtMost100Of =>
      'Please order at most 100 of one item.';

  @override
  String get apiErrorStorePleaseSignIn => 'Please sign in.';

  @override
  String get apiErrorStorePleaseSignInAgain => 'Please sign in again.';

  @override
  String get apiErrorStoreSorryOneOfYourItemsIs =>
      'Sorry, one of your items is no longer available in the quantity you chose. Please review your cart.';

  @override
  String get apiErrorStoreTheStoreIsClosedRightNow =>
      'The store is closed right now. Please come back later.';

  @override
  String get apiErrorStoreTheStoreIsNotTakingOrders =>
      'The store is not taking orders right now.';

  @override
  String get apiErrorStoreThisLinkHasExpiredPleaseAsk =>
      'This link has expired. Please ask for a new one.';

  @override
  String get apiErrorStoreThisOrderNumberIsAlreadyUsed =>
      'This order number is already used. Please try again.';

  @override
  String get apiErrorStoreThisProductIsNotAvailable =>
      'This product is not available.';

  @override
  String get apiErrorStoreWeCannotTakeOnlineOrdersFor =>
      'We cannot take online orders for this phone number. Please call us.';

  @override
  String get apiErrorStoreWeCouldNotFindThisOrder =>
      'We could not find this order. Check the link and try again.';

  @override
  String get apiErrorStoreWrongEmailOrPassword => 'Wrong email or password.';

  @override
  String get apiErrorUsersAUserWithThisEmailAlready =>
      'A user with this email already exists';

  @override
  String get apiErrorUsersThereMustBeAtLeastOne =>
      'There must be at least one active admin';

  @override
  String get apiErrorUsersUserNotFound => 'User not found';

  @override
  String get apiErrorUsersYouCannotDemoteOrDisableYour =>
      'You cannot demote or disable your own admin account';

  @override
  String apiErrorVendorsAVendorNamedAlreadyExists(String name) {
    return 'A vendor named \"$name\" already exists.';
  }

  @override
  String get apiErrorVendorsAVendorWithThisPhoneNumber =>
      'A vendor with this phone number already exists.';

  @override
  String get apiErrorVendorsDeleteHasLedgerEntries =>
      'This vendor cannot be deleted because it has ledger entries. Deactivate it instead.';

  @override
  String get apiErrorVendorsDeleteHasOpeningBalance =>
      'This vendor cannot be deleted because it has an opening balance. Deactivate it instead.';

  @override
  String get apiErrorVendorsDeleteHasPurchases =>
      'This vendor cannot be deleted because it has purchases. Deactivate it instead.';

  @override
  String get apiErrorVendorsVendorNameIsRequired => 'Vendor name is required.';

  @override
  String get apiErrorVendorsVendorNotFound => 'Vendor not found';

  @override
  String get apiErrorStreamTooManyConnections =>
      'Too many open update streams for this account.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty =>
      'Nothing new. Online orders and low stock will show here.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsLoadError =>
      'The notifications could not be loaded. They need a connection to the server.';

  @override
  String get notificationsRetry => 'Try again';

  @override
  String get notificationsView => 'View';

  @override
  String notificationNewOrder(String orderNo) {
    return 'New online order $orderNo';
  }

  @override
  String notificationNewOrderDetail(String customer, String total) {
    return '$customer · $total';
  }

  @override
  String notificationLowStock(String product) {
    return '$product is running low';
  }

  @override
  String notificationLowStockDetail(int count, int threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0 · alert level $threshold';
  }

  @override
  String notificationOutOfStock(String product) {
    return '$product is out of stock';
  }

  @override
  String notificationOutOfStockDetail(int threshold) {
    return 'Alert level $threshold';
  }

  @override
  String get notificationUnknown => 'New notification';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Sound and desktop alerts';

  @override
  String get notifSettingsSound => 'Play a sound';

  @override
  String get notifSettingsSoundHint =>
      'A chime for a new online order, a calmer tone for low stock.';

  @override
  String get notifSettingsSystem => 'Show desktop notifications';

  @override
  String get notifSettingsSystemHint =>
      'When this window is in the background or minimised, a new notification also appears on your screen.';

  @override
  String get notifSettingsBlocked =>
      'Notifications are blocked for this site. Allow them in your browser\'s site settings, then switch this on again.';

  @override
  String get notifSettingsUnsupported =>
      'This device cannot show desktop notifications.';

  @override
  String get notifSettingsTest => 'Send a test';

  @override
  String get notifSettingsTestTitle => 'Test notification';

  @override
  String get notifSettingsTestBody => 'A new online order will look like this.';

  @override
  String get notifSettingsTestSent =>
      'Test sent. It shows on your screen when this window is in the background.';

  @override
  String get notifSettingsTestSoundOnly =>
      'Sound played. Desktop notifications are switched off above.';

  @override
  String get notifSettingsTestNotAllowed =>
      'Sound played, but notifications are not allowed for this app yet. Switch the option on again to allow them.';

  @override
  String get apiErrorRegisterTheDayHasNotStartedYet =>
      'This day has not started yet, so it cannot be closed.';

  @override
  String get apiErrorRegisterTheRegisterIsSwitchedOff =>
      'The cash register is switched off for this business. An admin can switch it on in Settings.';

  @override
  String get moduleCashRegister => 'Cash register';

  @override
  String get registerRefresh => 'Refresh';

  @override
  String get registerCancel => 'Cancel';

  @override
  String get registerToday => 'Today';

  @override
  String get registerClosed => 'Closed';

  @override
  String get registerOpen => 'Open';

  @override
  String get registerShouldHave => 'Cash that should be in the drawer';

  @override
  String get registerOpening => 'Opening cash';

  @override
  String get registerOpeningHint =>
      'The cash that was in the drawer when the day began. Change it if it is not right.';

  @override
  String get registerFromCustomers => 'Cash from customers';

  @override
  String get registerToVendors => 'Cash paid to vendors';

  @override
  String get registerNotCash => 'Also received, not in cash';

  @override
  String registerSalesLine(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
      zero: 'No sales',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get registerCounted => 'Cash counted';

  @override
  String get registerCountedHint =>
      'Count the cash in the drawer and type the total.';

  @override
  String get registerNote => 'Note (optional)';

  @override
  String get registerCloseDay => 'Close the day';

  @override
  String get registerCountAgain => 'Count again';

  @override
  String get registerDayClosed => 'The day is closed.';

  @override
  String get registerBalanced => 'The cash matches';

  @override
  String get registerBalancedShort => 'Matches';

  @override
  String registerShort(String amount) {
    return '$amount short';
  }

  @override
  String registerOver(String amount) {
    return '$amount over';
  }

  @override
  String registerCountedAmount(String amount) {
    return '$amount counted';
  }

  @override
  String registerClosedBy(String name, String date) {
    return 'Closed by $name on $date';
  }

  @override
  String registerUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '1 action',
    );
    return '$_temp0 on this device not sent to the server yet. Wait for them to sync, so the cash of the day is complete.';
  }

  @override
  String get registerHistory => 'Days closed before';

  @override
  String get registerHistoryEmpty => 'No day has been closed yet.';

  @override
  String get registerChoiceTitle => 'I use a cash register';

  @override
  String get registerChoiceHint =>
      'Adds a Cash register page where you count the cash at the end of each day and see whether it matches. You can switch it on or off at any time.';

  @override
  String get onboardingContentCashRegister => 'Do you keep a cash register?';

  @override
  String get onboardingContentCashRegisterBody =>
      'If cash goes into a drawer or a cash box, A2 Stocks can help you check it at the end of each day: you count the cash and it tells you if anything is missing.';

  @override
  String get onboardingContentCashRegisterNoRegister =>
      'No register? Leave it off. You can switch it on later in Settings > Shop details.';

  @override
  String apiErrorReturnsAWalkInCustomerCannotKeepCredit(String amount) {
    return 'A walk-in customer cannot keep credit: hand back $amount.';
  }

  @override
  String get apiErrorReturnsCouldNotGenerateAReturnNumber =>
      'Could not generate a return number, try again.';

  @override
  String get apiErrorReturnsOnlyADeliveredOrderCanHave =>
      'Only a delivered order can have goods returned. Cancel an order that has not been delivered.';

  @override
  String apiErrorReturnsOnlyCanStillBeReturned(String max, String name) {
    return 'Only $max of $name can still be returned.';
  }

  @override
  String get apiErrorReturnsReturnNotFound => 'Return not found';

  @override
  String get apiErrorReturnsThatItemIsNotOnThisOrder =>
      'That item is not on this order.';

  @override
  String apiErrorReturnsTheRefundCannotBeMoreThan(String max) {
    return 'The money handed back cannot be more than $max.';
  }

  @override
  String get returnButton => 'Return items';

  @override
  String returnTitle(String orderNo) {
    return 'Return items · $orderNo';
  }

  @override
  String returnDone(String returnNo) {
    return 'Return $returnNo recorded.';
  }

  @override
  String returnSold(int sold, int back) {
    return 'Sold $sold · returned before $back';
  }

  @override
  String get returnFullyReturned => 'All of this was returned already.';

  @override
  String get returnDamaged => 'Damaged: do not put it back in stock';

  @override
  String get returnGoodsValue => 'Value of the goods';

  @override
  String get returnSettledSoFar => 'Settled so far';

  @override
  String get returnLowersDue => 'This lowers what the customer still owes.';

  @override
  String returnMoneyTitle(String amount) {
    return '$amount was paid for goods that are coming back';
  }

  @override
  String get returnHandBack => 'Hand the money back';

  @override
  String get returnKeepCredit => 'Keep it as credit on the customer\'s account';

  @override
  String get returnWalkInHint =>
      'A walk-in customer cannot keep credit, so the money is handed back.';

  @override
  String get returnMethod => 'Paid back by';

  @override
  String get returnAmount => 'Amount handed back';

  @override
  String returnUpTo(String amount) {
    return 'Up to $amount';
  }

  @override
  String get returnNote => 'Note (optional)';

  @override
  String get returnConfirm => 'Return the items';

  @override
  String get returnNothingChosen => 'Choose how many units come back';

  @override
  String get orderDetailReturnedGoods => 'Returned goods';

  @override
  String get orderDetailRefund => 'Refund';

  @override
  String get registerRefunded => 'Cash handed back for returns';

  @override
  String get orderDetailReturns => 'Returns';

  @override
  String orderDetailReturnUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String orderDetailReturnRefunded(String amount, String method) {
    return '$amount handed back by $method';
  }

  @override
  String get orderDetailReturnCredit => 'Kept as credit on the account';

  @override
  String apiErrorExpensesACategoryNamedAlreadyExists(String name) {
    return 'An expense category named \"$name\" already exists.';
  }

  @override
  String get apiErrorExpensesCategoryNameIsRequired =>
      'The category name is required.';

  @override
  String get apiErrorExpensesCategoryNotFound => 'Expense category not found';

  @override
  String get apiErrorExpensesExpenseNotFound => 'Expense not found';

  @override
  String get apiErrorExpensesThisCategoryIsSwitchedOff =>
      'This expense category is switched off. Choose another one.';

  @override
  String get apiErrorExpensesThisExpenseWasAlreadyVoided =>
      'This expense was already voided.';

  @override
  String get moduleExpenses => 'Expenses';

  @override
  String get expensesAdd => 'Add expense';

  @override
  String get expensesCancel => 'Cancel';

  @override
  String get expensesCategories => 'Categories';

  @override
  String get expensesPreviousMonth => 'Previous month';

  @override
  String get expensesNextMonth => 'Next month';

  @override
  String get expensesAllCategories => 'All categories';

  @override
  String get expensesSpent => 'Spent';

  @override
  String get expensesCountLabel => 'Expenses';

  @override
  String get expensesByCategory => 'By category';

  @override
  String get expensesNone => 'No expenses recorded for this month yet.';

  @override
  String get expensesVoid => 'Void';

  @override
  String get expensesVoided => 'Voided';

  @override
  String get expensesVoidTitle => 'Void this expense?';

  @override
  String expensesVoidBody(String amount, String category) {
    return '$amount under $category stays in the list but no longer counts. If it was a mistake, enter it again.';
  }

  @override
  String get expensesVoidReason => 'Reason (optional)';

  @override
  String get expensesVoidDone => 'Expense voided.';

  @override
  String get expensesSaved => 'Expense recorded.';

  @override
  String get expenseFormTitle => 'Add expense';

  @override
  String get expenseFormCategory => 'Category';

  @override
  String get expenseFormAmount => 'Amount';

  @override
  String get expenseFormEnterAmount => 'Enter an amount above zero';

  @override
  String get expenseFormMethod => 'Paid by';

  @override
  String get expenseFormReference => 'Transaction number or bank';

  @override
  String get expenseFormPayee => 'Paid to (optional)';

  @override
  String get expenseFormNote => 'Note (optional)';

  @override
  String get expenseFormNoCategories =>
      'There are no expense categories yet. Add some first (Rent, Salaries, Electricity...) with the categories button.';

  @override
  String get expenseFormSave => 'Save expense';

  @override
  String get expenseCatTitle => 'Expense categories';

  @override
  String get expenseCatNew => 'New category';

  @override
  String get expenseCatAdd => 'Add';

  @override
  String get expenseCatAddCommon => 'Add the usual ones';

  @override
  String get expenseCatRename => 'Rename';

  @override
  String get expenseCatSave => 'Save';

  @override
  String get expenseCatDone => 'Done';

  @override
  String expenseCatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
      zero: 'No expenses',
    );
    return '$_temp0';
  }

  @override
  String expenseCatCommonAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories added.',
      one: '1 category added.',
      zero: 'All the usual categories are already there.',
    );
    return '$_temp0';
  }

  @override
  String get expenseCommonRent => 'Rent';

  @override
  String get expenseCommonSalaries => 'Salaries';

  @override
  String get expenseCommonElectricity => 'Electricity';

  @override
  String get expenseCommonWaterGas => 'Water and gas';

  @override
  String get expenseCommonInternetPhone => 'Internet and phone';

  @override
  String get expenseCommonTransport => 'Transport and fuel';

  @override
  String get expenseCommonRepairs => 'Repairs and maintenance';

  @override
  String get expenseCommonPackaging => 'Packaging';

  @override
  String get expenseCommonMarketing => 'Marketing';

  @override
  String get expenseCommonTeaFood => 'Tea and food';

  @override
  String get expenseCommonTaxesFees => 'Taxes and fees';

  @override
  String get expenseCommonOther => 'Other';

  @override
  String get registerSpent => 'Cash spent on expenses';

  @override
  String dashboardExpensesMonth(String amount) {
    return 'Expenses this month ($amount today)';
  }

  @override
  String get dashboardEstimatedProfit =>
      'Estimated profit this month (sales less cost of goods and expenses)';

  @override
  String get moduleReports => 'Reports';

  @override
  String get reportKindSales => 'Sales';

  @override
  String get reportKindProfit => 'Profit';

  @override
  String get reportKindStock => 'Stock that does not sell';

  @override
  String get reportKindReceivables => 'Customers who owe';

  @override
  String get reportKindPayables => 'Vendors owed';

  @override
  String get reportRangeToday => 'Today';

  @override
  String get reportRangeLast7 => 'Last 7 days';

  @override
  String get reportRangeThisMonth => 'This month';

  @override
  String get reportRangeLastMonth => 'Last month';

  @override
  String get reportRangeThisYear => 'This year';

  @override
  String get reportRangeCustom => 'Pick days';

  @override
  String get reportExportCsv => 'Save as CSV (for a spreadsheet)';

  @override
  String get reportExportPdf => 'Save as PDF';

  @override
  String get reportSaveAs => 'Save the report';

  @override
  String get reportSaved => 'Report saved.';

  @override
  String get reportNothing => 'Nothing to show for this report.';

  @override
  String reportDays(int count) {
    return '$count days';
  }

  @override
  String get reportTotal => 'Total';

  @override
  String get reportOnlineStore => 'Online store';

  @override
  String get reportNeverSold => 'Never';

  @override
  String get reportSalesByProduct => 'Sales by product';

  @override
  String get reportSalesByCategory => 'Sales by category';

  @override
  String get reportSalesByCustomer => 'Sales by customer';

  @override
  String get reportSalesByCashier => 'Sales by cashier';

  @override
  String get reportColProduct => 'Product';

  @override
  String get reportColCategory => 'Category';

  @override
  String get reportColCustomer => 'Customer';

  @override
  String get reportColVendor => 'Vendor';

  @override
  String get reportColCashier => 'Cashier';

  @override
  String get reportColUnits => 'Units';

  @override
  String get reportColOrders => 'Orders';

  @override
  String get reportColRevenue => 'Sales';

  @override
  String get reportColReturned => 'Returned';

  @override
  String get reportColCost => 'Cost';

  @override
  String get reportColProfit => 'Profit';

  @override
  String get reportColMargin => 'Margin';

  @override
  String get reportColExpenses => 'Expenses';

  @override
  String get reportColDay => 'Day';

  @override
  String get reportColSku => 'SKU';

  @override
  String get reportColOnHand => 'On hand';

  @override
  String get reportColStockValue => 'Value at cost';

  @override
  String get reportColSold => 'Sold';

  @override
  String get reportColLastSold => 'Last sold';

  @override
  String get reportColStatus => 'Status';

  @override
  String get reportColPhone => 'Phone';

  @override
  String get reportColBalance => 'Owed';

  @override
  String get reportColAge030 => '0-30 days';

  @override
  String get reportColAge3160 => '31-60 days';

  @override
  String get reportColAge6190 => '61-90 days';

  @override
  String get reportColAge90 => 'Over 90 days';

  @override
  String get reportColOldestDays => 'Oldest (days)';

  @override
  String get reportProfitTitle => 'Profit and margin';

  @override
  String get reportProfitRevenue => 'Sales after discounts';

  @override
  String get reportProfitReturned => 'Returned by customers';

  @override
  String get reportProfitNetRevenue => 'Net sales';

  @override
  String get reportProfitCost => 'Cost of the goods sold';

  @override
  String get reportProfitGross => 'Gross profit';

  @override
  String get reportProfitMargin => 'Gross margin';

  @override
  String get reportProfitExpenses => 'Expenses';

  @override
  String get reportProfitNet => 'Net profit';

  @override
  String get reportProfitShipping =>
      'Delivery fees charged (not in the profit)';

  @override
  String get reportStockTitle => 'Stock that does not sell';

  @override
  String reportStockWindow(int days) {
    return 'Looking at the last $days days';
  }

  @override
  String reportStockDeadLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 with no sale (money tied up)';
  }

  @override
  String reportStockSlowLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 selling slowly (money tied up)';
  }

  @override
  String get reportStockDead => 'No sales';

  @override
  String get reportStockSlow => 'Slow';

  @override
  String get reportStockNew => 'New';

  @override
  String get reportStockOk => 'Selling';

  @override
  String get reportReceivablesTitle => 'Customers who owe money';

  @override
  String get reportPayablesTitle => 'Vendors who are owed money';

  @override
  String get apiErrorReportsTheFirstDayIsAfterTheLastDay =>
      'The first day is after the last day.';

  @override
  String get taxNameGst => 'GST';

  @override
  String get taxNameVat => 'VAT';

  @override
  String taxLine(String name, String rate) {
    return '$name $rate%';
  }

  @override
  String taxLineIncluded(String name, String rate) {
    return 'Includes $name $rate%';
  }

  @override
  String receiptTaxNumber(String number) {
    return 'Tax no. $number';
  }

  @override
  String get taxSettingsTitle => 'Tax';

  @override
  String get taxSettingsSwitch => 'Charge tax on sales';

  @override
  String get taxSettingsHint =>
      'GST and VAT are charged on the goods after discounts, never on the delivery fee. If you charge both, both apply to the same price. Leave a rate at 0 if you do not charge it.';

  @override
  String get taxGstRate => 'GST rate (%)';

  @override
  String get taxVatRate => 'VAT rate (%)';

  @override
  String get taxIncludesTitle => 'Do your shelf prices already include tax?';

  @override
  String get taxIncludesYes => 'Yes, the tax is inside the price';

  @override
  String get taxIncludesNo => 'No, add the tax on top';

  @override
  String get taxNumberLabel => 'Tax registration number (printed on receipts)';

  @override
  String get taxSave => 'Save tax settings';

  @override
  String get taxSaved => 'Tax settings saved.';

  @override
  String get taxNeedsRate => 'Enter a GST or VAT rate above 0.';

  @override
  String get taxRateInvalid => 'A rate is a number from 0 to 100.';

  @override
  String get taxAdminOnly => 'Only an admin can change the tax settings.';

  @override
  String get reportKindTax => 'Tax';

  @override
  String get reportTaxTitle => 'Tax summary';

  @override
  String get reportColTax => 'Tax';

  @override
  String get reportColCollected => 'Collected on sales';

  @override
  String get reportColGivenBack => 'Given back on returns';

  @override
  String get reportColTaxOwed => 'To pay';

  @override
  String get reportTaxSalesWithoutTax =>
      'Sales before tax (orders that carried tax)';

  @override
  String get reportTaxOrders => 'Orders with tax';

  @override
  String get reportTaxReturns => 'Returns with tax';

  @override
  String get returnTaxGivenBack => 'Tax on these goods (given back too)';

  @override
  String get returnTaxIncluded => 'Tax inside these prices';

  @override
  String get modulePurchaseOrders => 'Purchase orders';

  @override
  String get poStatusOpen => 'Open';

  @override
  String get poStatusPartial => 'Partly received';

  @override
  String get poStatusReceived => 'Received';

  @override
  String get poStatusClosed => 'Closed';

  @override
  String get poStatusCancelled => 'Cancelled';

  @override
  String get poFilterAll => 'All';

  @override
  String get poNewOrder => 'New order';

  @override
  String get poSearchHint => 'Search by order number or vendor';

  @override
  String get poNone => 'No purchase orders yet.';

  @override
  String poReceivedOfUnits(int received, int ordered) {
    return '$received of $ordered units received';
  }

  @override
  String poExpected(String date) {
    return 'Expected $date';
  }

  @override
  String poExpectedLate(String date) {
    return 'Expected $date: late';
  }

  @override
  String poCreated(String number) {
    return 'Purchase order $number created.';
  }

  @override
  String get poFormHint =>
      'An order only records what you asked the vendor for. Stock and what you owe change when the goods arrive.';

  @override
  String get poChooseVendor => 'Choose a vendor';

  @override
  String get poExpectedOptional => 'When do you expect it? (optional)';

  @override
  String get poItems => 'Items';

  @override
  String get poAddItem => 'Add item';

  @override
  String get poNoItemsYet => 'Add what you want to order.';

  @override
  String get poRemoveItem => 'Remove';

  @override
  String get poQuantity => 'Quantity';

  @override
  String get poUnitCost => 'Price per unit';

  @override
  String get poNote => 'Note (optional)';

  @override
  String poOrderTotal(String amount) {
    return 'Order total: $amount';
  }

  @override
  String get poPlaceOrder => 'Place order';

  @override
  String get poOrderedValue => 'Ordered';

  @override
  String get poReceivedValue => 'Received so far';

  @override
  String get poReceiveGoods => 'Receive goods';

  @override
  String get poConfirm => 'Yes';

  @override
  String get poCancelOrder => 'Cancel order';

  @override
  String get poCancelConfirm =>
      'Cancel this order? Nothing has arrived for it.';

  @override
  String get poCancelled => 'Order cancelled.';

  @override
  String get poCloseOrder => 'Close order';

  @override
  String get poCloseConfirm =>
      'Close this order? What has not arrived will not be received on it.';

  @override
  String get poClosed => 'Order closed.';

  @override
  String poLineProgress(int received, int ordered, String price) {
    return '$received of $ordered received at $price';
  }

  @override
  String poStillToCome(int count) {
    return '$count still to come';
  }

  @override
  String get poReceipts => 'Goods received';

  @override
  String poReceiveTitle(String number) {
    return 'Receive goods · $number';
  }

  @override
  String poReceiveHint(String vendor) {
    return 'Say how many of each item arrived from $vendor. Stock goes up and what you owe the vendor goes up by the same step.';
  }

  @override
  String get poArrived => 'Arrived';

  @override
  String poMostIs(int count) {
    return 'At most $count';
  }

  @override
  String get poInvoicePrice => 'Price on the invoice';

  @override
  String get poInvoiceNo => 'Invoice number (optional)';

  @override
  String get poPaidNow => 'Paid to the vendor now (optional)';

  @override
  String get poPaidNowHint => 'Leave empty to pay later.';

  @override
  String poPaidTooMuch(String total) {
    return 'More than the $total that arrived';
  }

  @override
  String poReceivingValue(String amount) {
    return 'Receiving: $amount';
  }

  @override
  String get poReceivedDone => 'Goods received.';

  @override
  String get apiErrorBusinessTaxNeedsARate =>
      'To charge tax, set a GST rate or a VAT rate above 0.';

  @override
  String get apiErrorPurchaseOrdersCouldNotGenerateAnOrderNumber =>
      'Could not generate an order number, try again.';

  @override
  String get apiErrorPurchaseOrdersOnlyAPartlyReceivedOrderCanBeClosed =>
      'Only a partly received order can be closed.';

  @override
  String get apiErrorPurchaseOrdersOnlyAnOpenOrderCanBeReceived =>
      'Goods can only be received against an order that is open or partly received.';

  @override
  String get apiErrorPurchaseOrdersOnlyAnOrderNothingArrivedForCanBeCancelled =>
      'Only an order that nothing has arrived for can be cancelled. Close it instead.';

  @override
  String apiErrorPurchaseOrdersOnlyCanStillBeReceived(String max, String name) {
    return 'Only $max of $name can still be received on this order.';
  }

  @override
  String get apiErrorPurchaseOrdersPurchaseOrderNotFound =>
      'Purchase order not found';

  @override
  String get apiErrorPurchaseOrdersThatLineIsNotOnThisOrder =>
      'That line is not on this order.';

  @override
  String get apiErrorPurchaseOrdersThisOrderAlreadyExists =>
      'This purchase order already exists.';

  @override
  String get moduleReorder => 'Reorder suggestions';

  @override
  String get reorderLookBack => 'Sales looked at:';

  @override
  String get reorderCover => 'Order enough for:';

  @override
  String get reorderNone => 'Nothing needs ordering right now.';

  @override
  String get reorderReasonOut => 'Out of stock';

  @override
  String get reorderReasonLow => 'Low';

  @override
  String get reorderReasonRunning => 'Running out';

  @override
  String reorderLine(int onHand, int onOrder) {
    return 'On hand $onHand · on order $onOrder';
  }

  @override
  String reorderSpeed(String perDay, String days) {
    return 'Sells $perDay a day, about $days days left';
  }

  @override
  String get reorderNoSales => 'No sales in this period';

  @override
  String get reorderNoVendor => 'No vendor yet';

  @override
  String get reorderNoVendorHint =>
      'These were never bought from an active vendor. Choose one to order them.';

  @override
  String get reorderChooseVendor => 'Choose vendor';

  @override
  String get reorderCreate => 'Create order';

  @override
  String reorderGroupTotal(int count, String amount) {
    return '$count items · $amount';
  }

  @override
  String reorderCreated(String number) {
    return 'Order $number created. Nothing changes in stock until the goods arrive.';
  }

  @override
  String get reorderOpen => 'Open';

  @override
  String get reorderNote => 'From reorder suggestions';

  @override
  String get poSendToVendor => 'Send to vendor';

  @override
  String get poSendWhatsApp => 'WhatsApp';

  @override
  String get poSendWhatsAppHint =>
      'Opens a chat with the order written out; you press send.';

  @override
  String get poSendSharePdf => 'Share PDF';

  @override
  String get poSendPrintPdf => 'Print or save PDF';

  @override
  String get poSendVendorPhone => 'Vendor phone';

  @override
  String poMsgTitle(String number) {
    return 'Purchase order $number';
  }

  @override
  String poMsgTo(String vendor) {
    return 'To: $vendor';
  }

  @override
  String poMsgDate(String date) {
    return 'Date: $date';
  }

  @override
  String poMsgExpected(String date) {
    return 'Expected by: $date';
  }

  @override
  String get poMsgStillToCome => 'Still to be delivered:';

  @override
  String poMsgLine(int quantity, String name, String price, String total) {
    return '$quantity x $name @ $price = $total';
  }

  @override
  String poMsgTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String poMsgNote(String note) {
    return 'Note: $note';
  }

  @override
  String get poMsgClosing =>
      'Please confirm availability and the delivery date. Thank you.';

  @override
  String get poPdfVendor => 'Vendor';

  @override
  String get poPdfDate => 'Date';

  @override
  String get poPdfExpected => 'Expected by';

  @override
  String get poPdfNote => 'Note';

  @override
  String get barcodeRequiredTitle => 'Barcodes are required';

  @override
  String get barcodeRequiredHint =>
      'Off: a barcode is optional. On: every new item needs one (items you already have are not affected). You can switch it any time.';

  @override
  String get variantBarcodeRequired => 'Barcode';

  @override
  String get variantBarcodeCreate => 'Create a barcode';

  @override
  String get variantBarcodeNeeded =>
      'A barcode is required. Scan one, type it, or press the wand to create one.';

  @override
  String get variantBarcodeUsed => 'Another item already has this barcode.';

  @override
  String catalogBarcodeRequired(String sku) {
    return 'A barcode is required for $sku.';
  }

  @override
  String catalogBarcodeTwice(String barcode) {
    return 'The barcode $barcode is used twice in this product.';
  }

  @override
  String catalogBarcodeBelongsTo(String barcode, String name) {
    return 'The barcode $barcode already belongs to $name.';
  }

  @override
  String get onboardingContentBarcodes => 'Do you use barcodes?';

  @override
  String get onboardingContentBarcodesBody =>
      'A barcode lets you ring up an item by scanning it, and lets you print price labels. It is optional by default: you can add one to any item when you like. Switch this on only if every item must have one.';

  @override
  String get onboardingContentBarcodesLabels =>
      'You can print labels for any item, with its barcode or its SKU, from the Labels page.';

  @override
  String apiErrorProductsABarcodeIsRequired(String sku) {
    return 'A barcode is required for $sku.';
  }

  @override
  String apiErrorProductsBarcodeAlreadyBelongsTo(
      String barcode, String name, String sku) {
    return 'The barcode $barcode already belongs to $name ($sku).';
  }

  @override
  String apiErrorProductsBarcodeIsUsedTwiceInThis(String barcode) {
    return 'The barcode $barcode is used twice in this product.';
  }

  @override
  String get moduleLabels => 'Labels';

  @override
  String get labelsSearch => 'Search by name, SKU or barcode';

  @override
  String get labelsSize => 'Label size';

  @override
  String labelsSizeRoll(String size) {
    return 'Label roll $size mm';
  }

  @override
  String labelsSizeSheet(int count, String grid) {
    return 'A4 sheet of $count labels ($grid)';
  }

  @override
  String get labelsSkip => 'Places already used';

  @override
  String get labelsShowName => 'Name';

  @override
  String get labelsShowPrice => 'Price';

  @override
  String get labelsShowSku => 'SKU';

  @override
  String get labelsUseSku => 'SKU as the bar code when there is no barcode';

  @override
  String get labelsCopies => 'Labels';

  @override
  String get labelsOneEach => '1 each';

  @override
  String get labelsClear => 'Clear';

  @override
  String get labelsNoItems => 'No items to show.';

  @override
  String get labelsNothing => 'Choose how many labels each item needs.';

  @override
  String labelsSummary(int labels, int pages) {
    return '$labels labels, $pages pages';
  }

  @override
  String get labelsPrint => 'Print';

  @override
  String get labelsShare => 'Share PDF';

  @override
  String get labelsSkuCode => 'SKU as the bar code';

  @override
  String get labelsNoCode => 'No bar code';

  @override
  String get posPromotions => 'Promotions';

  @override
  String get posCoupon => 'Coupon';

  @override
  String get posCouponAdd => 'Add';

  @override
  String get posCouponCode => 'Coupon code';

  @override
  String get posCouponApply => 'Apply';

  @override
  String posCouponNotValid(String code) {
    return '$code (not valid)';
  }

  @override
  String posPromotionsNote(String names) {
    return 'Promotions: $names';
  }

  @override
  String get modulePromotions => 'Promotions';

  @override
  String get promoNew => 'New promotion';

  @override
  String get promoEdit => 'Change promotion';

  @override
  String get promoNone =>
      'No promotions yet. Make one to give a percent off the order, a category or a product, with bulk prices and coupon codes.';

  @override
  String promoDeleteConfirm(String name) {
    return 'Delete the promotion \"$name\"?';
  }

  @override
  String get promoStatusOn => 'On';

  @override
  String get promoStatusOff => 'Off';

  @override
  String promoStatusScheduled(String date) {
    return 'Starts $date';
  }

  @override
  String get promoStatusEnded => 'Ended';

  @override
  String promoCodeTag(String code) {
    return 'Code $code';
  }

  @override
  String get promoChannelPos => 'Counter';

  @override
  String get promoChannelWeb => 'Online store';

  @override
  String promoDescOrderPercent(String percent) {
    return '$percent% off the order';
  }

  @override
  String promoDescOrderAmount(String amount) {
    return '$amount off the order';
  }

  @override
  String promoDescLinePercent(String percent, String target) {
    return '$percent% off $target';
  }

  @override
  String promoDescLineAmount(String amount, String target) {
    return '$amount off each $target';
  }

  @override
  String promoDescMinQuantity(int count) {
    return 'from $count units';
  }

  @override
  String promoDescMinAmount(String amount) {
    return 'orders of $amount or more';
  }

  @override
  String get promoName => 'Name (for example \"Cricket week\")';

  @override
  String get promoAppliesTo => 'It takes a discount off';

  @override
  String get promoScopeOrder => 'The order';

  @override
  String get promoScopeCategory => 'A category';

  @override
  String get promoScopeProduct => 'A product';

  @override
  String get promoPickCategory => 'Category';

  @override
  String get promoPickProduct => 'Product';

  @override
  String get promoCategoryHint => 'Its sub-categories are included.';

  @override
  String get promoDiscount => 'Discount';

  @override
  String get promoKindPercent => 'Percent';

  @override
  String get promoKindAmount => 'Amount';

  @override
  String get promoValuePercent => 'Percent off';

  @override
  String get promoValueAmountEach => 'Amount off each unit';

  @override
  String get promoValueAmountOrder => 'Amount off the order';

  @override
  String get promoMinQuantity => 'Bulk price: from this many units (optional)';

  @override
  String get promoMinQuantityHint =>
      'Leave empty for any number. Make several promotions for several tiers: the best one applies.';

  @override
  String get promoMinAmount => 'Only for orders of at least (optional)';

  @override
  String get promoMinAmountHint =>
      'Counted after the discounts on categories and products.';

  @override
  String get promoCode => 'Coupon code (optional)';

  @override
  String get promoCodeHint =>
      'With a code, the customer has to name it. Without one the promotion applies by itself.';

  @override
  String get promoWhere => 'Where it applies';

  @override
  String get promoStarts => 'Starts: any day';

  @override
  String get promoEnds => 'Ends: never';

  @override
  String promoStartsOn(String date) {
    return 'Starts $date';
  }

  @override
  String promoEndsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get promoSwitchedOn => 'Switched on';

  @override
  String get promoSave => 'Save promotion';

  @override
  String get promoNeedName => 'Give the promotion a name.';

  @override
  String get promoNeedValue => 'Enter the discount, above zero.';

  @override
  String get promoPercentMax => 'A percent cannot be more than 100.';

  @override
  String get promoNeedTarget => 'Choose the category or the product.';

  @override
  String get promoNeedChannel => 'Choose where it applies.';

  @override
  String get promoEndBeforeStart => 'The end date is before the start date.';

  @override
  String get apiErrorPromotionsAPercentIsBetween1And100 =>
      'A percent must be between 1 and 100.';

  @override
  String get apiErrorPromotionsChooseACategoryOrAProduct =>
      'Choose the category or the product the promotion is for.';

  @override
  String get apiErrorPromotionsGiveThePromotionAName =>
      'Give the promotion a name.';

  @override
  String get apiErrorPromotionsPromotionNotFound => 'Promotion not found';

  @override
  String apiErrorPromotionsThatCodeIsAlreadyUsed(String code) {
    return 'The code $code is already used by another promotion.';
  }

  @override
  String get apiErrorPromotionsThatCouponCodeIsNotValid =>
      'That coupon code is not valid.';

  @override
  String get apiErrorPromotionsTheEndIsBeforeTheStart =>
      'The end date is before the start date.';
}
