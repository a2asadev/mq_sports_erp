import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The product name. Also the window / task-switcher title.
  ///
  /// In en, this message translates to:
  /// **'A2 Stocks'**
  String get appTitle;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get commonSomethingWentWrong;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// Shown when the sign-in state itself cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String authError(Object error);

  /// No description provided for @accessNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Your account is not registered in A2 Stocks. Contact your administrator.'**
  String get accessNotRegistered;

  /// No description provided for @accessInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive. Contact your administrator.'**
  String get accessInactive;

  /// No description provided for @accessCouldNotVerify.
  ///
  /// In en, this message translates to:
  /// **'Your account could not be verified.'**
  String get accessCouldNotVerify;

  /// No description provided for @categoriesStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get categoriesStatus;

  /// No description provided for @categoriesProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get categoriesProducts;

  /// No description provided for @categoriesParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get categoriesParent;

  /// No description provided for @categoriesCategorySubcategory.
  ///
  /// In en, this message translates to:
  /// **'Category / Subcategory'**
  String get categoriesCategorySubcategory;

  /// No description provided for @categoriesDirectlyInInIts.
  ///
  /// In en, this message translates to:
  /// **'{directProducts} directly in {name}\n{productsInSubcategories} in its subcategories'**
  String categoriesDirectlyInInIts(
      Object directProducts, Object name, Object productsInSubcategories);

  /// No description provided for @categoriesSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get categoriesSubcategories;

  /// No description provided for @categoriesCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoriesCategory;

  /// No description provided for @categoriesNoCategoriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No categories match.'**
  String get categoriesNoCategoriesMatch;

  /// No description provided for @categoriesAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoriesAddCategory;

  /// No description provided for @categoriesStarterPacks.
  ///
  /// In en, this message translates to:
  /// **'Starter packs'**
  String get categoriesStarterPacks;

  /// No description provided for @categoriesCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesCategories;

  /// No description provided for @categoriesSearchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get categoriesSearchCategories;

  /// No description provided for @categoriesWithoutProducts.
  ///
  /// In en, this message translates to:
  /// **'Without products'**
  String get categoriesWithoutProducts;

  /// No description provided for @categoriesSubcategoriesInTotal.
  ///
  /// In en, this message translates to:
  /// **'Subcategories in total'**
  String get categoriesSubcategoriesInTotal;

  /// No description provided for @categoriesMainCategories.
  ///
  /// In en, this message translates to:
  /// **'Main categories'**
  String get categoriesMainCategories;

  /// No description provided for @categoriesStartFromATemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from a template'**
  String get categoriesStartFromATemplate;

  /// No description provided for @categoriesStartFromAReady.
  ///
  /// In en, this message translates to:
  /// **'Start from a ready-made set for your kind of business, or add them one by one.'**
  String get categoriesStartFromAReady;

  /// No description provided for @categoriesNoCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get categoriesNoCategoriesYet;

  /// No description provided for @categoriesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoriesDelete;

  /// No description provided for @categoriesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get categoriesEdit;

  /// No description provided for @categoriesAddSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get categoriesAddSubcategory;

  /// No description provided for @categoriesActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get categoriesActions;

  /// No description provided for @categoriesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoriesCancel;

  /// No description provided for @categoriesDelete2.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String categoriesDelete2(Object name);

  /// No description provided for @categoriesDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoriesDeleteCategory;

  /// No description provided for @categoriesAddedCategories.
  ///
  /// In en, this message translates to:
  /// **'Added {created} categories{already}.'**
  String categoriesAddedCategories(Object created, Object already);

  /// No description provided for @categoryFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get categoryFormActive;

  /// No description provided for @categoryFormDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get categoryFormDescriptionOptional;

  /// No description provided for @categoryFormNoneTopLevel.
  ///
  /// In en, this message translates to:
  /// **'None (top level)'**
  String get categoryFormNoneTopLevel;

  /// No description provided for @categoryFormParentCategory.
  ///
  /// In en, this message translates to:
  /// **'Parent category'**
  String get categoryFormParentCategory;

  /// No description provided for @categoryFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryFormName;

  /// No description provided for @categoryFormCategoryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Category photo'**
  String get categoryFormCategoryPhoto;

  /// No description provided for @productsAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productsAddProduct;

  /// No description provided for @productsInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get productsInactive;

  /// No description provided for @productsSearchNameBrandSku.
  ///
  /// In en, this message translates to:
  /// **'Search name, brand, SKU or barcode'**
  String get productsSearchNameBrandSku;

  /// No description provided for @productsBrands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get productsBrands;

  /// No description provided for @productsVariants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get productsVariants;

  /// No description provided for @productsDeleteAndItsVariant.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and its {length, plural, =1{{length} variant} other{{length} variants}}?'**
  String productsDeleteAndItsVariant(Object name, int length);

  /// No description provided for @productsDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get productsDeleteProduct;

  /// No description provided for @productFormAddAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one variant.'**
  String get productFormAddAtLeastOne;

  /// No description provided for @productFormAddVariant.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get productFormAddVariant;

  /// No description provided for @productFormVariants.
  ///
  /// In en, this message translates to:
  /// **'Variants ({length})'**
  String productFormVariants(Object length);

  /// No description provided for @productFormBrandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get productFormBrandOptional;

  /// No description provided for @productFormProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productFormProductName;

  /// No description provided for @productFormRemoveVariant.
  ///
  /// In en, this message translates to:
  /// **'Remove variant'**
  String get productFormRemoveVariant;

  /// No description provided for @starterPackPickTheKindOf.
  ///
  /// In en, this message translates to:
  /// **'Pick the kind of business you run and we will add a ready-made set of categories. You can rename, move or delete any of them afterwards.'**
  String get starterPackPickTheKindOf;

  /// No description provided for @starterPackStarterPacksNeedA.
  ///
  /// In en, this message translates to:
  /// **'{value}\nStarter packs need a connection to the server.'**
  String starterPackStarterPacksNeedA(Object value);

  /// No description provided for @starterPackClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get starterPackClose;

  /// No description provided for @starterPackBackToTheList.
  ///
  /// In en, this message translates to:
  /// **'Back to the list'**
  String get starterPackBackToTheList;

  /// No description provided for @variantSaveVariant.
  ///
  /// In en, this message translates to:
  /// **'Save variant'**
  String get variantSaveVariant;

  /// No description provided for @variantAddAttribute.
  ///
  /// In en, this message translates to:
  /// **'Add attribute'**
  String get variantAddAttribute;

  /// No description provided for @variantRemoveAttribute.
  ///
  /// In en, this message translates to:
  /// **'Remove attribute'**
  String get variantRemoveAttribute;

  /// No description provided for @variantSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get variantSmall;

  /// No description provided for @variantValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get variantValue;

  /// No description provided for @variantSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get variantSize;

  /// No description provided for @variantAttributes.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get variantAttributes;

  /// No description provided for @variantFlagThisVariantWhen.
  ///
  /// In en, this message translates to:
  /// **'Flag this variant when stock is at or below this number. 0 = no alert.'**
  String get variantFlagThisVariantWhen;

  /// No description provided for @variantLowStockAlertLevel.
  ///
  /// In en, this message translates to:
  /// **'Low-stock alert level'**
  String get variantLowStockAlertLevel;

  /// No description provided for @variantWholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale price'**
  String get variantWholesalePrice;

  /// No description provided for @variantCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get variantCostPrice;

  /// No description provided for @variantAddsASeparateWholesale.
  ///
  /// In en, this message translates to:
  /// **'Adds a separate wholesale price'**
  String get variantAddsASeparateWholesale;

  /// No description provided for @variantWholesaleVariant.
  ///
  /// In en, this message translates to:
  /// **'Wholesale variant'**
  String get variantWholesaleVariant;

  /// No description provided for @variantBarcodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get variantBarcodeOptional;

  /// No description provided for @variantVariantNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Variant name (optional)'**
  String get variantVariantNameOptional;

  /// No description provided for @variantAutoCreateSku.
  ///
  /// In en, this message translates to:
  /// **'Auto-create SKU'**
  String get variantAutoCreateSku;

  /// No description provided for @variantSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get variantSku;

  /// No description provided for @dashboardTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get dashboardTopCategories;

  /// No description provided for @dashboardOrderS.
  ///
  /// In en, this message translates to:
  /// **'{value, plural, =1{{value} order} other{{value} orders}}'**
  String dashboardOrderS(int value);

  /// No description provided for @dashboardTopCustomers.
  ///
  /// In en, this message translates to:
  /// **'Top customers'**
  String get dashboardTopCustomers;

  /// No description provided for @dashboardRecentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent sales'**
  String get dashboardRecentSales;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAll;

  /// No description provided for @dashboardLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get dashboardLowStock;

  /// No description provided for @dashboardTopSelling.
  ///
  /// In en, this message translates to:
  /// **'Top selling'**
  String get dashboardTopSelling;

  /// No description provided for @dashboardOverallInformation.
  ///
  /// In en, this message translates to:
  /// **'Overall information'**
  String get dashboardOverallInformation;

  /// No description provided for @dashboardWalkInSalesHave.
  ///
  /// In en, this message translates to:
  /// **'Walk-in sales have no customer record, so they are counted on their own and are never new or returning.'**
  String get dashboardWalkInSalesHave;

  /// No description provided for @dashboardNewVsReturningCustomers.
  ///
  /// In en, this message translates to:
  /// **'New vs returning customers'**
  String get dashboardNewVsReturningCustomers;

  /// No description provided for @dashboardTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total sales  '**
  String get dashboardTotalSales;

  /// No description provided for @dashboardSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get dashboardSales;

  /// No description provided for @dashboardViewStock.
  ///
  /// In en, this message translates to:
  /// **'View stock'**
  String get dashboardViewStock;

  /// No description provided for @dashboardHasLeft.
  ///
  /// In en, this message translates to:
  /// **' has {onHand} left{more}. '**
  String dashboardHasLeft(Object onHand, Object more);

  /// No description provided for @dashboardRunningLow.
  ///
  /// In en, this message translates to:
  /// **'Running low: '**
  String get dashboardRunningLow;

  /// No description provided for @dashboardUnitsInStock.
  ///
  /// In en, this message translates to:
  /// **'Units in stock'**
  String get dashboardUnitsInStock;

  /// No description provided for @dashboardPotentialMargin.
  ///
  /// In en, this message translates to:
  /// **'Potential margin'**
  String get dashboardPotentialMargin;

  /// No description provided for @dashboardStockAtRetail.
  ///
  /// In en, this message translates to:
  /// **'Stock at retail'**
  String get dashboardStockAtRetail;

  /// No description provided for @dashboardStockAtCost.
  ///
  /// In en, this message translates to:
  /// **'Stock at cost'**
  String get dashboardStockAtCost;

  /// No description provided for @dashboardPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending orders'**
  String get dashboardPendingOrders;

  /// No description provided for @dashboardSalesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Sales this month'**
  String get dashboardSalesThisMonth;

  /// No description provided for @dashboardSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get dashboardSalesToday;

  /// No description provided for @dashboardYouHaveOrderS.
  ///
  /// In en, this message translates to:
  /// **'You have {ordersToday, plural, =1{{ordersToday} order} other{{ordersToday} orders}} today · {value}'**
  String dashboardYouHaveOrderS(int ordersToday, Object value);

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {value}'**
  String dashboardWelcome(Object value);

  /// No description provided for @dashboardNoModulesAvailableFor.
  ///
  /// In en, this message translates to:
  /// **'No modules available for your role yet.'**
  String get dashboardNoModulesAvailableFor;

  /// No description provided for @homePos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get homePos;

  /// No description provided for @homeMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get homeMenu;

  /// No description provided for @activityLogsAllS.
  ///
  /// In en, this message translates to:
  /// **'All {value}s'**
  String activityLogsAllS(Object value);

  /// No description provided for @activityLogsLinked.
  ///
  /// In en, this message translates to:
  /// **'{related} linked'**
  String activityLogsLinked(Object related);

  /// No description provided for @activityLogsActivityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get activityLogsActivityLogs;

  /// No description provided for @activityLogsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get activityLogsClear;

  /// No description provided for @activityLogsLinkedEntries.
  ///
  /// In en, this message translates to:
  /// **'Linked entries'**
  String get activityLogsLinkedEntries;

  /// No description provided for @activityLogsUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get activityLogsUser;

  /// No description provided for @activityLogsModule.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get activityLogsModule;

  /// No description provided for @activityLogsType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get activityLogsType;

  /// No description provided for @activityLogsAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get activityLogsAllLevels;

  /// No description provided for @activityLogsSearchSummaryRecordUser.
  ///
  /// In en, this message translates to:
  /// **'Search summary, record, user, field or #id…'**
  String get activityLogsSearchSummaryRecordUser;

  /// No description provided for @activityLogsOnlyAdminsCanView.
  ///
  /// In en, this message translates to:
  /// **'Only admins can view the activity logs.'**
  String get activityLogsOnlyAdminsCanView;

  /// No description provided for @activityLogsShowLinked.
  ///
  /// In en, this message translates to:
  /// **'Show linked'**
  String get activityLogsShowLinked;

  /// No description provided for @activityLogsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get activityLogsCopy;

  /// No description provided for @activityLogsLogCopied.
  ///
  /// In en, this message translates to:
  /// **'Log copied.'**
  String get activityLogsLogCopied;

  /// No description provided for @activityLogsChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get activityLogsChanges;

  /// No description provided for @onboardingContentAddPhotosToProducts.
  ///
  /// In en, this message translates to:
  /// **'Add photos to products (several each), categories, customers, vendors and users. Your own photo is in Settings.'**
  String get onboardingContentAddPhotosToProducts;

  /// No description provided for @onboardingContentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get onboardingContentPhotos;

  /// No description provided for @onboardingContentEveryChangeIsRecorded.
  ///
  /// In en, this message translates to:
  /// **'Every change is recorded with who did it and when. Open Activity Logs to see sales, price changes, logins and more.'**
  String get onboardingContentEveryChangeIsRecorded;

  /// No description provided for @onboardingContentActivityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity logs'**
  String get onboardingContentActivityLogs;

  /// No description provided for @onboardingContentCustomersOrderOnYour.
  ///
  /// In en, this message translates to:
  /// **'Customers order on your website and pay cash on delivery.'**
  String get onboardingContentCustomersOrderOnYour;

  /// No description provided for @onboardingContentTheOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'The online store'**
  String get onboardingContentTheOnlineStore;

  /// No description provided for @onboardingContentCreateALoginFor.
  ///
  /// In en, this message translates to:
  /// **'Create a login for everyone under Users. Nobody should share one.'**
  String get onboardingContentCreateALoginFor;

  /// No description provided for @onboardingContentYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Your team'**
  String get onboardingContentYourTeam;

  /// No description provided for @onboardingContentDoTheseOnceIn.
  ///
  /// In en, this message translates to:
  /// **'Do these once, in this order:'**
  String get onboardingContentDoTheseOnceIn;

  /// No description provided for @onboardingContentFirstSetupChecklist.
  ///
  /// In en, this message translates to:
  /// **'First setup checklist'**
  String get onboardingContentFirstSetupChecklist;

  /// No description provided for @onboardingContentYouAreSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are signed in as Admin: you can see and change everything. Here is how to get the shop ready.'**
  String get onboardingContentYouAreSignedIn;

  /// No description provided for @onboardingContentWelcomeToA2Stocks.
  ///
  /// In en, this message translates to:
  /// **'Welcome to A2 Stocks'**
  String get onboardingContentWelcomeToA2Stocks;

  /// No description provided for @onboardingContentAddPhotosToProducts2.
  ///
  /// In en, this message translates to:
  /// **'Add photos to products, categories, customers and vendors. Product photos appear in the online store.'**
  String get onboardingContentAddPhotosToProducts2;

  /// No description provided for @onboardingContentCountTheShelfIn.
  ///
  /// In en, this message translates to:
  /// **'Count the shelf in Stock Audit; confirming it corrects the system to what you counted.'**
  String get onboardingContentCountTheShelfIn;

  /// No description provided for @onboardingContentStockAndAudits.
  ///
  /// In en, this message translates to:
  /// **'Stock and audits'**
  String get onboardingContentStockAndAudits;

  /// No description provided for @onboardingContentVendorsAndPurchasesRecord.
  ///
  /// In en, this message translates to:
  /// **'Vendors and Purchases record what you buy and what you owe. Confirming a purchase adds the stock.'**
  String get onboardingContentVendorsAndPurchasesRecord;

  /// No description provided for @onboardingContentBuyingStock.
  ///
  /// In en, this message translates to:
  /// **'Buying stock'**
  String get onboardingContentBuyingStock;

  /// No description provided for @onboardingContentSalesOrdersHoldsEvery.
  ///
  /// In en, this message translates to:
  /// **'Sales & Orders holds every order: from the counter and from the online store.'**
  String get onboardingContentSalesOrdersHoldsEvery;

  /// No description provided for @onboardingContentSalesAndOnlineOrders.
  ///
  /// In en, this message translates to:
  /// **'Sales and online orders'**
  String get onboardingContentSalesAndOnlineOrders;

  /// No description provided for @onboardingContentTheHomeScreenShows.
  ///
  /// In en, this message translates to:
  /// **'The home screen shows today\'s and this month\'s sales, what customers owe, low stock and the best sellers.'**
  String get onboardingContentTheHomeScreenShows;

  /// No description provided for @onboardingContentYourDashboard.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard'**
  String get onboardingContentYourDashboard;

  /// No description provided for @onboardingContentYouAreSignedIn2.
  ///
  /// In en, this message translates to:
  /// **'You are signed in as Manager: you run the shop day to day. This tour shows where things are.'**
  String get onboardingContentYouAreSignedIn2;

  /// No description provided for @onboardingContentAddACustomerWhen.
  ///
  /// In en, this message translates to:
  /// **'Add a customer when someone new buys. Their balance shows what they owe and the payments they made.'**
  String get onboardingContentAddACustomerWhen;

  /// No description provided for @onboardingContentCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get onboardingContentCustomers;

  /// No description provided for @onboardingContentLookUpProductsPrices.
  ///
  /// In en, this message translates to:
  /// **'Look up products, prices and photos under Products, and what is on the shelf under Stock.'**
  String get onboardingContentLookUpProductsPrices;

  /// No description provided for @onboardingContentProductsAndStock.
  ///
  /// In en, this message translates to:
  /// **'Products and stock'**
  String get onboardingContentProductsAndStock;

  /// No description provided for @onboardingContentOpenSalesOrdersTo.
  ///
  /// In en, this message translates to:
  /// **'Open Sales & Orders to make a sale.'**
  String get onboardingContentOpenSalesOrdersTo;

  /// No description provided for @onboardingContentSelling.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get onboardingContentSelling;

  /// No description provided for @onboardingContentYouAreSignedIn3.
  ///
  /// In en, this message translates to:
  /// **'You are signed in as Staff. This quick tour shows what you can do. It takes a minute.'**
  String get onboardingContentYouAreSignedIn3;

  /// No description provided for @onboardingContentOpenSettingsToAdd.
  ///
  /// In en, this message translates to:
  /// **'Open Settings to add your own photo and to see this guide again whenever you like.'**
  String get onboardingContentOpenSettingsToAdd;

  /// No description provided for @onboardingContentYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get onboardingContentYourProfile;

  /// No description provided for @onboardingContentOnPhonesAndComputers.
  ///
  /// In en, this message translates to:
  /// **'On phones and computers the app keeps working when the internet is down and sends your work to the shop\'s server when the connection returns. On the web version a connection is needed all the time.'**
  String get onboardingContentOnPhonesAndComputers;

  /// No description provided for @onboardingContentWorksWithOrWithout.
  ///
  /// In en, this message translates to:
  /// **'Works with or without internet'**
  String get onboardingContentWorksWithOrWithout;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome · {label}'**
  String onboardingWelcome(Object label);

  /// No description provided for @customersAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get customersAddCustomer;

  /// No description provided for @customersNoCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet.'**
  String get customersNoCustomersYet;

  /// No description provided for @ledgerEntrySaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get ledgerEntrySaveEntry;

  /// No description provided for @ledgerEntryReferenceReceiptNoOptional.
  ///
  /// In en, this message translates to:
  /// **'Reference / receipt no. (optional)'**
  String get ledgerEntryReferenceReceiptNoOptional;

  /// No description provided for @ledgerEntryDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ledgerEntryDate;

  /// No description provided for @ledgerEntryAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ledgerEntryAmount;

  /// No description provided for @ledgerEntryAddLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Add ledger entry'**
  String get ledgerEntryAddLedgerEntry;

  /// No description provided for @partyDetailAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get partyDetailAddEntry;

  /// No description provided for @partyDetailDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get partyDetailDeleteEntry;

  /// No description provided for @partyDetailBal.
  ///
  /// In en, this message translates to:
  /// **'Bal {value}'**
  String partyDetailBal(Object value);

  /// No description provided for @partyDetailNoLedgerEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No ledger entries yet.'**
  String get partyDetailNoLedgerEntriesYet;

  /// No description provided for @partyDetailOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get partyDetailOpeningBalance;

  /// No description provided for @partyDetailLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get partyDetailLedger;

  /// No description provided for @partyDetailThisRecordNoLonger.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get partyDetailThisRecordNoLonger;

  /// No description provided for @partyFormInactivePartiesAreHidden.
  ///
  /// In en, this message translates to:
  /// **'Inactive parties are hidden from pickers.'**
  String get partyFormInactivePartiesAreHidden;

  /// No description provided for @partyFormNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get partyFormNotesOptional;

  /// No description provided for @partyForm0MeansNoLimit.
  ///
  /// In en, this message translates to:
  /// **'0 means no limit.'**
  String get partyForm0MeansNoLimit;

  /// No description provided for @partyFormCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get partyFormCreditLimit;

  /// No description provided for @partyFormCityOptional.
  ///
  /// In en, this message translates to:
  /// **'City (optional)'**
  String get partyFormCityOptional;

  /// No description provided for @partyFormAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get partyFormAddressOptional;

  /// No description provided for @partyFormEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get partyFormEmailOptional;

  /// No description provided for @partyFormPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get partyFormPhone;

  /// No description provided for @partyFormContactPersonOptional.
  ///
  /// In en, this message translates to:
  /// **'Contact person (optional)'**
  String get partyFormContactPersonOptional;

  /// No description provided for @vendorsAddVendor.
  ///
  /// In en, this message translates to:
  /// **'Add vendor'**
  String get vendorsAddVendor;

  /// No description provided for @vendorsVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendorsVendors;

  /// No description provided for @vendorsNoVendorsYet.
  ///
  /// In en, this message translates to:
  /// **'No vendors yet.'**
  String get vendorsNoVendorsYet;

  /// No description provided for @heldSalesResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get heldSalesResume;

  /// No description provided for @heldSalesNoSalesOnHold.
  ///
  /// In en, this message translates to:
  /// **'No sales on hold.'**
  String get heldSalesNoSalesOnHold;

  /// No description provided for @heldSalesHeldSales.
  ///
  /// In en, this message translates to:
  /// **'Held sales'**
  String get heldSalesHeldSales;

  /// No description provided for @posPaymentCompleteSale.
  ///
  /// In en, this message translates to:
  /// **'Complete sale'**
  String get posPaymentCompleteSale;

  /// No description provided for @posPaymentBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get posPaymentBack;

  /// No description provided for @posPaymentGiveChange.
  ///
  /// In en, this message translates to:
  /// **'Give change: {prefix}{value}'**
  String posPaymentGiveChange(Object prefix, Object value);

  /// No description provided for @posPaymentFullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully paid'**
  String get posPaymentFullyPaid;

  /// No description provided for @posPaymentAddPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get posPaymentAddPayment;

  /// No description provided for @posPaymentExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get posPaymentExact;

  /// No description provided for @posPaymentLeftToPay.
  ///
  /// In en, this message translates to:
  /// **'Left to pay: {prefix}{value}'**
  String posPaymentLeftToPay(Object prefix, Object value);

  /// No description provided for @posPaymentRemoveThisPayment.
  ///
  /// In en, this message translates to:
  /// **'Remove this payment'**
  String get posPaymentRemoveThisPayment;

  /// No description provided for @posPaymentPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {prefix}{value}'**
  String posPaymentPay(Object prefix, Object value);

  /// No description provided for @posYourLoginCannotMake.
  ///
  /// In en, this message translates to:
  /// **'Your login cannot make sales.'**
  String get posYourLoginCannotMake;

  /// No description provided for @posHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get posHold;

  /// No description provided for @posTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get posTotalPayable;

  /// No description provided for @posItems.
  ///
  /// In en, this message translates to:
  /// **'Items : {units}'**
  String posItems(Object units);

  /// No description provided for @posNoProductsSelected.
  ///
  /// In en, this message translates to:
  /// **'No Products Selected'**
  String get posNoProductsSelected;

  /// No description provided for @posClearSale.
  ///
  /// In en, this message translates to:
  /// **'Clear sale'**
  String get posClearSale;

  /// No description provided for @posNewSale.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get posNewSale;

  /// No description provided for @posOrderList.
  ///
  /// In en, this message translates to:
  /// **'Order List'**
  String get posOrderList;

  /// No description provided for @posApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get posApply;

  /// No description provided for @posNoProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get posNoProductsFound;

  /// No description provided for @posAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posAll;

  /// No description provided for @posWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {who}'**
  String posWelcome(Object who);

  /// No description provided for @posSearchOrScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Search, or scan barcode / SKU and press Enter'**
  String get posSearchOrScanBarcode;

  /// No description provided for @posDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get posDashboard;

  /// No description provided for @posBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due: {prefix}{value}'**
  String posBalanceDue(Object prefix, Object value);

  /// No description provided for @posSaleComplete.
  ///
  /// In en, this message translates to:
  /// **'Sale complete'**
  String get posSaleComplete;

  /// No description provided for @posCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posCustomer;

  /// No description provided for @purchasesNewPurchase.
  ///
  /// In en, this message translates to:
  /// **'New purchase'**
  String get purchasesNewPurchase;

  /// No description provided for @purchasesPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchasesPurchases;

  /// No description provided for @purchasesOfPurchaseSShown.
  ///
  /// In en, this message translates to:
  /// **'{length} of {length2, plural, =1{{length2} purchase} other{{length2} purchases}} shown'**
  String purchasesOfPurchaseSShown(Object length, int length2);

  /// No description provided for @purchasesSearchPurchaseNoVendor.
  ///
  /// In en, this message translates to:
  /// **'Search purchase no., vendor, invoice…'**
  String get purchasesSearchPurchaseNoVendor;

  /// No description provided for @purchasesNotFullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Not fully paid'**
  String get purchasesNotFullyPaid;

  /// No description provided for @purchasesOwedToVendors.
  ///
  /// In en, this message translates to:
  /// **'Owed to vendors'**
  String get purchasesOwedToVendors;

  /// No description provided for @purchasesTotalPurchased.
  ///
  /// In en, this message translates to:
  /// **'Total purchased'**
  String get purchasesTotalPurchased;

  /// No description provided for @purchaseDetailSavePayment.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get purchaseDetailSavePayment;

  /// No description provided for @purchaseDetailNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get purchaseDetailNoteOptional;

  /// No description provided for @purchaseDetailDue.
  ///
  /// In en, this message translates to:
  /// **'Due: {value}'**
  String purchaseDetailDue(Object value);

  /// No description provided for @purchaseDetailRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get purchaseDetailRecordPayment;

  /// No description provided for @purchaseDetailNoPaymentsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get purchaseDetailNoPaymentsRecordedYet;

  /// No description provided for @purchaseDetailPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get purchaseDetailPayments;

  /// No description provided for @purchaseDetailSku.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku}'**
  String purchaseDetailSku(Object sku);

  /// No description provided for @purchaseDetailItemsUnits.
  ///
  /// In en, this message translates to:
  /// **'Items ({length} · {totalUnits} units)'**
  String purchaseDetailItemsUnits(Object length, Object totalUnits);

  /// No description provided for @purchaseDetailThisPurchaseNoLonger.
  ///
  /// In en, this message translates to:
  /// **'This purchase no longer exists.'**
  String get purchaseDetailThisPurchaseNoLonger;

  /// No description provided for @purchaseDetailPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchaseDetailPurchase;

  /// No description provided for @purchaseFormConfirmingAddsTheQuantities.
  ///
  /// In en, this message translates to:
  /// **'Confirming adds the quantities to stock and posts the purchase to the vendor ledger. It is uploaded to the cloud as one atomic change when you sync.'**
  String get purchaseFormConfirmingAddsTheQuantities;

  /// No description provided for @purchaseFormConfirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm purchase'**
  String get purchaseFormConfirmPurchase;

  /// No description provided for @purchaseFormPayLater.
  ///
  /// In en, this message translates to:
  /// **'Pay later'**
  String get purchaseFormPayLater;

  /// No description provided for @purchaseFormPaidInFull.
  ///
  /// In en, this message translates to:
  /// **'Paid in full'**
  String get purchaseFormPaidInFull;

  /// No description provided for @purchaseFormPaidNow.
  ///
  /// In en, this message translates to:
  /// **'Paid now'**
  String get purchaseFormPaidNow;

  /// No description provided for @purchaseFormTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {value}'**
  String purchaseFormTotal(Object value);

  /// No description provided for @purchaseFormAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get purchaseFormAddItem;

  /// No description provided for @purchaseFormLineTotal.
  ///
  /// In en, this message translates to:
  /// **'Line total {value}'**
  String purchaseFormLineTotal(Object value);

  /// No description provided for @purchaseFormCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog {value}'**
  String purchaseFormCatalog(Object value);

  /// No description provided for @purchaseFormBuyingPrice.
  ///
  /// In en, this message translates to:
  /// **'Buying price'**
  String get purchaseFormBuyingPrice;

  /// No description provided for @purchaseFormQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get purchaseFormQuantity;

  /// No description provided for @purchaseFormRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get purchaseFormRemoveItem;

  /// No description provided for @purchaseFormAddAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item.'**
  String get purchaseFormAddAtLeastOne;

  /// No description provided for @purchaseFormSupplierInvoiceNoOptional.
  ///
  /// In en, this message translates to:
  /// **'Supplier invoice no. (optional)'**
  String get purchaseFormSupplierInvoiceNoOptional;

  /// No description provided for @purchaseFormConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get purchaseFormConfirm;

  /// No description provided for @purchaseFormVendorItemSUnit.
  ///
  /// In en, this message translates to:
  /// **'Vendor: {name}\n{length, plural, =1{{length} item} other{{length} items}}, {units, plural, =1{{units} unit} other{{units} units}} will be added to stock.\n\nTotal: {value}\nPaid now: {value2}\nDue: {value3}'**
  String purchaseFormVendorItemSUnit(Object name, int length, int units,
      Object value, Object value2, Object value3);

  /// No description provided for @ordersNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get ordersNewOrder;

  /// No description provided for @ordersSalesOrders.
  ///
  /// In en, this message translates to:
  /// **'Sales & Orders'**
  String get ordersSalesOrders;

  /// No description provided for @ordersOfOrderSShown.
  ///
  /// In en, this message translates to:
  /// **'{length} of {length2, plural, =1{{length2} order} other{{length2} orders}} shown'**
  String ordersOfOrderSShown(Object length, int length2);

  /// No description provided for @ordersAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get ordersAllTypes;

  /// No description provided for @ordersSearchOrderNoOr.
  ///
  /// In en, this message translates to:
  /// **'Search order no. or customer…'**
  String get ordersSearchOrderNoOr;

  /// No description provided for @ordersOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get ordersOpenOrders;

  /// No description provided for @ordersToCollect.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get ordersToCollect;

  /// No description provided for @ordersTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total sales'**
  String get ordersTotalSales;

  /// No description provided for @orderDetailReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get orderDetailReceipt;

  /// No description provided for @orderDetailNoHistoryRecorded.
  ///
  /// In en, this message translates to:
  /// **'No history recorded.'**
  String get orderDetailNoHistoryRecorded;

  /// No description provided for @orderDetailStatusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status history'**
  String get orderDetailStatusHistory;

  /// No description provided for @orderDetailMessageOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get orderDetailMessageOnWhatsapp;

  /// No description provided for @orderDetailCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderDetailCancelOrder;

  /// No description provided for @orderDetailMarkAs.
  ///
  /// In en, this message translates to:
  /// **'Mark as {label}'**
  String orderDetailMarkAs(Object label);

  /// No description provided for @orderDetailCancelledTheStockWas.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. The stock was returned and the ledger charge reversed.'**
  String get orderDetailCancelledTheStockWas;

  /// No description provided for @orderDetailThisOrderNoLonger.
  ///
  /// In en, this message translates to:
  /// **'This order no longer exists.'**
  String get orderDetailThisOrderNoLonger;

  /// No description provided for @orderDetailOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderDetailOrder;

  /// No description provided for @orderDetailKeepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get orderDetailKeepOrder;

  /// No description provided for @orderDetailWillBeCancelledUnit.
  ///
  /// In en, this message translates to:
  /// **'{orderNo} will be cancelled. {totalUnits, plural, =1{{totalUnits} unit} other{{totalUnits} units}} go back into stock and the charge on {customerName}\'s ledger is reversed. Money already received stays on the ledger as customer credit.'**
  String orderDetailWillBeCancelledUnit(
      Object orderNo, int totalUnits, Object customerName);

  /// No description provided for @orderDetailCancelThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get orderDetailCancelThisOrder;

  /// No description provided for @orderDetailWhatsappCouldNotBe.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp could not be opened on this device.'**
  String get orderDetailWhatsappCouldNotBe;

  /// No description provided for @orderDetailThisCustomerHasNo.
  ///
  /// In en, this message translates to:
  /// **'This customer has no usable phone number. Add one to their record.'**
  String get orderDetailThisCustomerHasNo;

  /// No description provided for @orderFormConfirmingTakesTheQuantities.
  ///
  /// In en, this message translates to:
  /// **'Confirming takes the quantities out of stock and posts the order to the customer ledger. It is uploaded to the cloud as one atomic change when you sync.'**
  String get orderFormConfirmingTakesTheQuantities;

  /// No description provided for @orderFormConfirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get orderFormConfirmOrder;

  /// No description provided for @orderFormDiscountOnTheWhole.
  ///
  /// In en, this message translates to:
  /// **'Discount on the whole order'**
  String get orderFormDiscountOnTheWhole;

  /// No description provided for @orderFormSaleType.
  ///
  /// In en, this message translates to:
  /// **'Sale type'**
  String get orderFormSaleType;

  /// No description provided for @orderFormLineDiscount.
  ///
  /// In en, this message translates to:
  /// **'Line discount'**
  String get orderFormLineDiscount;

  /// No description provided for @orderFormSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get orderFormSellingPrice;

  /// No description provided for @orderFormCustomerSaleTypeItem.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}\nSale type: {label}\n{length, plural, =1{{length} item} other{{length} items}}, {units, plural, =1{{units} unit} other{{units} units}} will be taken out of stock.\n\nTotal: {value}\nPaid now: {value2}\nDue: {value3}'**
  String orderFormCustomerSaleTypeItem(Object name, Object label, int length,
      int units, Object value, Object value2, Object value3);

  /// No description provided for @orderFormAmt.
  ///
  /// In en, this message translates to:
  /// **'Amt'**
  String get orderFormAmt;

  /// No description provided for @settingsSendTestEMail.
  ///
  /// In en, this message translates to:
  /// **'Send test e-mail'**
  String get settingsSendTestEMail;

  /// No description provided for @settingsSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get settingsSaveSettings;

  /// No description provided for @settingsWhenOffTheWebsite.
  ///
  /// In en, this message translates to:
  /// **'When off, the website shows a closed notice and takes no orders.'**
  String get settingsWhenOffTheWebsite;

  /// No description provided for @settingsStoreIsOpen.
  ///
  /// In en, this message translates to:
  /// **'Store is open'**
  String get settingsStoreIsOpen;

  /// No description provided for @settingsOnlyAnAdminCan.
  ///
  /// In en, this message translates to:
  /// **'Only an admin can change these.'**
  String get settingsOnlyAnAdminCan;

  /// No description provided for @settingsOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'Online store'**
  String get settingsOnlineStore;

  /// No description provided for @settingsSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get settingsSend;

  /// No description provided for @settingsSendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get settingsSendTo;

  /// No description provided for @settingsTheStoreSettingsNeed.
  ///
  /// In en, this message translates to:
  /// **'{value}\nThe store settings need a connection to the server.'**
  String settingsTheStoreSettingsNeed(Object value);

  /// No description provided for @settingsCraftedWithLoveBy.
  ///
  /// In en, this message translates to:
  /// **'Crafted with love by A2 Devs.'**
  String get settingsCraftedWithLoveBy;

  /// No description provided for @settingsPosInventorySoftware.
  ///
  /// In en, this message translates to:
  /// **'POS & Inventory Software'**
  String get settingsPosInventorySoftware;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsAmountsAlreadyRecordedAre.
  ///
  /// In en, this message translates to:
  /// **'Amounts already recorded are not converted: they keep their numbers.'**
  String get settingsAmountsAlreadyRecordedAre;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsShopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get settingsShopName;

  /// No description provided for @settingsButtonsSelectionsAndCharts.
  ///
  /// In en, this message translates to:
  /// **'Buttons, selections and charts. A2 Stocks teal unless you pick your own.'**
  String get settingsButtonsSelectionsAndCharts;

  /// No description provided for @settingsBrandColour.
  ///
  /// In en, this message translates to:
  /// **'Brand colour'**
  String get settingsBrandColour;

  /// No description provided for @settingsLogo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get settingsLogo;

  /// No description provided for @settingsShopDetails.
  ///
  /// In en, this message translates to:
  /// **'Shop details'**
  String get settingsShopDetails;

  /// No description provided for @settingsTheShopDetailsNeed.
  ///
  /// In en, this message translates to:
  /// **'{value}\nThe shop details need a connection to the server.'**
  String settingsTheShopDetailsNeed(Object value);

  /// No description provided for @settingsYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your photo'**
  String get settingsYourPhoto;

  /// No description provided for @settingsSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSettings;

  /// No description provided for @settingsAShortTourOf.
  ///
  /// In en, this message translates to:
  /// **'A short tour of what you can do as {label}.'**
  String settingsAShortTourOf(Object label);

  /// No description provided for @settingsWelcomeGuide.
  ///
  /// In en, this message translates to:
  /// **'Welcome guide'**
  String get settingsWelcomeGuide;

  /// No description provided for @settingsSomethingWentWrongPlease.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get settingsSomethingWentWrongPlease;

  /// No description provided for @stockAuditNoStockAuditsYet.
  ///
  /// In en, this message translates to:
  /// **'No stock audits yet.'**
  String get stockAuditNoStockAuditsYet;

  /// No description provided for @stockAuditAuditHistory.
  ///
  /// In en, this message translates to:
  /// **'Audit history'**
  String get stockAuditAuditHistory;

  /// No description provided for @stockAuditOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get stockAuditOneMore;

  /// No description provided for @stockAuditOneLess.
  ///
  /// In en, this message translates to:
  /// **'One less'**
  String get stockAuditOneLess;

  /// No description provided for @stockAuditEachDifferenceBecomesA.
  ///
  /// In en, this message translates to:
  /// **'Each difference becomes a stock adjustment and is uploaded as one atomic change when you sync.'**
  String get stockAuditEachDifferenceBecomesA;

  /// No description provided for @stockAuditApplyCount.
  ///
  /// In en, this message translates to:
  /// **'Apply count'**
  String get stockAuditApplyCount;

  /// No description provided for @stockAuditCountedDifferenceS.
  ///
  /// In en, this message translates to:
  /// **'{length} counted · {differences, plural, =1{{differences} difference} other{{differences} differences}}'**
  String stockAuditCountedDifferenceS(Object length, int differences);

  /// No description provided for @stockAuditReasonNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason / note (optional)'**
  String get stockAuditReasonNoteOptional;

  /// No description provided for @stockAuditNoItemsToShow.
  ///
  /// In en, this message translates to:
  /// **'No items to show.'**
  String get stockAuditNoItemsToShow;

  /// No description provided for @stockAuditClearCounts.
  ///
  /// In en, this message translates to:
  /// **'Clear counts'**
  String get stockAuditClearCounts;

  /// No description provided for @stockAuditCountedOnly.
  ///
  /// In en, this message translates to:
  /// **'Counted only ({length})'**
  String stockAuditCountedOnly(Object length);

  /// No description provided for @stockAuditSearchProductSkuBarcode.
  ///
  /// In en, this message translates to:
  /// **'Search product, SKU, barcode…'**
  String get stockAuditSearchProductSkuBarcode;

  /// No description provided for @stockAuditStockAudit.
  ///
  /// In en, this message translates to:
  /// **'Stock audit'**
  String get stockAuditStockAudit;

  /// No description provided for @stockAuditOnlyAdminsAndManagers.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can count and adjust stock.'**
  String get stockAuditOnlyAdminsAndManagers;

  /// No description provided for @stockAuditStockCountApplied.
  ///
  /// In en, this message translates to:
  /// **'Stock count applied.'**
  String get stockAuditStockCountApplied;

  /// No description provided for @stockAuditItemSWillBe.
  ///
  /// In en, this message translates to:
  /// **'{length, plural, =1{{length} item} other{{length} items}} will be adjusted:'**
  String stockAuditItemSWillBe(int length);

  /// No description provided for @stockAuditEveryCountedQuantityMatches.
  ///
  /// In en, this message translates to:
  /// **'Every counted quantity matches the system, so nothing will be adjusted.'**
  String get stockAuditEveryCountedQuantityMatches;

  /// No description provided for @stockAuditApplyStockCount.
  ///
  /// In en, this message translates to:
  /// **'Apply stock count'**
  String get stockAuditApplyStockCount;

  /// No description provided for @stockItemSHaveNegative.
  ///
  /// In en, this message translates to:
  /// **'{negativeCount, plural, =1{{negativeCount} item} other{{negativeCount} items}} have negative stock. More was sold than was in stock, for example on two devices before they synced. Check the stock ledger and add a correction.'**
  String stockItemSHaveNegative(int negativeCount);

  /// No description provided for @stockItemSUnitS.
  ///
  /// In en, this message translates to:
  /// **'{length, plural, =1{{length} item} other{{length} items}} · {totalUnits, plural, =1{{totalUnits} unit} other{{totalUnits} units}} in stock'**
  String stockItemSUnitS(int length, int totalUnits);

  /// No description provided for @stockOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockOutOfStock;

  /// No description provided for @stockStockValueCost.
  ///
  /// In en, this message translates to:
  /// **'Stock value (cost)'**
  String get stockStockValueCost;

  /// No description provided for @stockAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get stockAudit;

  /// No description provided for @stockStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockStock;

  /// No description provided for @syncDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get syncDiscard;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncWaitingForTheServer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the server ({length})'**
  String syncWaitingForTheServer(Object length);

  /// No description provided for @syncNothingIsWaitingTo.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting to be uploaded.'**
  String get syncNothingIsWaitingTo;

  /// No description provided for @syncDownloadEverythingAgain.
  ///
  /// In en, this message translates to:
  /// **'Download everything again'**
  String get syncDownloadEverythingAgain;

  /// No description provided for @syncMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get syncMore;

  /// No description provided for @syncSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSync;

  /// No description provided for @syncDownloadAgain.
  ///
  /// In en, this message translates to:
  /// **'Download again'**
  String get syncDownloadAgain;

  /// No description provided for @syncThisReplacesThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This replaces this device\'s copy of the data with the server\'s. Changes that are waiting to be uploaded are kept.'**
  String get syncThisReplacesThisDevice;

  /// No description provided for @syncDownloadEverythingAgain2.
  ///
  /// In en, this message translates to:
  /// **'Download everything again?'**
  String get syncDownloadEverythingAgain2;

  /// No description provided for @usersAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get usersAddUser;

  /// No description provided for @usersUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersUsers;

  /// No description provided for @usersManagersStaff.
  ///
  /// In en, this message translates to:
  /// **'Managers & staff'**
  String get usersManagersStaff;

  /// No description provided for @usersAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get usersAdmins;

  /// No description provided for @usersNoUsersYet.
  ///
  /// In en, this message translates to:
  /// **'No users yet.'**
  String get usersNoUsersYet;

  /// No description provided for @usersDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get usersDeleteUser;

  /// No description provided for @userFormRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get userFormRole;

  /// No description provided for @userFormPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get userFormPhoneOptional;

  /// No description provided for @userFormShareItWithThe.
  ///
  /// In en, this message translates to:
  /// **'Share it with the user so they can sign in.'**
  String get userFormShareItWithThe;

  /// No description provided for @userFormInitialPassword.
  ///
  /// In en, this message translates to:
  /// **'Initial password'**
  String get userFormInitialPassword;

  /// No description provided for @userFormEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'Email (login)'**
  String get userFormEmailLogin;

  /// No description provided for @userFormFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get userFormFullName;

  /// No description provided for @userFormProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get userFormProfilePhoto;

  /// No description provided for @businessBrandCraftedWithLoveBy.
  ///
  /// In en, this message translates to:
  /// **'Crafted with love by'**
  String get businessBrandCraftedWithLoveBy;

  /// No description provided for @businessBrandPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get businessBrandPoweredBy;

  /// No description provided for @logoutButtonSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed.'**
  String get logoutButtonSignOutFailed;

  /// No description provided for @orderReceiptCardDue.
  ///
  /// In en, this message translates to:
  /// **'Due {value}'**
  String orderReceiptCardDue(Object value);

  /// No description provided for @orderReceiptCardTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderReceiptCardTotal;

  /// No description provided for @orderReceiptCardNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get orderReceiptCardNoItems;

  /// No description provided for @partyListNoMatchesTryChanging.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try changing the search or filters.'**
  String get partyListNoMatchesTryChanging;

  /// No description provided for @partyListShowInactive.
  ///
  /// In en, this message translates to:
  /// **'Show inactive'**
  String get partyListShowInactive;

  /// No description provided for @partyListOverCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Over credit limit'**
  String get partyListOverCreditLimit;

  /// No description provided for @partyListWithBalance.
  ///
  /// In en, this message translates to:
  /// **'With balance'**
  String get partyListWithBalance;

  /// No description provided for @partyListSearchNamePhoneCity.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone, city…'**
  String get partyListSearchNamePhoneCity;

  /// No description provided for @partyListSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get partyListSettled;

  /// No description provided for @partyListWithABalance.
  ///
  /// In en, this message translates to:
  /// **'With a balance'**
  String get partyListWithABalance;

  /// No description provided for @partyPickerSelectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select customer'**
  String get partyPickerSelectCustomer;

  /// No description provided for @partyPickerSelectVendor.
  ///
  /// In en, this message translates to:
  /// **'Select vendor'**
  String get partyPickerSelectVendor;

  /// No description provided for @photoWidgetsDeletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get photoWidgetsDeletePhoto;

  /// No description provided for @photoWidgetsMakeMainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Make main photo'**
  String get photoWidgetsMakeMainPhoto;

  /// No description provided for @photoWidgetsMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get photoWidgetsMain;

  /// No description provided for @photoWidgetsNoPhotosYetThe.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. The first photo is the main one shown in the shop and on the online store.'**
  String get photoWidgetsNoPhotosYetThe;

  /// No description provided for @photoWidgetsAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get photoWidgetsAddPhoto;

  /// No description provided for @photoWidgetsOf10.
  ///
  /// In en, this message translates to:
  /// **'({length} of 10)'**
  String photoWidgetsOf10(Object length);

  /// No description provided for @photoWidgetsSaveFirstThenOpen.
  ///
  /// In en, this message translates to:
  /// **'Save first, then open this again to add {what}.'**
  String photoWidgetsSaveFirstThenOpen(Object what);

  /// No description provided for @photoWidgetsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get photoWidgetsRemove;

  /// No description provided for @photoWidgetsThePhotoCouldNot.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be saved. Please try again.'**
  String get photoWidgetsThePhotoCouldNot;

  /// No description provided for @receiptActionsWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get receiptActionsWhatsapp;

  /// No description provided for @receiptActionsSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get receiptActionsSharePdf;

  /// No description provided for @receiptActionsViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get receiptActionsViewReceipt;

  /// No description provided for @receiptActionsPrintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get receiptActionsPrintReceipt;

  /// No description provided for @receiptActionsOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp'**
  String get receiptActionsOpenWhatsapp;

  /// No description provided for @receiptActionsCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get receiptActionsCustomerPhone;

  /// No description provided for @receiptActionsWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get receiptActionsWhatsappNumber;

  /// No description provided for @receiptActionsThatIsNotA.
  ///
  /// In en, this message translates to:
  /// **'That is not a usable phone number.'**
  String get receiptActionsThatIsNotA;

  /// No description provided for @receiptActionsThatDidNotWork.
  ///
  /// In en, this message translates to:
  /// **'That did not work on this device. Please try again.'**
  String get receiptActionsThatDidNotWork;

  /// No description provided for @receiptThankYouForShopping.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping with us. Please come again.'**
  String get receiptThankYouForShopping;

  /// No description provided for @receiptDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount -{value}'**
  String receiptDiscount(Object value);

  /// No description provided for @receiptQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get receiptQty;

  /// No description provided for @receiptPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get receiptPrice;

  /// No description provided for @receiptItem.
  ///
  /// In en, this message translates to:
  /// **'# Item'**
  String get receiptItem;

  /// No description provided for @receiptSalesReceipt.
  ///
  /// In en, this message translates to:
  /// **'Sales Receipt'**
  String get receiptSalesReceipt;

  /// No description provided for @receiptPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number : {shopPhone}'**
  String receiptPhoneNumber(Object shopPhone);

  /// No description provided for @variantPickerStock.
  ///
  /// In en, this message translates to:
  /// **'Stock {onHand}'**
  String variantPickerStock(Object onHand);

  /// No description provided for @variantPickerNoMatchingItems.
  ///
  /// In en, this message translates to:
  /// **'No matching items.'**
  String get variantPickerNoMatchingItems;

  /// No description provided for @variantPickerSelectItem.
  ///
  /// In en, this message translates to:
  /// **'Select item'**
  String get variantPickerSelectItem;

  /// Pattern (ICU date skeleton letters, see intl DateFormat) for a full date with the weekday, e.g. "Monday, 18 November 2026". Translators may reorder the parts.
  ///
  /// In en, this message translates to:
  /// **'EEEE, d MMMM y'**
  String get dateLong;

  /// Pattern for a date with an abbreviated weekday, e.g. "Mon, 18 November 2026".
  ///
  /// In en, this message translates to:
  /// **'EEE, d MMMM y'**
  String get dateShort;

  /// No description provided for @categoriesNoSubcategoriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No subcategories match.'**
  String get categoriesNoSubcategoriesMatch;

  /// No description provided for @categoriesNoSubcategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No subcategories yet.'**
  String get categoriesNoSubcategoriesYet;

  /// No description provided for @categoriesCategoriesWithNothingIn.
  ///
  /// In en, this message translates to:
  /// **'categories with nothing in them'**
  String get categoriesCategoriesWithNothingIn;

  /// No description provided for @categoriesYouAlreadyHadWere.
  ///
  /// In en, this message translates to:
  /// **' ({skipped} you already had were left as they are)'**
  String categoriesYouAlreadyHadWere(Object skipped);

  /// No description provided for @categoryFormCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get categoryFormCreateCategory;

  /// No description provided for @categoryFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get categoryFormSaveChanges;

  /// No description provided for @categoryFormNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get categoryFormNameIsRequired;

  /// No description provided for @categoryFormEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryFormEditCategory;

  /// No description provided for @productsNoProductsMatchYour.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get productsNoProductsMatchYour;

  /// No description provided for @productsNoProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet.'**
  String get productsNoProductsYet;

  /// No description provided for @productsInactive2.
  ///
  /// In en, this message translates to:
  /// **'{value} inactive'**
  String productsInactive2(Object value);

  /// No description provided for @productFormCreateProduct.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get productFormCreateProduct;

  /// No description provided for @productFormChooseACategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get productFormChooseACategory;

  /// No description provided for @productFormCreateACategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a category first.'**
  String get productFormCreateACategoryFirst;

  /// No description provided for @productFormEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productFormEditProduct;

  /// No description provided for @productFormProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productFormProduct;

  /// No description provided for @productFormCostSale.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost} · Sale {sale}'**
  String productFormCostSale(Object cost, Object sale);

  /// No description provided for @productFormCostWholesaleRetail.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost} · Wholesale {value} · Retail {sale}'**
  String productFormCostWholesaleRetail(Object cost, Object value, Object sale);

  /// No description provided for @starterPackAddCategories.
  ///
  /// In en, this message translates to:
  /// **'Add {toAdd} categories'**
  String starterPackAddCategories(Object toAdd);

  /// No description provided for @starterPackNothingNewToAdd.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to add'**
  String get starterPackNothingNewToAdd;

  /// No description provided for @starterPackYouAlreadyHaveEverything.
  ///
  /// In en, this message translates to:
  /// **'You already have everything you ticked.'**
  String get starterPackYouAlreadyHaveEverything;

  /// No description provided for @starterPackTickAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Tick at least one group.'**
  String get starterPackTickAtLeastOne;

  /// No description provided for @starterPackSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get starterPackSelectAll;

  /// No description provided for @starterPackSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get starterPackSelectNone;

  /// No description provided for @starterPackOtherKindsOfStore.
  ///
  /// In en, this message translates to:
  /// **'Other kinds of store'**
  String get starterPackOtherKindsOfStore;

  /// No description provided for @starterPackStoresLikeYours.
  ///
  /// In en, this message translates to:
  /// **'Stores like yours'**
  String get starterPackStoresLikeYours;

  /// No description provided for @starterPackStarterCategories.
  ///
  /// In en, this message translates to:
  /// **'Starter categories'**
  String get starterPackStarterCategories;

  /// No description provided for @variantEnter0OrA.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or a whole number.'**
  String get variantEnter0OrA;

  /// No description provided for @variantSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get variantSalePrice;

  /// No description provided for @variantRetailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail price'**
  String get variantRetailPrice;

  /// No description provided for @variantSkuIsRequired.
  ///
  /// In en, this message translates to:
  /// **'SKU is required.'**
  String get variantSkuIsRequired;

  /// No description provided for @variantVariant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variantVariant;

  /// No description provided for @variantEnterTheProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter the product name or an attribute value first.'**
  String get variantEnterTheProductName;

  /// No description provided for @variantEnterAValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price.'**
  String get variantEnterAValidPrice;

  /// No description provided for @dashboardNoCategorySalesYet.
  ///
  /// In en, this message translates to:
  /// **'No category sales yet.'**
  String get dashboardNoCategorySalesYet;

  /// No description provided for @dashboardNoNamedCustomersHave.
  ///
  /// In en, this message translates to:
  /// **'No named customers have bought yet.'**
  String get dashboardNoNamedCustomersHave;

  /// No description provided for @dashboardWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get dashboardWalkInCustomer;

  /// No description provided for @dashboardNoSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet.'**
  String get dashboardNoSalesYet;

  /// No description provided for @dashboardLeft.
  ///
  /// In en, this message translates to:
  /// **'{value} left'**
  String dashboardLeft(Object value);

  /// No description provided for @dashboardNothingIsRunningLow.
  ///
  /// In en, this message translates to:
  /// **'Nothing is running low.'**
  String get dashboardNothingIsRunningLow;

  /// No description provided for @dashboardSold.
  ///
  /// In en, this message translates to:
  /// **'{value} sold'**
  String dashboardSold(Object value);

  /// No description provided for @dashboardNoSalesInThis.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period yet.'**
  String get dashboardNoSalesInThis;

  /// No description provided for @dashboardOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get dashboardOrders;

  /// No description provided for @dashboardNoNamedCustomersBought.
  ///
  /// In en, this message translates to:
  /// **'No named customers bought in this period.'**
  String get dashboardNoNamedCustomersBought;

  /// No description provided for @dashboardWalkInOrders.
  ///
  /// In en, this message translates to:
  /// **'Walk-in orders'**
  String get dashboardWalkInOrders;

  /// No description provided for @dashboardOfBuyers.
  ///
  /// In en, this message translates to:
  /// **'{returningPercent}% of buyers'**
  String dashboardOfBuyers(Object returningPercent);

  /// No description provided for @dashboardReturningCustomers.
  ///
  /// In en, this message translates to:
  /// **'Returning customers'**
  String get dashboardReturningCustomers;

  /// No description provided for @dashboardFirstOrderInThis.
  ///
  /// In en, this message translates to:
  /// **'first order in this period'**
  String get dashboardFirstOrderInThis;

  /// No description provided for @dashboardNewCustomers.
  ///
  /// In en, this message translates to:
  /// **'New customers'**
  String get dashboardNewCustomers;

  /// No description provided for @dashboardAndMore.
  ///
  /// In en, this message translates to:
  /// **' and {value} more'**
  String dashboardAndMore(Object value);

  /// No description provided for @dashboardAtOrBelowAlert.
  ///
  /// In en, this message translates to:
  /// **'at or below alert level'**
  String get dashboardAtOrBelowAlert;

  /// No description provided for @dashboardAllAboveAlertLevel.
  ///
  /// In en, this message translates to:
  /// **'All above alert level'**
  String get dashboardAllAboveAlertLevel;

  /// No description provided for @dashboardProcessingShipped.
  ///
  /// In en, this message translates to:
  /// **'{processingOrders} processing · {shippedOrders} shipped'**
  String dashboardProcessingShipped(
      Object processingOrders, Object shippedOrders);

  /// No description provided for @dashboardOrderS2.
  ///
  /// In en, this message translates to:
  /// **'{ordersMonth, plural, =1{{ordersMonth} order} other{{ordersMonth} orders}}'**
  String dashboardOrderS2(int ordersMonth);

  /// No description provided for @dashboardOrderS3.
  ///
  /// In en, this message translates to:
  /// **'{ordersToday, plural, =1{{ordersToday} order} other{{ordersToday} orders}}'**
  String dashboardOrderS3(int ordersToday);

  /// No description provided for @homeCollapseMenu.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get homeCollapseMenu;

  /// No description provided for @homeExpandMenu.
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get homeExpandMenu;

  /// No description provided for @homeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeHome;

  /// No description provided for @activityLogsChangeS.
  ///
  /// In en, this message translates to:
  /// **'{length, plural, =1{{length} change} other{{length} changes}}'**
  String activityLogsChangeS(int length);

  /// No description provided for @activityLogsLoadFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Load from cloud'**
  String get activityLogsLoadFromCloud;

  /// No description provided for @activityLogsRefreshCloud.
  ///
  /// In en, this message translates to:
  /// **'Refresh cloud'**
  String get activityLogsRefreshCloud;

  /// No description provided for @activityLogsNoLogsMatchThe.
  ///
  /// In en, this message translates to:
  /// **'No logs match the filters.'**
  String get activityLogsNoLogsMatchThe;

  /// No description provided for @activityLogsNoLogsOnThis.
  ///
  /// In en, this message translates to:
  /// **'No logs on this device yet.'**
  String get activityLogsNoLogsOnThis;

  /// No description provided for @activityLogsModuleRecord.
  ///
  /// In en, this message translates to:
  /// **'Module: {module}  Record: {entityLabel} ({entityId})'**
  String activityLogsModuleRecord(
      Object module, Object entityLabel, Object entityId);

  /// No description provided for @activityLogsUser2.
  ///
  /// In en, this message translates to:
  /// **'User: {userName} {userRole}'**
  String activityLogsUser2(Object userName, Object userRole);

  /// No description provided for @activityLogsRemoved.
  ///
  /// In en, this message translates to:
  /// **'(removed)'**
  String get activityLogsRemoved;

  /// No description provided for @activityLogsNone.
  ///
  /// In en, this message translates to:
  /// **'(none)'**
  String get activityLogsNone;

  /// No description provided for @activityLogsLogId.
  ///
  /// In en, this message translates to:
  /// **'Log id'**
  String get activityLogsLogId;

  /// No description provided for @activityLogsGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get activityLogsGroup;

  /// No description provided for @activityLogsRecordId.
  ///
  /// In en, this message translates to:
  /// **'Record id'**
  String get activityLogsRecordId;

  /// No description provided for @activityLogsRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get activityLogsRecord;

  /// No description provided for @activityLogsLevelType.
  ///
  /// In en, this message translates to:
  /// **'Level / type'**
  String get activityLogsLevelType;

  /// No description provided for @activityLogsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get activityLogsTime;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @ledgerEntryEnterAnAmountGreater.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get ledgerEntryEnterAnAmountGreater;

  /// No description provided for @partyDetailRef.
  ///
  /// In en, this message translates to:
  /// **'Ref {reference}'**
  String partyDetailRef(Object reference);

  /// No description provided for @partyDetailCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit {value}'**
  String partyDetailCreditLimit(Object value);

  /// No description provided for @partyDetailOverTheCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Over the credit limit of {value}'**
  String partyDetailOverTheCreditLimit(Object value);

  /// No description provided for @partyDetailDeleteThisOf.
  ///
  /// In en, this message translates to:
  /// **'Delete this {value} of {value2}?'**
  String partyDetailDeleteThisOf(Object value, Object value2);

  /// No description provided for @partyDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String partyDetailDelete(Object name);

  /// No description provided for @partyDetailDelete2.
  ///
  /// In en, this message translates to:
  /// **'Delete {value}'**
  String partyDetailDelete2(Object value);

  /// No description provided for @partyFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create {noun}'**
  String partyFormCreate(Object noun);

  /// No description provided for @partyFormEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get partyFormEnterAValidAmount;

  /// No description provided for @partyFormPositiveYouOweThe.
  ///
  /// In en, this message translates to:
  /// **'Positive: you owe the vendor. Negative: advance paid.'**
  String get partyFormPositiveYouOweThe;

  /// No description provided for @partyFormPositiveTheCustomerOwes.
  ///
  /// In en, this message translates to:
  /// **'Positive: the customer owes you. Negative: advance received.'**
  String get partyFormPositiveTheCustomerOwes;

  /// No description provided for @partyFormEnterAValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get partyFormEnterAValidPhone;

  /// No description provided for @partyFormNameBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Name / business name'**
  String get partyFormNameBusinessName;

  /// No description provided for @partyFormNameShopName.
  ///
  /// In en, this message translates to:
  /// **'Name / shop name'**
  String get partyFormNameShopName;

  /// No description provided for @partyFormVendorPhotoLogo.
  ///
  /// In en, this message translates to:
  /// **'Vendor photo / logo'**
  String get partyFormVendorPhotoLogo;

  /// No description provided for @partyFormCustomerPhotoShopFront.
  ///
  /// In en, this message translates to:
  /// **'Customer photo / shop front'**
  String get partyFormCustomerPhotoShopFront;

  /// No description provided for @partyFormAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {noun}'**
  String partyFormAdd(Object noun);

  /// No description provided for @partyFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {noun}'**
  String partyFormEdit(Object noun);

  /// No description provided for @heldSalesAndMore.
  ///
  /// In en, this message translates to:
  /// **'{names} and {more} more'**
  String heldSalesAndMore(Object names, Object more);

  /// No description provided for @heldSalesDAgo.
  ///
  /// In en, this message translates to:
  /// **'{inDays} d ago'**
  String heldSalesDAgo(Object inDays);

  /// No description provided for @heldSalesHAgo.
  ///
  /// In en, this message translates to:
  /// **'{inHours} h ago'**
  String heldSalesHAgo(Object inHours);

  /// No description provided for @heldSalesMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{inMinutes} min ago'**
  String heldSalesMinAgo(Object inMinutes);

  /// No description provided for @heldSalesJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get heldSalesJustNow;

  /// No description provided for @posPaymentSellWithDue.
  ///
  /// In en, this message translates to:
  /// **'Sell with {prefix}{value} due'**
  String posPaymentSellWithDue(Object prefix, Object value);

  /// No description provided for @posPaymentSellOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Sell on credit'**
  String get posPaymentSellOnCredit;

  /// No description provided for @posPaymentTransactionNo.
  ///
  /// In en, this message translates to:
  /// **'Transaction no.'**
  String get posPaymentTransactionNo;

  /// No description provided for @posPaymentBankAndTransactionNo.
  ///
  /// In en, this message translates to:
  /// **'Bank and transaction no.'**
  String get posPaymentBankAndTransactionNo;

  /// No description provided for @posPaymentCashReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash received'**
  String get posPaymentCashReceived;

  /// No description provided for @posPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order · {prefix}{value}'**
  String posPlaceOrder(Object prefix, Object value);

  /// No description provided for @posPlaceOrder2.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get posPlaceOrder2;

  /// No description provided for @posBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get posBank;

  /// No description provided for @posDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get posDiscount;

  /// No description provided for @posSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get posSubTotal;

  /// No description provided for @posOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get posOrderDetails;

  /// No description provided for @posMayPayNowOr.
  ///
  /// In en, this message translates to:
  /// **'May pay now or later'**
  String get posMayPayNowOr;

  /// No description provided for @posPaysInFullNow.
  ///
  /// In en, this message translates to:
  /// **'Pays in full now'**
  String get posPaysInFullNow;

  /// No description provided for @posCustomerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get posCustomerInformation;

  /// No description provided for @posHeld.
  ///
  /// In en, this message translates to:
  /// **'Held'**
  String get posHeld;

  /// No description provided for @posHeld2.
  ///
  /// In en, this message translates to:
  /// **'Held ({heldCount})'**
  String posHeld2(Object heldCount);

  /// No description provided for @posDiscountOn.
  ///
  /// In en, this message translates to:
  /// **'Discount on {productName}'**
  String posDiscountOn(Object productName);

  /// No description provided for @posDiscountOnTheWhole.
  ///
  /// In en, this message translates to:
  /// **'Discount on the whole sale'**
  String get posDiscountOnTheWhole;

  /// No description provided for @posLeft.
  ///
  /// In en, this message translates to:
  /// **'{onHand} left'**
  String posLeft(Object onHand);

  /// No description provided for @posPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get posPayment;

  /// No description provided for @posVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get posVoid;

  /// No description provided for @posViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get posViewOrders;

  /// No description provided for @posSale.
  ///
  /// In en, this message translates to:
  /// **'Sale · {prefix}{value}'**
  String posSale(Object prefix, Object value);

  /// No description provided for @posSale2.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get posSale2;

  /// No description provided for @posHeldSaleResumedThe.
  ///
  /// In en, this message translates to:
  /// **'Held sale resumed. The previous sale is now on hold.'**
  String get posHeldSaleResumedThe;

  /// No description provided for @posHeldSaleResumed.
  ///
  /// In en, this message translates to:
  /// **'Held sale resumed.'**
  String get posHeldSaleResumed;

  /// No description provided for @posSalePutOnHold.
  ///
  /// In en, this message translates to:
  /// **'Sale put on hold. Find it under \"Held\".'**
  String get posSalePutOnHold;

  /// No description provided for @posTheSaleCouldNot.
  ///
  /// In en, this message translates to:
  /// **'The sale could not be completed.'**
  String get posTheSaleCouldNot;

  /// No description provided for @posTheWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'The walk-in customer is not on this device yet. Sync once, then try again.'**
  String get posTheWalkInCustomer;

  /// No description provided for @posNoProductWithBarcode.
  ///
  /// In en, this message translates to:
  /// **'No product with barcode or SKU \"{value}\".'**
  String posNoProductWithBarcode(Object value);

  /// No description provided for @posHasNoActiveVariant.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has no active variant.'**
  String posHasNoActiveVariant(Object name);

  /// No description provided for @posOnlyOfInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {onHand} of \"{name} · {label}\" in stock.'**
  String posOnlyOfInStock(Object onHand, Object name, Object label);

  /// No description provided for @posIsOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'\"{name} · {label}\" is out of stock.'**
  String posIsOutOfStock(Object name, Object label);

  /// No description provided for @purchasesInv.
  ///
  /// In en, this message translates to:
  /// **'Inv {invoiceNo}'**
  String purchasesInv(Object invoiceNo);

  /// No description provided for @purchasesItemS.
  ///
  /// In en, this message translates to:
  /// **'{length, plural, =1{{length} item} other{{length} items}}'**
  String purchasesItemS(int length);

  /// No description provided for @purchasesNoPurchasesMatchYour.
  ///
  /// In en, this message translates to:
  /// **'No purchases match your search.'**
  String get purchasesNoPurchasesMatchYour;

  /// No description provided for @purchasesNoPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet.'**
  String get purchasesNoPurchasesYet;

  /// No description provided for @purchaseDetailMoreThanTheAmount.
  ///
  /// In en, this message translates to:
  /// **'More than the amount due.'**
  String get purchaseDetailMoreThanTheAmount;

  /// No description provided for @purchaseDetailDue2.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get purchaseDetailDue2;

  /// No description provided for @purchaseDetailPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get purchaseDetailPaid;

  /// No description provided for @purchaseDetailInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice {invoiceNo}'**
  String purchaseDetailInvoice(Object invoiceNo);

  /// No description provided for @purchaseFormMoreThanThePurchase.
  ///
  /// In en, this message translates to:
  /// **'More than the purchase total.'**
  String get purchaseFormMoreThanThePurchase;

  /// No description provided for @purchaseFormInvalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get purchaseFormInvalidPrice;

  /// No description provided for @purchaseFormAtLeast1.
  ///
  /// In en, this message translates to:
  /// **'At least 1'**
  String get purchaseFormAtLeast1;

  /// No description provided for @purchaseFormItemsAndQuantities.
  ///
  /// In en, this message translates to:
  /// **'Items and quantities'**
  String get purchaseFormItemsAndQuantities;

  /// No description provided for @purchaseFormChooseAVendor.
  ///
  /// In en, this message translates to:
  /// **'Choose a vendor.'**
  String get purchaseFormChooseAVendor;

  /// No description provided for @purchaseFormVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get purchaseFormVendor;

  /// No description provided for @ordersNoOrdersMatchYour.
  ///
  /// In en, this message translates to:
  /// **'No orders match your search.'**
  String get ordersNoOrdersMatchYour;

  /// No description provided for @ordersNoOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get ordersNoOrdersYet;

  /// No description provided for @ordersNotYetDelivered.
  ///
  /// In en, this message translates to:
  /// **'not yet delivered'**
  String get ordersNotYetDelivered;

  /// No description provided for @ordersOrderS.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} order} other{{count} orders}}'**
  String ordersOrderS(int count);

  /// No description provided for @ordersOrderS2.
  ///
  /// In en, this message translates to:
  /// **'{todayCount, plural, =1{{todayCount} order} other{{todayCount} orders}}'**
  String ordersOrderS2(int todayCount);

  /// No description provided for @orderDetailEnterTheTransactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the transaction number.'**
  String get orderDetailEnterTheTransactionNumber;

  /// No description provided for @orderDetailDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount {value}'**
  String orderDetailDiscount(Object value);

  /// No description provided for @orderDetailSku.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku}'**
  String orderDetailSku(Object sku);

  /// No description provided for @orderDetailBy.
  ///
  /// In en, this message translates to:
  /// **'by {byName}'**
  String orderDetailBy(Object byName);

  /// No description provided for @orderDetailDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDetailDelivery;

  /// No description provided for @orderDetailDiscountsLinesAndOrder.
  ///
  /// In en, this message translates to:
  /// **'Discounts (lines and order)'**
  String get orderDetailDiscountsLinesAndOrder;

  /// No description provided for @orderDetailSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get orderDetailSubtotal;

  /// No description provided for @orderFormMoreThanTheOrder.
  ///
  /// In en, this message translates to:
  /// **'More than the order total.'**
  String get orderFormMoreThanTheOrder;

  /// No description provided for @orderFormOrderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Order discount'**
  String get orderFormOrderDiscount;

  /// No description provided for @orderFormItemsQuantitiesAndPrices.
  ///
  /// In en, this message translates to:
  /// **'Items, quantities and prices'**
  String get orderFormItemsQuantitiesAndPrices;

  /// No description provided for @orderFormChooseACustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose a customer.'**
  String get orderFormChooseACustomer;

  /// No description provided for @orderFormSellingBelowTheCost.
  ///
  /// In en, this message translates to:
  /// **'Selling below the cost price ({value}).'**
  String orderFormSellingBelowTheCost(Object value);

  /// No description provided for @orderFormSkuInStock.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · In stock: {onHand}'**
  String orderFormSkuInStock(Object sku, Object onHand);

  /// No description provided for @orderFormSkuOnlyInStock.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Only {onHand} in stock, {requested} requested'**
  String orderFormSkuOnlyInStock(Object sku, Object onHand, Object requested);

  /// No description provided for @orderFormMoreThanTheAmount.
  ///
  /// In en, this message translates to:
  /// **'More than the amount'**
  String get orderFormMoreThanTheAmount;

  /// No description provided for @orderFormMax100.
  ///
  /// In en, this message translates to:
  /// **'Max 100%'**
  String get orderFormMax100;

  /// No description provided for @orderFormInvalidDiscount.
  ///
  /// In en, this message translates to:
  /// **'Invalid discount'**
  String get orderFormInvalidDiscount;

  /// No description provided for @settingsEnterAWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, 0 or more.'**
  String get settingsEnterAWholeNumber;

  /// No description provided for @settingsCustomersNeverSeeExact.
  ///
  /// In en, this message translates to:
  /// **'Customers never see exact numbers.'**
  String get settingsCustomersNeverSeeExact;

  /// No description provided for @settingsShowLowStockAt.
  ///
  /// In en, this message translates to:
  /// **'Show \"Low stock\" at or below'**
  String get settingsShowLowStockAt;

  /// No description provided for @settingsStockDisplay.
  ///
  /// In en, this message translates to:
  /// **'Stock display'**
  String get settingsStockDisplay;

  /// No description provided for @settings0NeverFree.
  ///
  /// In en, this message translates to:
  /// **'0 = never free'**
  String get settings0NeverFree;

  /// No description provided for @settingsFreeDeliveryFrom.
  ///
  /// In en, this message translates to:
  /// **'Free delivery from'**
  String get settingsFreeDeliveryFrom;

  /// No description provided for @settingsDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get settingsDeliveryFee;

  /// No description provided for @settingsForExampleDeliveryTimes.
  ///
  /// In en, this message translates to:
  /// **'For example delivery times.'**
  String get settingsForExampleDeliveryTimes;

  /// No description provided for @settingsNoteAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Note at checkout'**
  String get settingsNoteAtCheckout;

  /// No description provided for @settingsCheckoutDelivery.
  ///
  /// In en, this message translates to:
  /// **'Checkout & delivery'**
  String get settingsCheckoutDelivery;

  /// No description provided for @settingsLeaveEmptyForNo.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no alerts.'**
  String get settingsLeaveEmptyForNo;

  /// No description provided for @settingsSendNewOrderAlerts.
  ///
  /// In en, this message translates to:
  /// **'Send new-order alerts to (e-mail)'**
  String get settingsSendNewOrderAlerts;

  /// No description provided for @settingsShownInTheWebsite.
  ///
  /// In en, this message translates to:
  /// **'Shown in the website footer.'**
  String get settingsShownInTheWebsite;

  /// No description provided for @settingsContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get settingsContactPhone;

  /// No description provided for @settingsEnterTheStoreName.
  ///
  /// In en, this message translates to:
  /// **'Enter the store name.'**
  String get settingsEnterTheStoreName;

  /// No description provided for @settingsStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get settingsStoreName;

  /// No description provided for @settingsContactAlerts.
  ///
  /// In en, this message translates to:
  /// **'Contact & alerts'**
  String get settingsContactAlerts;

  /// No description provided for @settingsEMailIsNot.
  ///
  /// In en, this message translates to:
  /// **'E-mail is not set up on the server yet (SMTP_HOST is empty). See docs/deploy.md.'**
  String get settingsEMailIsNot;

  /// No description provided for @settingsTheMailServerRefused.
  ///
  /// In en, this message translates to:
  /// **'The mail server refused or could not be reached. Check the SMTP settings on the server.'**
  String get settingsTheMailServerRefused;

  /// No description provided for @settingsTestEMailSent.
  ///
  /// In en, this message translates to:
  /// **'Test e-mail sent to {address}. Check the inbox (and the spam folder).'**
  String settingsTestEMailSent(Object address);

  /// No description provided for @settingsEnterAValidE.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid e-mail address.'**
  String get settingsEnterAValidE;

  /// No description provided for @settingsSavedTheStoreIs.
  ///
  /// In en, this message translates to:
  /// **'Saved. The store is closed: it takes no orders.'**
  String get settingsSavedTheStoreIs;

  /// No description provided for @settingsSavedTheStoreIs2.
  ///
  /// In en, this message translates to:
  /// **'Saved. The store is open.'**
  String get settingsSavedTheStoreIs2;

  /// No description provided for @settingsEnterAnAmountOf.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount of 0 or more.'**
  String get settingsEnterAnAmountOf;

  /// No description provided for @settingsSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get settingsSlate;

  /// No description provided for @settingsDarkTeal.
  ///
  /// In en, this message translates to:
  /// **'Dark teal'**
  String get settingsDarkTeal;

  /// No description provided for @settingsGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get settingsGreen;

  /// No description provided for @settingsGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get settingsGold;

  /// No description provided for @settingsOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get settingsOrange;

  /// No description provided for @settingsRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get settingsRed;

  /// No description provided for @settingsPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get settingsPink;

  /// No description provided for @settingsMagenta.
  ///
  /// In en, this message translates to:
  /// **'Magenta'**
  String get settingsMagenta;

  /// No description provided for @settingsViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get settingsViolet;

  /// No description provided for @settingsBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get settingsBlue;

  /// No description provided for @settingsA2StocksTeal.
  ///
  /// In en, this message translates to:
  /// **'A2 Stocks teal'**
  String get settingsA2StocksTeal;

  /// No description provided for @settingsEnterTheShopName.
  ///
  /// In en, this message translates to:
  /// **'Enter the shop name.'**
  String get settingsEnterTheShopName;

  /// No description provided for @settingsPrintedAtTheTop.
  ///
  /// In en, this message translates to:
  /// **'Printed at the top of your receipts and in messages to customers.'**
  String get settingsPrintedAtTheTop;

  /// No description provided for @settingsTheCurrencyEveryAmount.
  ///
  /// In en, this message translates to:
  /// **'The currency every amount in the app is written in.'**
  String get settingsTheCurrencyEveryAmount;

  /// No description provided for @settingsTheWelcomeTour.
  ///
  /// In en, this message translates to:
  /// **'The welcome tour'**
  String get settingsTheWelcomeTour;

  /// No description provided for @settingsHelpGuide.
  ///
  /// In en, this message translates to:
  /// **'Help & guide'**
  String get settingsHelpGuide;

  /// No description provided for @settingsCurrencyAndReceiptDetails.
  ///
  /// In en, this message translates to:
  /// **'Currency and receipt details'**
  String get settingsCurrencyAndReceiptDetails;

  /// No description provided for @settingsOpeningDeliveryAndAlerts.
  ///
  /// In en, this message translates to:
  /// **'Opening, delivery and alerts'**
  String get settingsOpeningDeliveryAndAlerts;

  /// No description provided for @settingsYourNameEMail.
  ///
  /// In en, this message translates to:
  /// **'Your name, e-mail and photo'**
  String get settingsYourNameEMail;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @stockAuditBy.
  ///
  /// In en, this message translates to:
  /// **'by {countedByName}'**
  String stockAuditBy(Object countedByName);

  /// No description provided for @stockLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock ({lowCount})'**
  String stockLowStock(Object lowCount);

  /// No description provided for @stockInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get stockInStock;

  /// No description provided for @stockItemS.
  ///
  /// In en, this message translates to:
  /// **'{items, plural, =1{{items} item} other{{items} items}}'**
  String stockItemS(int items);

  /// No description provided for @syncSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncSyncNow;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// No description provided for @syncLastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked {value}.'**
  String syncLastChecked(Object value);

  /// No description provided for @syncNothingIsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting.'**
  String get syncNothingIsWaiting;

  /// No description provided for @syncInStepWithThe.
  ///
  /// In en, this message translates to:
  /// **'In step with the server'**
  String get syncInStepWithThe;

  /// No description provided for @syncTheyAreUploadedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'They are uploaded automatically in a few seconds.'**
  String get syncTheyAreUploadedAutomatically;

  /// No description provided for @syncChangeSToUpload.
  ///
  /// In en, this message translates to:
  /// **'{waiting, plural, =1{{waiting} change} other{{waiting} changes}} to upload'**
  String syncChangeSToUpload(int waiting);

  /// No description provided for @syncEverythingYouDoIs.
  ///
  /// In en, this message translates to:
  /// **'Everything you do is saved on this device and uploaded later.'**
  String get syncEverythingYouDoIs;

  /// No description provided for @syncChangeSAreSaved.
  ///
  /// In en, this message translates to:
  /// **'{waiting, plural, =1{{waiting} change} other{{waiting} changes}} are saved on this device and are uploaded automatically when the connection is back.'**
  String syncChangeSAreSaved(int waiting);

  /// No description provided for @syncYouAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get syncYouAreOffline;

  /// No description provided for @syncTheServerCannotBe.
  ///
  /// In en, this message translates to:
  /// **'The server cannot be reached'**
  String get syncTheServerCannotBe;

  /// No description provided for @syncTheServerRefusedThem.
  ///
  /// In en, this message translates to:
  /// **'The server refused them. Retry them, or discard them below.'**
  String get syncTheServerRefusedThem;

  /// No description provided for @syncChangeSNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{failed, plural, =1{{failed} change} other{{failed} changes}} need attention'**
  String syncChangeSNeedAttention(int failed);

  /// No description provided for @syncPleaseKeepTheApp.
  ///
  /// In en, this message translates to:
  /// **'Please keep the app open.'**
  String get syncPleaseKeepTheApp;

  /// No description provided for @syncRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused: {error}'**
  String syncRefused(Object error);

  /// No description provided for @syncUploadedWaitingForThe.
  ///
  /// In en, this message translates to:
  /// **'Uploaded, waiting for the server\'s copy'**
  String get syncUploadedWaitingForThe;

  /// No description provided for @syncWaitingToUpload.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload · {value}'**
  String syncWaitingToUpload(Object value);

  /// No description provided for @usersManagerSStaff.
  ///
  /// In en, this message translates to:
  /// **'{managers, plural, =1{{managers} manager} other{{managers} managers}}, {staff} staff'**
  String usersManagerSStaff(int managers, Object staff);

  /// No description provided for @usersTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'{value} turned off'**
  String usersTurnedOff(Object value);

  /// No description provided for @usersActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get usersActivate;

  /// No description provided for @usersDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get usersDeactivate;

  /// No description provided for @usersYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String usersYou(Object name);

  /// No description provided for @userFormCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get userFormCreateUser;

  /// No description provided for @userFormInactiveUsersCannotUse.
  ///
  /// In en, this message translates to:
  /// **'Inactive users cannot use the app.'**
  String get userFormInactiveUsersCannotUse;

  /// No description provided for @userFormYouCannotDeactivateYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot deactivate yourself.'**
  String get userFormYouCannotDeactivateYourself;

  /// No description provided for @userFormYouCannotChangeYour.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role.'**
  String get userFormYouCannotChangeYour;

  /// No description provided for @userFormUseAtLeast6.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get userFormUseAtLeast6;

  /// No description provided for @userFormTheLoginEmailCannot.
  ///
  /// In en, this message translates to:
  /// **'The login email cannot be changed.'**
  String get userFormTheLoginEmailCannot;

  /// No description provided for @userFormEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get userFormEditUser;

  /// No description provided for @logoutButtonDoYouWantTo.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out of A2 Stocks?'**
  String get logoutButtonDoYouWantTo;

  /// No description provided for @logoutButtonYouHaveChangeS.
  ///
  /// In en, this message translates to:
  /// **'You have {pendingCount, plural, =1{{pendingCount} change} other{{pendingCount} changes}} that were not uploaded. They stay on this device and are uploaded when you sign in again with a connection. Sign out anyway?'**
  String logoutButtonYouHaveChangeS(int pendingCount);

  /// No description provided for @onlineStatusChipNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get onlineStatusChipNoConnection;

  /// No description provided for @onlineStatusChipOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatusChipOnline;

  /// No description provided for @orderReceiptCardUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get orderReceiptCardUnpaid;

  /// No description provided for @orderReceiptCardPartlyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get orderReceiptCardPartlyPaid;

  /// No description provided for @orderReceiptCardCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderReceiptCardCancelled;

  /// No description provided for @partyListNoCity.
  ///
  /// In en, this message translates to:
  /// **'No city'**
  String get partyListNoCity;

  /// No description provided for @partyListNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get partyListNoPhone;

  /// No description provided for @partyListOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Over limit'**
  String get partyListOverLimit;

  /// No description provided for @partyListWithABalance2.
  ///
  /// In en, this message translates to:
  /// **'{withBalance} with a balance'**
  String partyListWithABalance2(Object withBalance);

  /// No description provided for @partyListToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get partyListToPay;

  /// No description provided for @partyListNothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get partyListNothingHereYet;

  /// No description provided for @partyPickerWalkInCustomerNo.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer (no account)'**
  String get partyPickerWalkInCustomerNo;

  /// No description provided for @photoWidgetsAPhoto.
  ///
  /// In en, this message translates to:
  /// **'a photo'**
  String get photoWidgetsAPhoto;

  /// No description provided for @photoWidgetsChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get photoWidgetsChangePhoto;

  /// No description provided for @photoWidgetsPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoWidgetsPhoto;

  /// No description provided for @receiptActionsReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt {orderNo}'**
  String receiptActionsReceipt(Object orderNo);

  /// No description provided for @receiptDue.
  ///
  /// In en, this message translates to:
  /// **'Due :'**
  String get receiptDue;

  /// No description provided for @receiptChange.
  ///
  /// In en, this message translates to:
  /// **'Change :'**
  String get receiptChange;

  /// No description provided for @receiptDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery :'**
  String get receiptDelivery;

  /// No description provided for @receiptDiscount2.
  ///
  /// In en, this message translates to:
  /// **'Discount :'**
  String get receiptDiscount2;

  /// No description provided for @receiptSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total :'**
  String get receiptSubTotal;

  /// No description provided for @receiptReceiptNo.
  ///
  /// In en, this message translates to:
  /// **'Receipt No'**
  String get receiptReceiptNo;

  /// No description provided for @receiptServedBy.
  ///
  /// In en, this message translates to:
  /// **'Served by'**
  String get receiptServedBy;

  /// No description provided for @syncStatusChipSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusChipSynced;

  /// No description provided for @syncStatusChipToUpload.
  ///
  /// In en, this message translates to:
  /// **'{waiting} to upload'**
  String syncStatusChipToUpload(Object waiting);

  /// No description provided for @syncStatusChipOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusChipOffline;

  /// No description provided for @syncStatusChipWaitingOffline.
  ///
  /// In en, this message translates to:
  /// **'{waiting} waiting (offline)'**
  String syncStatusChipWaitingOffline(Object waiting);

  /// No description provided for @syncStatusChipNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{failed} need attention'**
  String syncStatusChipNeedAttention(Object failed);

  /// No description provided for @syncStatusChipSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncStatusChipSyncing;

  /// No description provided for @variantPickerSkuCost.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Cost {value}'**
  String variantPickerSkuCost(Object sku, Object value);

  /// No description provided for @variantPickerSkuPrice.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Price {value}'**
  String variantPickerSkuPrice(Object sku, Object value);

  /// Navigation titles of the modules (side bar, drawer, page headings).
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get moduleCategories;

  /// No description provided for @moduleProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get moduleProducts;

  /// No description provided for @moduleCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get moduleCustomers;

  /// No description provided for @moduleVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get moduleVendors;

  /// No description provided for @modulePurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get modulePurchases;

  /// No description provided for @modulePos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get modulePos;

  /// No description provided for @moduleSalesOrders.
  ///
  /// In en, this message translates to:
  /// **'Sales & Orders'**
  String get moduleSalesOrders;

  /// No description provided for @moduleStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get moduleStock;

  /// No description provided for @moduleActivityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get moduleActivityLogs;

  /// No description provided for @moduleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moduleSettings;

  /// No description provided for @moduleUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get moduleUsers;

  /// Headings the modules are listed under in the navigation.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get moduleGroupMain;

  /// No description provided for @moduleGroupInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get moduleGroupInventory;

  /// No description provided for @moduleGroupSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get moduleGroupSales;

  /// No description provided for @moduleGroupPurchasing.
  ///
  /// In en, this message translates to:
  /// **'Purchasing'**
  String get moduleGroupPurchasing;

  /// No description provided for @moduleGroupSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get moduleGroupSystem;

  /// A number of products, with the right plural form.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} product} other{{count} products}}'**
  String countProducts(int count);

  /// No description provided for @countSubcategories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} subcategory} other{{count} subcategories}}'**
  String countSubcategories(int count);

  /// No description provided for @countVariants.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} variant} other{{count} variants}}'**
  String countVariants(int count);

  /// No description provided for @categoriesTipHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} · {subcategories}'**
  String categoriesTipHeader(String name, String subcategories);

  /// No description provided for @categoriesTipChild.
  ///
  /// In en, this message translates to:
  /// **'•  {name} — {products}'**
  String categoriesTipChild(String name, String products);

  /// No description provided for @categoriesTipTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {products} ({direct} directly in {name})'**
  String categoriesTipTotal(String products, Object direct, String name);

  /// No description provided for @productsUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get productsUncategorized;

  /// No description provided for @productsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{category} · {variants} · {price}'**
  String productsSubtitle(String category, String variants, String price);

  /// No description provided for @productFormSku.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku}'**
  String productFormSku(String sku);

  /// No description provided for @productFormSkuInactive.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Inactive'**
  String productFormSkuInactive(String sku);

  /// No description provided for @starterPackSimilarAll.
  ///
  /// In en, this message translates to:
  /// **'Your store looks similar: you already have {matched}. You have all of this pack.'**
  String starterPackSimilarAll(String matched);

  /// No description provided for @starterPackSimilarSome.
  ///
  /// In en, this message translates to:
  /// **'Your store looks similar: you already have {matched}. {have} of {total} categories are already added; add the rest.'**
  String starterPackSimilarSome(String matched, int have, int total);

  /// No description provided for @starterPackWillAdd.
  ///
  /// In en, this message translates to:
  /// **'{toAdd, plural, =1{1 new category will be added.} other{{toAdd} new categories will be added.}}'**
  String starterPackWillAdd(int toAdd);

  /// No description provided for @starterPackWillAddLeft.
  ///
  /// In en, this message translates to:
  /// **'{toAdd, plural, =1{1 new category will be added ({have} you already have are left as they are).} other{{toAdd} new categories will be added ({have} you already have are left as they are).}}'**
  String starterPackWillAddLeft(int toAdd, int have);

  /// No description provided for @activityLogsCount.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total, plural, =1{1 log} other{{total} logs}}'**
  String activityLogsCount(int shown, int total);

  /// No description provided for @activityLogsErrors.
  ///
  /// In en, this message translates to:
  /// **' · {count, plural, =1{1 error} other{{count} errors}}'**
  String activityLogsErrors(int count);

  /// No description provided for @activityLogsNotUploaded.
  ///
  /// In en, this message translates to:
  /// **' · {count} not uploaded yet'**
  String activityLogsNotUploaded(int count);

  /// No description provided for @heldSalesItemsTotal.
  ///
  /// In en, this message translates to:
  /// **'{units, plural, =1{1 item} other{{units} items}} · {total}'**
  String heldSalesItemsTotal(int units, String total);

  /// No description provided for @posInStockCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String posInStockCount(int count);

  /// No description provided for @purchaseFormSkuInStock.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · In stock now: {count}'**
  String purchaseFormSkuInStock(String sku, int count);

  /// No description provided for @orderDetailSaleLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {type} sale'**
  String orderDetailSaleLine(String date, String type);

  /// No description provided for @orderDetailSaleLineOnline.
  ///
  /// In en, this message translates to:
  /// **'{date} · {type} sale · Online store'**
  String orderDetailSaleLineOnline(String date, String type);

  /// No description provided for @stockAuditSystemLine.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · System {onHand}'**
  String stockAuditSystemLine(String sku, int onHand);

  /// No description provided for @stockAuditSystemLineInactive.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · System {onHand} · inactive'**
  String stockAuditSystemLineInactive(String sku, int onHand);

  /// No description provided for @stockAuditDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference {variance}'**
  String stockAuditDifference(String variance);

  /// No description provided for @stockAuditItemLine.
  ///
  /// In en, this message translates to:
  /// **'{product} · {variant} ({sku}): system {system}, counted {counted} ({variance})'**
  String stockAuditItemLine(String product, String variant, String sku,
      int system, int counted, String variance);

  /// No description provided for @stockCostLine.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Cost {cost}'**
  String stockCostLine(String sku, String cost);

  /// No description provided for @stockCostAlertLine.
  ///
  /// In en, this message translates to:
  /// **'SKU {sku} · Cost {cost} · Alert at {alert}'**
  String stockCostAlertLine(String sku, String cost, int alert);

  /// No description provided for @usersDeleteUserMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? They will lose access to the app immediately. Their login remains in Firebase Authentication but cannot open the app. To block access but keep the record, deactivate the user instead.'**
  String usersDeleteUserMessage(String name);

  /// No description provided for @orderReceiptMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+ {count, plural, =1{1 more item} other{{count} more items}}'**
  String orderReceiptMoreItems(int count);

  /// No description provided for @onboardingContentWithEMailSet.
  ///
  /// In en, this message translates to:
  /// **'With e-mail set up, shoppers get a confirmation and you get an alert for each new order.'**
  String get onboardingContentWithEMailSet;

  /// No description provided for @onboardingContentSwitchTheStoreOff.
  ///
  /// In en, this message translates to:
  /// **'Switch the store off in Settings to stop taking orders.'**
  String get onboardingContentSwitchTheStoreOff;

  /// No description provided for @onboardingContentOrdersArriveHereAs.
  ///
  /// In en, this message translates to:
  /// **'Orders arrive here as \"Online store\" with the delivery address; the stock is taken out at once.'**
  String get onboardingContentOrdersArriveHereAs;

  /// No description provided for @onboardingContentOnlyActiveProductsWith.
  ///
  /// In en, this message translates to:
  /// **'Only active products with a price and a category that is active are shown.'**
  String get onboardingContentOnlyActiveProductsWith;

  /// No description provided for @onboardingContentAPersonWhoLeaves.
  ///
  /// In en, this message translates to:
  /// **'A person who leaves is switched off, never deleted, so history stays correct.'**
  String get onboardingContentAPersonWhoLeaves;

  /// No description provided for @onboardingContentAdminEverythingPlusUsers.
  ///
  /// In en, this message translates to:
  /// **'Admin: everything, plus users, activity logs and the store settings.'**
  String get onboardingContentAdminEverythingPlusUsers;

  /// No description provided for @onboardingContentManagerEverythingStaffDo.
  ///
  /// In en, this message translates to:
  /// **'Manager: everything staff do, plus vendors, purchases, stock audits, the dashboard, and cancelling orders.'**
  String get onboardingContentManagerEverythingStaffDo;

  /// No description provided for @onboardingContentStaffSellRecordPayments.
  ///
  /// In en, this message translates to:
  /// **'Staff: sell, record payments, look up stock and products.'**
  String get onboardingContentStaffSellRecordPayments;

  /// No description provided for @onboardingContent6UsersALogin.
  ///
  /// In en, this message translates to:
  /// **'6. Users: a login for each person, with the right role.'**
  String get onboardingContent6UsersALogin;

  /// No description provided for @onboardingContent5PurchasesToPut.
  ///
  /// In en, this message translates to:
  /// **'5. Purchases to put the first stock on the shelf (or a Stock Audit to count what you have).'**
  String get onboardingContent5PurchasesToPut;

  /// No description provided for @onboardingContent4VendorsAndCustomers.
  ///
  /// In en, this message translates to:
  /// **'4. Vendors and Customers; record opening balances if people already owe or are owed.'**
  String get onboardingContent4VendorsAndCustomers;

  /// No description provided for @onboardingContent3CategoriesStartFrom.
  ///
  /// In en, this message translates to:
  /// **'3. Categories (start from a ready-made Starter pack for your kind of business), then Products with their variants, prices and photos.'**
  String get onboardingContent3CategoriesStartFrom;

  /// No description provided for @onboardingContent2SettingsOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'2. Settings > Online store > \"Send test e-mail\" to check that e-mail works.'**
  String get onboardingContent2SettingsOnlineStore;

  /// No description provided for @onboardingContent1SettingsOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'1. Settings > Online store: store name, phone, delivery fee, free-delivery amount.'**
  String get onboardingContent1SettingsOnlineStore;

  /// No description provided for @onboardingContentSetAnAlertLevel.
  ///
  /// In en, this message translates to:
  /// **'Set an alert level on a variant to be warned before it runs out.'**
  String get onboardingContentSetAnAlertLevel;

  /// No description provided for @onboardingContentOnlyYouAndAdmins.
  ///
  /// In en, this message translates to:
  /// **'Only you and admins can cancel an order; do it for fake or refused online orders so the stock comes back.'**
  String get onboardingContentOnlyYouAndAdmins;

  /// No description provided for @onboardingContentOnlineOrdersAreMarked.
  ///
  /// In en, this message translates to:
  /// **'Online orders are marked \"Online store\" and already took their stock out.'**
  String get onboardingContentOnlineOrdersAreMarked;

  /// No description provided for @onboardingContentYouCanAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'You can add photos to products you can open.'**
  String get onboardingContentYouCanAddPhotos;

  /// No description provided for @onboardingContentRedNumbersInStock.
  ///
  /// In en, this message translates to:
  /// **'Red numbers in Stock mean the system thinks there is less than zero: tell your manager.'**
  String get onboardingContentRedNumbersInStock;

  /// No description provided for @onboardingContentMoveAnOrderAlong.
  ///
  /// In en, this message translates to:
  /// **'Move an order along: Pending, Processing, Shipped, Delivered.'**
  String get onboardingContentMoveAnOrderAlong;

  /// No description provided for @onboardingContentRecordThePaymentNow.
  ///
  /// In en, this message translates to:
  /// **'Record the payment now or later from the order.'**
  String get onboardingContentRecordThePaymentNow;

  /// No description provided for @onboardingContentChooseTheCustomerAdd.
  ///
  /// In en, this message translates to:
  /// **'Choose the customer, add the products and quantities, and give a discount if allowed.'**
  String get onboardingContentChooseTheCustomerAdd;

  /// No description provided for @onboardingContentSalesMadeOfflineAre.
  ///
  /// In en, this message translates to:
  /// **'Sales made offline are always recorded, even if the shelf turns out to be empty.'**
  String get onboardingContentSalesMadeOfflineAre;

  /// No description provided for @onboardingContentIfTheServerRefuses.
  ///
  /// In en, this message translates to:
  /// **'If the server refuses something, it appears on the Sync screen with the reason; you can retry or discard it.'**
  String get onboardingContentIfTheServerRefuses;

  /// No description provided for @onboardingContentTheChipAtThe.
  ///
  /// In en, this message translates to:
  /// **'The chip at the top shows what is waiting to be sent.'**
  String get onboardingContentTheChipAtThe;

  /// Order status names.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// Retail / wholesale tags of an order or a customer.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get saleTypeRetail;

  /// No description provided for @saleTypeWholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale'**
  String get saleTypeWholesale;

  /// No description provided for @partyTypeVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get partyTypeVendor;

  /// No description provided for @partyTypeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get partyTypeCustomer;

  /// What a party balance is called.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get balanceSettled;

  /// No description provided for @balanceToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get balanceToReceive;

  /// No description provided for @balanceAdvanceReceived.
  ///
  /// In en, this message translates to:
  /// **'Advance received'**
  String get balanceAdvanceReceived;

  /// No description provided for @balanceToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get balanceToPay;

  /// No description provided for @balanceAdvancePaid.
  ///
  /// In en, this message translates to:
  /// **'Advance paid'**
  String get balanceAdvancePaid;

  /// No description provided for @ledgerSaleOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Sale on credit'**
  String get ledgerSaleOnCredit;

  /// No description provided for @ledgerPurchaseOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Purchase on credit'**
  String get ledgerPurchaseOnCredit;

  /// No description provided for @ledgerPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get ledgerPaymentReceived;

  /// No description provided for @ledgerPaymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment made'**
  String get ledgerPaymentMade;

  /// No description provided for @vendorTypeManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get vendorTypeManufacturer;

  /// No description provided for @vendorTypeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get vendorTypeShop;

  /// No description provided for @vendorTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vendorTypeOther;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodEasypaisa.
  ///
  /// In en, this message translates to:
  /// **'Easypaisa'**
  String get paymentMethodEasypaisa;

  /// No description provided for @paymentMethodJazzcash.
  ///
  /// In en, this message translates to:
  /// **'JazzCash'**
  String get paymentMethodJazzcash;

  /// No description provided for @paymentMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodBank;

  /// Shown when a payment has no recorded method.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentMethodUnknown;

  /// No description provided for @purchaseStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get purchaseStatusPending;

  /// No description provided for @purchaseStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get purchaseStatusPartial;

  /// No description provided for @purchaseStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get purchaseStatusPaid;

  /// No description provided for @stockMovementPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get stockMovementPurchase;

  /// No description provided for @stockMovementSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get stockMovementSale;

  /// No description provided for @stockMovementAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get stockMovementAdjustment;

  /// No description provided for @userRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get userRoleAdmin;

  /// No description provided for @userRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get userRoleManager;

  /// No description provided for @userRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get userRoleStaff;

  /// No description provided for @logLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get logLevelInfo;

  /// No description provided for @logLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get logLevelWarning;

  /// No description provided for @logLevelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logLevelError;

  /// No description provided for @logKindRecord.
  ///
  /// In en, this message translates to:
  /// **'Record change'**
  String get logKindRecord;

  /// No description provided for @logKindAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get logKindAction;

  /// No description provided for @logKindFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get logKindFailure;

  /// No description provided for @logKindSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get logKindSync;

  /// No description provided for @logKindSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get logKindSession;

  /// No description provided for @activityLogLoadedLogS.
  ///
  /// In en, this message translates to:
  /// **'Loaded {length} log(s).'**
  String activityLogLoadedLogS(Object length);

  /// No description provided for @authControllerSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get authControllerSignedOut;

  /// No description provided for @authControllerSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get authControllerSignedIn;

  /// No description provided for @catalogThisProductCannotBe.
  ///
  /// In en, this message translates to:
  /// **'This product cannot be deleted because {reason}. Mark it inactive instead.'**
  String catalogThisProductCannotBe(Object reason);

  /// No description provided for @catalogHasStockHistoryAnd.
  ///
  /// In en, this message translates to:
  /// **'\"{label}\" has stock history and cannot be removed. Mark it inactive instead.'**
  String catalogHasStockHistoryAnd(Object label);

  /// No description provided for @catalogTheSelectedCategoryNo.
  ///
  /// In en, this message translates to:
  /// **'The selected category no longer exists.'**
  String get catalogTheSelectedCategoryNo;

  /// No description provided for @catalogSkuAlreadyBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'SKU \"{value}\" already belongs to \"{name}\".'**
  String catalogSkuAlreadyBelongsTo(Object value, Object name);

  /// No description provided for @catalogSkuIsUsedTwice.
  ///
  /// In en, this message translates to:
  /// **'SKU \"{value}\" is used twice in this product.'**
  String catalogSkuIsUsedTwice(Object value);

  /// No description provided for @catalogEveryVariantNeedsA.
  ///
  /// In en, this message translates to:
  /// **'Every variant needs a SKU.'**
  String get catalogEveryVariantNeedsA;

  /// No description provided for @catalogProductNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required.'**
  String get catalogProductNameIsRequired;

  /// No description provided for @catalogThisCategoryCannotBe.
  ///
  /// In en, this message translates to:
  /// **'This category cannot be deleted because {reason}.'**
  String catalogThisCategoryCannotBe(Object reason);

  /// No description provided for @catalogTheSelectedParentCategory.
  ///
  /// In en, this message translates to:
  /// **'The selected parent category no longer exists.'**
  String get catalogTheSelectedParentCategory;

  /// No description provided for @catalogACategoryCannotBe.
  ///
  /// In en, this message translates to:
  /// **'A category cannot be placed inside itself or its subcategories.'**
  String get catalogACategoryCannotBe;

  /// No description provided for @catalogACategoryNamedAlready.
  ///
  /// In en, this message translates to:
  /// **'A category named \"{value}\" already exists here.'**
  String catalogACategoryNamedAlready(Object value);

  /// No description provided for @catalogCategoryNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required.'**
  String get catalogCategoryNameIsRequired;

  /// No description provided for @catalogOnlyAdminsAndManagers.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can change the catalog.'**
  String get catalogOnlyAdminsAndManagers;

  /// No description provided for @catalogItHasStockHistory.
  ///
  /// In en, this message translates to:
  /// **'it has stock history'**
  String get catalogItHasStockHistory;

  /// No description provided for @catalogItIsUsedBy.
  ///
  /// In en, this message translates to:
  /// **'it is used by {used} product(s)'**
  String catalogItIsUsedBy(Object used);

  /// No description provided for @catalogItHasSubcategories.
  ///
  /// In en, this message translates to:
  /// **'it has subcategories'**
  String get catalogItHasSubcategories;

  /// No description provided for @dashboardInsightsUncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get dashboardInsightsUncategorised;

  /// No description provided for @dashboardThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dashboardThisMonth;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @localDataNoUserIsSigned.
  ///
  /// In en, this message translates to:
  /// **'No user is signed in, so there is no database to open.'**
  String get localDataNoUserIsSigned;

  /// No description provided for @partiesThisEntryBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'This entry belongs to a purchase and cannot be deleted.'**
  String get partiesThisEntryBelongsTo;

  /// No description provided for @partiesThisPartyNoLonger.
  ///
  /// In en, this message translates to:
  /// **'This party no longer exists.'**
  String get partiesThisPartyNoLonger;

  /// No description provided for @partiesTheAmountMustBe.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than zero.'**
  String get partiesTheAmountMustBe;

  /// No description provided for @partiesThisCustomerCannotBe.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be deleted because {reason}. Deactivate it instead.'**
  String partiesThisCustomerCannotBe(Object reason);

  /// No description provided for @partiesTheCreditLimitCannot.
  ///
  /// In en, this message translates to:
  /// **'The credit limit cannot be negative.'**
  String get partiesTheCreditLimitCannot;

  /// No description provided for @partiesACustomerWithThis.
  ///
  /// In en, this message translates to:
  /// **'A customer with this phone number already exists.'**
  String get partiesACustomerWithThis;

  /// No description provided for @partiesCustomerNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer name is required.'**
  String get partiesCustomerNameIsRequired;

  /// No description provided for @partiesThisVendorCannotBe.
  ///
  /// In en, this message translates to:
  /// **'This vendor cannot be deleted because {reason}. Deactivate it instead.'**
  String partiesThisVendorCannotBe(Object reason);

  /// No description provided for @partiesAVendorWithThis.
  ///
  /// In en, this message translates to:
  /// **'A vendor with this phone number already exists.'**
  String get partiesAVendorWithThis;

  /// No description provided for @partiesAVendorNamedAlready.
  ///
  /// In en, this message translates to:
  /// **'A vendor named \"{value}\" already exists.'**
  String partiesAVendorNamedAlready(Object value);

  /// No description provided for @partiesVendorNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Vendor name is required.'**
  String get partiesVendorNameIsRequired;

  /// No description provided for @partiesItHasOrders.
  ///
  /// In en, this message translates to:
  /// **'it has orders'**
  String get partiesItHasOrders;

  /// No description provided for @partiesItHasAnOpening.
  ///
  /// In en, this message translates to:
  /// **'it has an opening balance'**
  String get partiesItHasAnOpening;

  /// No description provided for @partiesItHasLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'it has ledger entries'**
  String get partiesItHasLedgerEntries;

  /// No description provided for @partiesOnlyAdminsAndManagers.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can change vendors, customers and ledgers.'**
  String get partiesOnlyAdminsAndManagers;

  /// No description provided for @purchasingPaymentOfRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Payment of {value} recorded for purchase {purchaseNo} ({vendorName}).'**
  String purchasingPaymentOfRecordedFor(
      Object value, Object purchaseNo, Object vendorName);

  /// No description provided for @purchasingThePaymentIsMore.
  ///
  /// In en, this message translates to:
  /// **'The payment is more than the amount due ({value}).'**
  String purchasingThePaymentIsMore(Object value);

  /// No description provided for @purchasingPurchaseConfirmedFromItem.
  ///
  /// In en, this message translates to:
  /// **'Purchase {purchaseNo} confirmed from {vendorName}: {length} item(s), {totalUnits} unit(s), total {value}, paid now {value2}. Stock added and the vendor ledger charged.'**
  String purchasingPurchaseConfirmedFromItem(
      Object purchaseNo,
      Object vendorName,
      Object length,
      Object totalUnits,
      Object value,
      Object value2);

  /// No description provided for @purchasingTheAmountPaidMust.
  ///
  /// In en, this message translates to:
  /// **'The amount paid must be between 0 and the purchase total.'**
  String get purchasingTheAmountPaidMust;

  /// No description provided for @purchasingNoLongerExistsIn.
  ///
  /// In en, this message translates to:
  /// **'\"{productName}\" no longer exists in the catalog.'**
  String purchasingNoLongerExistsIn(Object productName);

  /// No description provided for @purchasingABuyingPriceCannot.
  ///
  /// In en, this message translates to:
  /// **'A buying price cannot be negative.'**
  String get purchasingABuyingPriceCannot;

  /// No description provided for @purchasingEveryItemNeedsA.
  ///
  /// In en, this message translates to:
  /// **'Every item needs a quantity of at least 1.'**
  String get purchasingEveryItemNeedsA;

  /// No description provided for @purchasingThisVendorIsInactive.
  ///
  /// In en, this message translates to:
  /// **'This vendor is inactive.'**
  String get purchasingThisVendorIsInactive;

  /// No description provided for @purchasingOnlyAdminsAndManagers.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can record purchases.'**
  String get purchasingOnlyAdminsAndManagers;

  /// No description provided for @salesPaymentOfRecordedFor.
  ///
  /// In en, this message translates to:
  /// **'Payment of {value} recorded for order {orderNo} ({customerName}).'**
  String salesPaymentOfRecordedFor(
      Object value, Object orderNo, Object customerName);

  /// No description provided for @salesACancelledOrderCannot.
  ///
  /// In en, this message translates to:
  /// **'A cancelled order cannot take payments.'**
  String get salesACancelledOrderCannot;

  /// No description provided for @salesOrderCancelledWasUnit.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo} cancelled (was {label}): {totalUnits} unit(s) returned to stock and the {value} charge on {customerName}\'s ledger reversed.'**
  String salesOrderCancelledWasUnit(Object orderNo, Object label,
      Object totalUnits, Object value, Object customerName);

  /// No description provided for @salesAOrderCannotBe.
  ///
  /// In en, this message translates to:
  /// **'A {value} order cannot be cancelled.'**
  String salesAOrderCannotBe(Object value);

  /// No description provided for @salesOrderMovedFromTo.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo} moved from {label} to {label2}.'**
  String salesOrderMovedFromTo(Object orderNo, Object label, Object label2);

  /// No description provided for @salesAOrderCannotChange.
  ///
  /// In en, this message translates to:
  /// **'A {value} order cannot change status.'**
  String salesAOrderCannotChange(Object value);

  /// No description provided for @salesOrderConfirmedForItem.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo} confirmed for {customerName}: {length} item(s), {totalUnits} unit(s), {value} sale, total {value2}, paid now {value3}. Stock taken out and the customer ledger charged.'**
  String salesOrderConfirmedForItem(
      Object orderNo,
      Object customerName,
      Object length,
      Object totalUnits,
      Object value,
      Object value2,
      Object value3);

  /// No description provided for @salesThisOrderWouldTake.
  ///
  /// In en, this message translates to:
  /// **'This order would take {name} over the credit limit (limit {value}, balance after {value2}).'**
  String salesThisOrderWouldTake(Object name, Object value, Object value2);

  /// No description provided for @salesNotEnoughStockFor.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for \"{productName} · {variantLabel}\": {available} available, {wanted} requested.'**
  String salesNotEnoughStockFor(
      Object productName, Object variantLabel, Object available, Object wanted);

  /// No description provided for @salesIsInactive.
  ///
  /// In en, this message translates to:
  /// **'\"{productName} · {variantLabel}\" is inactive.'**
  String salesIsInactive(Object productName, Object variantLabel);

  /// No description provided for @salesTheAmountPaidMust.
  ///
  /// In en, this message translates to:
  /// **'The amount paid must be between 0 and the order total.'**
  String get salesTheAmountPaidMust;

  /// No description provided for @salesTheOrderDiscountMust.
  ///
  /// In en, this message translates to:
  /// **'The order discount must be between 0 and the order subtotal.'**
  String get salesTheOrderDiscountMust;

  /// No description provided for @salesEveryPaymentMustBe.
  ///
  /// In en, this message translates to:
  /// **'Every payment must be more than zero.'**
  String get salesEveryPaymentMustBe;

  /// No description provided for @salesTheDiscountOnMust.
  ///
  /// In en, this message translates to:
  /// **'The discount on \"{productName}\" must be between 0 and the line amount.'**
  String salesTheDiscountOnMust(Object productName);

  /// No description provided for @salesASellingPriceCannot.
  ///
  /// In en, this message translates to:
  /// **'A selling price cannot be negative.'**
  String get salesASellingPriceCannot;

  /// No description provided for @salesThisCustomerIsInactive.
  ///
  /// In en, this message translates to:
  /// **'This customer is inactive.'**
  String get salesThisCustomerIsInactive;

  /// No description provided for @salesOnlyAdminsAndManagers.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can cancel orders.'**
  String get salesOnlyAdminsAndManagers;

  /// No description provided for @salesYouAreNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to change orders.'**
  String get salesYouAreNotAllowed;

  /// No description provided for @stockAuditEveryCountedQuantityMatches2.
  ///
  /// In en, this message translates to:
  /// **'Every counted quantity matches the system, so there is nothing to adjust.'**
  String get stockAuditEveryCountedQuantityMatches2;

  /// No description provided for @stockAuditACountedItemNo.
  ///
  /// In en, this message translates to:
  /// **'A counted item no longer exists in the catalog.'**
  String get stockAuditACountedItemNo;

  /// No description provided for @stockAuditTheSameItemWas.
  ///
  /// In en, this message translates to:
  /// **'The same item was counted twice.'**
  String get stockAuditTheSameItemWas;

  /// No description provided for @stockAuditACountedQuantityCannot.
  ///
  /// In en, this message translates to:
  /// **'A counted quantity cannot be negative.'**
  String get stockAuditACountedQuantityCannot;

  /// No description provided for @stockAuditEnterTheCountedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter the counted quantity of at least one item.'**
  String get stockAuditEnterTheCountedQuantity;

  /// No description provided for @syncControllerEverythingIsInStep.
  ///
  /// In en, this message translates to:
  /// **'Everything is in step with the server.'**
  String get syncControllerEverythingIsInStep;

  /// No description provided for @syncControllerChangeSWereRefused.
  ///
  /// In en, this message translates to:
  /// **'{refused} change(s) were refused by the server. See the list below.'**
  String syncControllerChangeSWereRefused(Object refused);

  /// No description provided for @syncControllerTheServerCannotBe.
  ///
  /// In en, this message translates to:
  /// **'The server cannot be reached. Your work is saved on this device.'**
  String get syncControllerTheServerCannotBe;

  /// No description provided for @syncControllerSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {e}'**
  String syncControllerSyncFailed(Object e);

  /// No description provided for @usersYouCannotDeleteYour.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account.'**
  String get usersYouCannotDeleteYour;

  /// No description provided for @usersOnlyAnActiveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Only an active admin can delete users.'**
  String get usersOnlyAnActiveAdmin;

  /// No description provided for @usersUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get usersUserNotFound;

  /// No description provided for @usersYouCannotChangeYour.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role or active status.'**
  String get usersYouCannotChangeYour;

  /// No description provided for @usersOnlyAnActiveAdmin2.
  ///
  /// In en, this message translates to:
  /// **'Only an active admin can update users.'**
  String get usersOnlyAnActiveAdmin2;

  /// No description provided for @usersOnlyAnActiveAdmin3.
  ///
  /// In en, this message translates to:
  /// **'Only an active admin can add users.'**
  String get usersOnlyAnActiveAdmin3;

  /// No description provided for @appExceptionsTheCloudDataChanged.
  ///
  /// In en, this message translates to:
  /// **'The cloud data changed. Download the updates first.'**
  String get appExceptionsTheCloudDataChanged;

  /// No description provided for @posPaymentPlanThatIsMoreThan.
  ///
  /// In en, this message translates to:
  /// **'That is more than what is left to pay ({value}).'**
  String posPaymentPlanThatIsMoreThan(Object value);

  /// No description provided for @posPaymentPlanEnterTheTransactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the {label} transaction number.'**
  String posPaymentPlanEnterTheTransactionNumber(Object label);

  /// No description provided for @posPaymentPlanEnterTheBankAnd.
  ///
  /// In en, this message translates to:
  /// **'Enter the bank and transaction number.'**
  String get posPaymentPlanEnterTheBankAnd;

  /// No description provided for @posPaymentPlanTheSaleIsAlready.
  ///
  /// In en, this message translates to:
  /// **'The sale is already fully paid.'**
  String get posPaymentPlanTheSaleIsAlready;

  /// No description provided for @posPaymentPlanEnterAnAmountAbove.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get posPaymentPlanEnterAnAmountAbove;

  /// No description provided for @priceWarningsSalePriceIsLess.
  ///
  /// In en, this message translates to:
  /// **'Sale price is less than the cost price.'**
  String get priceWarningsSalePriceIsLess;

  /// No description provided for @priceWarningsWholesalePriceIsLess.
  ///
  /// In en, this message translates to:
  /// **'Wholesale price is less than the cost price.'**
  String get priceWarningsWholesalePriceIsLess;

  /// No description provided for @priceWarningsRetailPriceIsLess.
  ///
  /// In en, this message translates to:
  /// **'Retail price is less than the wholesale price.'**
  String get priceWarningsRetailPriceIsLess;

  /// No description provided for @receiptThankYouForShopping2.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping with us!'**
  String get receiptThankYouForShopping2;

  /// No description provided for @receiptBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due: {value}'**
  String receiptBalanceDue(Object value);

  /// No description provided for @receiptChange2.
  ///
  /// In en, this message translates to:
  /// **'Change: {value}'**
  String receiptChange2(Object value);

  /// No description provided for @receiptTotal.
  ///
  /// In en, this message translates to:
  /// **'*Total: {value}*'**
  String receiptTotal(Object value);

  /// No description provided for @receiptDelivery2.
  ///
  /// In en, this message translates to:
  /// **'Delivery: {value}'**
  String receiptDelivery2(Object value);

  /// No description provided for @receiptDiscount3.
  ///
  /// In en, this message translates to:
  /// **'Discount: -{value}'**
  String receiptDiscount3(Object value);

  /// No description provided for @receiptItems.
  ///
  /// In en, this message translates to:
  /// **'Items: {value}'**
  String receiptItems(Object value);

  /// No description provided for @receiptCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer: {customerName}'**
  String receiptCustomer(Object customerName);

  /// No description provided for @receiptReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt {orderNo}'**
  String receiptReceipt(Object orderNo);

  /// No description provided for @receiptTel.
  ///
  /// In en, this message translates to:
  /// **'Tel: {shopPhone}'**
  String receiptTel(Object shopPhone);

  /// No description provided for @receiptPdfDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount -{value}'**
  String receiptPdfDiscount(Object value);

  /// No description provided for @receiptPdfPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number : {shopPhone}'**
  String receiptPdfPhoneNumber(Object shopPhone);

  /// No description provided for @whatsappHelloYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Hello{who}, your order {orderNo} ({value}) {status}. - {shopName}'**
  String whatsappHelloYourOrder(
      Object who, Object orderNo, Object value, Object status, Object shopName);

  /// No description provided for @whatsappHasBeenCancelled.
  ///
  /// In en, this message translates to:
  /// **'has been cancelled'**
  String get whatsappHasBeenCancelled;

  /// No description provided for @whatsappHasBeenDeliveredThank.
  ///
  /// In en, this message translates to:
  /// **'has been delivered. Thank you for shopping with us!'**
  String get whatsappHasBeenDeliveredThank;

  /// No description provided for @whatsappIsOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'is on its way to you'**
  String get whatsappIsOnItsWay;

  /// No description provided for @whatsappIsBeingPrepared.
  ///
  /// In en, this message translates to:
  /// **'is being prepared'**
  String get whatsappIsBeingPrepared;

  /// No description provided for @whatsappHasBeenReceived.
  ///
  /// In en, this message translates to:
  /// **'has been received'**
  String get whatsappHasBeenReceived;

  /// No description provided for @apiAuthServiceTheServerDidNot.
  ///
  /// In en, this message translates to:
  /// **'The server did not return the new user.'**
  String get apiAuthServiceTheServerDidNot;

  /// No description provided for @apiClientTheServerHadA.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem (error {status}). Please try again.'**
  String apiClientTheServerHadA(Object status);

  /// No description provided for @apiClientTooManyAttemptsPlease.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get apiClientTooManyAttemptsPlease;

  /// No description provided for @apiClientYouAreNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this.'**
  String get apiClientYouAreNotAllowed;

  /// No description provided for @apiClientIncorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get apiClientIncorrectEmailOrPassword;

  /// No description provided for @apiClientTheServerRefusedThis.
  ///
  /// In en, this message translates to:
  /// **'The server refused this request.'**
  String get apiClientTheServerRefusedThis;

  /// No description provided for @apiClientCannotReachTheServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server at {_baseUrl}. Check your connection and try again. ({message})'**
  String apiClientCannotReachTheServer(Object _baseUrl, Object message);

  /// No description provided for @apiClientTheServerTookToo.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer. Please try again.'**
  String get apiClientTheServerTookToo;

  /// No description provided for @apiClientYourSessionEndedPlease.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Please sign in again.'**
  String get apiClientYourSessionEndedPlease;

  /// No description provided for @apiClientTheServerSentAn.
  ///
  /// In en, this message translates to:
  /// **'The server sent an unexpected sign-in answer.'**
  String get apiClientTheServerSentAn;

  /// No description provided for @apiCommandsRecordsOfCannotBe.
  ///
  /// In en, this message translates to:
  /// **'Records of \"{collection}\" cannot be deleted.'**
  String apiCommandsRecordsOfCannotBe(Object collection);

  /// No description provided for @apiCommandsRecordsOfCannotBe2.
  ///
  /// In en, this message translates to:
  /// **'Records of \"{collection}\" cannot be saved directly.'**
  String apiCommandsRecordsOfCannotBe2(Object collection);

  /// No description provided for @onlineRepositoriesUsersAreCreatedWith.
  ///
  /// In en, this message translates to:
  /// **'Users are created with a login (email and password).'**
  String get onlineRepositoriesUsersAreCreatedWith;

  /// No description provided for @onlineRepositoriesAStockCountCannot.
  ///
  /// In en, this message translates to:
  /// **'A stock count cannot be deleted.'**
  String get onlineRepositoriesAStockCountCannot;

  /// No description provided for @onlineRepositoriesAStockCountIs.
  ///
  /// In en, this message translates to:
  /// **'A stock count is created by confirming it.'**
  String get onlineRepositoriesAStockCountIs;

  /// No description provided for @onlineRepositoriesAnOrderCannotBe.
  ///
  /// In en, this message translates to:
  /// **'An order cannot be deleted. Cancel it instead.'**
  String get onlineRepositoriesAnOrderCannotBe;

  /// No description provided for @onlineRepositoriesAnOrderIsCreated.
  ///
  /// In en, this message translates to:
  /// **'An order is created by confirming it.'**
  String get onlineRepositoriesAnOrderIsCreated;

  /// No description provided for @onlineRepositoriesAConfirmedPurchaseCannot.
  ///
  /// In en, this message translates to:
  /// **'A confirmed purchase cannot be deleted.'**
  String get onlineRepositoriesAConfirmedPurchaseCannot;

  /// No description provided for @onlineRepositoriesAConfirmedPurchaseCannot2.
  ///
  /// In en, this message translates to:
  /// **'A confirmed purchase cannot be changed.'**
  String get onlineRepositoriesAConfirmedPurchaseCannot2;

  /// No description provided for @onlineRepositoriesStockChangesOnlyThrough.
  ///
  /// In en, this message translates to:
  /// **'Stock changes only through purchases, sales and stock counts.'**
  String get onlineRepositoriesStockChangesOnlyThrough;

  /// No description provided for @onlineRepositoriesLedgerEntriesCannotBe.
  ///
  /// In en, this message translates to:
  /// **'Ledger entries cannot be edited. Delete the entry and add it again.'**
  String get onlineRepositoriesLedgerEntriesCannotBe;

  /// No description provided for @photoServiceThePhotoCouldNot.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be uploaded. Check your connection and try again.'**
  String get photoServiceThePhotoCouldNot;

  /// No description provided for @photoServiceThePhotoCouldNot2.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be uploaded ({statusCode}). Please try again.'**
  String photoServiceThePhotoCouldNot2(Object statusCode);

  /// No description provided for @photoServiceTheServerDidNot.
  ///
  /// In en, this message translates to:
  /// **'The server did not give an upload link.'**
  String get photoServiceTheServerDidNot;

  /// No description provided for @photoServiceThisItemHasNot.
  ///
  /// In en, this message translates to:
  /// **'This item has not reached the server yet. Wait for it to sync, then add the photo.'**
  String get photoServiceThisItemHasNot;

  /// No description provided for @photoServiceChooseAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get photoServiceChooseAPhoto;

  /// No description provided for @photoServiceOnlyJpegPngOr.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG, PNG or WebP photos can be used.'**
  String get photoServiceOnlyJpegPngOr;

  /// No description provided for @photoServiceThatPhotoIsBigger.
  ///
  /// In en, this message translates to:
  /// **'That photo is bigger than 10 MB. Please choose a smaller one.'**
  String get photoServiceThatPhotoIsBigger;

  /// No description provided for @photoServiceThatFileIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'That file is empty.'**
  String get photoServiceThatFileIsEmpty;

  /// No description provided for @localRepositoriesStockCount.
  ///
  /// In en, this message translates to:
  /// **'Stock count {auditNo}'**
  String localRepositoriesStockCount(Object auditNo);

  /// No description provided for @localRepositoriesStockCount2.
  ///
  /// In en, this message translates to:
  /// **'Stock count'**
  String get localRepositoriesStockCount2;

  /// No description provided for @localRepositoriesCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order {orderNo}'**
  String localRepositoriesCancelOrder(Object orderNo);

  /// No description provided for @localRepositoriesOrder.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo}'**
  String localRepositoriesOrder(Object orderNo);

  /// No description provided for @localRepositoriesPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase {purchaseNo}'**
  String localRepositoriesPurchase(Object purchaseNo);

  /// No description provided for @localRepositoriesStockEntry.
  ///
  /// In en, this message translates to:
  /// **'Stock entry'**
  String get localRepositoriesStockEntry;

  /// No description provided for @localRepositoriesPaymentFor.
  ///
  /// In en, this message translates to:
  /// **'Payment {value} for {reference}'**
  String localRepositoriesPaymentFor(Object value, Object reference);

  /// No description provided for @localRepositoriesLedgerEntry.
  ///
  /// In en, this message translates to:
  /// **'Ledger entry'**
  String get localRepositoriesLedgerEntry;

  /// Currency names in the currency list of the shop details.
  ///
  /// In en, this message translates to:
  /// **'Pakistani rupee'**
  String get currencyPkr;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @currencyGbp.
  ///
  /// In en, this message translates to:
  /// **'British pound'**
  String get currencyGbp;

  /// No description provided for @currencyAed.
  ///
  /// In en, this message translates to:
  /// **'UAE dirham'**
  String get currencyAed;

  /// No description provided for @currencySar.
  ///
  /// In en, this message translates to:
  /// **'Saudi riyal'**
  String get currencySar;

  /// No description provided for @currencyQar.
  ///
  /// In en, this message translates to:
  /// **'Qatari riyal'**
  String get currencyQar;

  /// No description provided for @currencyInr.
  ///
  /// In en, this message translates to:
  /// **'Indian rupee'**
  String get currencyInr;

  /// No description provided for @currencyBdt.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi taka'**
  String get currencyBdt;

  /// No description provided for @currencyCad.
  ///
  /// In en, this message translates to:
  /// **'Canadian dollar'**
  String get currencyCad;

  /// No description provided for @currencyAud.
  ///
  /// In en, this message translates to:
  /// **'Australian dollar'**
  String get currencyAud;

  /// Activity-log summary of an applied stock count.
  ///
  /// In en, this message translates to:
  /// **'Stock count {auditNo} applied: {items, plural, =1{1 item} other{{items} items}} adjusted, net {net, plural, =1{{netText} unit} other{{netText} units}}.{note}'**
  String stockAuditLogSummary(
      String auditNo, int items, int net, String netText, String note);

  /// No description provided for @stockAuditLogNote.
  ///
  /// In en, this message translates to:
  /// **' Note: {note}'**
  String stockAuditLogNote(String note);

  /// The names of the pack groups the shop already has, as a sentence part.
  ///
  /// In en, this message translates to:
  /// **'{a}'**
  String starterPackMatchedOne(String a);

  /// No description provided for @starterPackMatchedTwo.
  ///
  /// In en, this message translates to:
  /// **'{a} and {b}'**
  String starterPackMatchedTwo(String a, String b);

  /// No description provided for @starterPackMatchedThree.
  ///
  /// In en, this message translates to:
  /// **'{a}, {b} and {c}'**
  String starterPackMatchedThree(String a, String b, String c);

  /// No description provided for @starterPackMatchedMore.
  ///
  /// In en, this message translates to:
  /// **'{a}, {b}, {c} and {more} more'**
  String starterPackMatchedMore(String a, String b, String c, int more);

  /// No description provided for @countGroups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} group} other{{count} groups}}'**
  String countGroups(int count);

  /// No description provided for @countCategories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} category} other{{count} categories}}'**
  String countCategories(int count);

  /// No description provided for @starterPackSizeLine.
  ///
  /// In en, this message translates to:
  /// **'{groups} · {categories}'**
  String starterPackSizeLine(String groups, String categories);

  /// No description provided for @starterPackGroupHave.
  ///
  /// In en, this message translates to:
  /// **'{subcategories} · you already have this one'**
  String starterPackGroupHave(String subcategories);

  /// No description provided for @photoWidgetsPhotos.
  ///
  /// In en, this message translates to:
  /// **'photos'**
  String get photoWidgetsPhotos;

  /// No description provided for @apiErrorAuditsACountedItemNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'A counted item no longer exists in the catalog.'**
  String get apiErrorAuditsACountedItemNoLongerExists;

  /// No description provided for @apiErrorAuditsAuditNumberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Audit number {supplied} already exists.'**
  String apiErrorAuditsAuditNumberAlreadyExists(String supplied);

  /// No description provided for @apiErrorAuditsCouldNotGenerateAnAuditNumber.
  ///
  /// In en, this message translates to:
  /// **'Could not generate an audit number, try again.'**
  String get apiErrorAuditsCouldNotGenerateAnAuditNumber;

  /// No description provided for @apiErrorAuditsEveryCountedQuantityMatchesTheSystem.
  ///
  /// In en, this message translates to:
  /// **'Every counted quantity matches the system, so there is nothing to adjust.'**
  String get apiErrorAuditsEveryCountedQuantityMatchesTheSystem;

  /// No description provided for @apiErrorAuditsStockAuditNotFound.
  ///
  /// In en, this message translates to:
  /// **'Stock audit not found'**
  String get apiErrorAuditsStockAuditNotFound;

  /// No description provided for @apiErrorAuditsTheSameItemWasCountedTwice.
  ///
  /// In en, this message translates to:
  /// **'The same item was counted twice.'**
  String get apiErrorAuditsTheSameItemWasCountedTwice;

  /// No description provided for @apiErrorAuditsThisStockAuditAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This stock audit already exists.'**
  String get apiErrorAuditsThisStockAuditAlreadyExists;

  /// No description provided for @apiErrorAuthAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account is disabled'**
  String get apiErrorAuthAccountDisabled;

  /// No description provided for @apiErrorAuthAccountDisabledToken.
  ///
  /// In en, this message translates to:
  /// **'Account is disabled'**
  String get apiErrorAuthAccountDisabledToken;

  /// No description provided for @apiErrorAuthInvalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get apiErrorAuthInvalidEmailOrPassword;

  /// No description provided for @apiErrorAuthInvalidOrExpiredAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired access token'**
  String get apiErrorAuthInvalidOrExpiredAccessToken;

  /// No description provided for @apiErrorAuthInvalidRefreshToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid refresh token'**
  String get apiErrorAuthInvalidRefreshToken;

  /// No description provided for @apiErrorAuthMissingAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Missing access token'**
  String get apiErrorAuthMissingAccessToken;

  /// No description provided for @apiErrorAuthRefreshTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Refresh token expired'**
  String get apiErrorAuthRefreshTokenExpired;

  /// No description provided for @apiErrorAuthRefreshTokenWasAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Refresh token was already used'**
  String get apiErrorAuthRefreshTokenWasAlreadyUsed;

  /// No description provided for @apiErrorAuthYouDoNotHavePermissionFor.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action'**
  String get apiErrorAuthYouDoNotHavePermissionFor;

  /// No description provided for @apiErrorCategoriesACategoryCannotBePlacedInside.
  ///
  /// In en, this message translates to:
  /// **'A category cannot be placed inside itself or its subcategories.'**
  String get apiErrorCategoriesACategoryCannotBePlacedInside;

  /// No description provided for @apiErrorCategoriesACategoryNamedAlreadyExistsHere.
  ///
  /// In en, this message translates to:
  /// **'A category named \"{name}\" already exists here.'**
  String apiErrorCategoriesACategoryNamedAlreadyExistsHere(String name);

  /// No description provided for @apiErrorCategoriesCategoryNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required.'**
  String get apiErrorCategoriesCategoryNameIsRequired;

  /// No description provided for @apiErrorCategoriesCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get apiErrorCategoriesCategoryNotFound;

  /// No description provided for @apiErrorCategoriesTheSelectedParentCategoryNoLonger.
  ///
  /// In en, this message translates to:
  /// **'The selected parent category no longer exists.'**
  String get apiErrorCategoriesTheSelectedParentCategoryNoLonger;

  /// No description provided for @apiErrorCategoriesDeleteHasSubcategories.
  ///
  /// In en, this message translates to:
  /// **'This category cannot be deleted because it has subcategories.'**
  String get apiErrorCategoriesDeleteHasSubcategories;

  /// No description provided for @apiErrorCategoriesDeleteUsedByProducts.
  ///
  /// In en, this message translates to:
  /// **'This category cannot be deleted because it is used by {count, plural, =1{{count} product} other{{count} products}}.'**
  String apiErrorCategoriesDeleteUsedByProducts(int count);

  /// No description provided for @apiErrorCustomersACustomerWithThisPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'A customer with this phone number already exists.'**
  String get apiErrorCustomersACustomerWithThisPhoneNumber;

  /// No description provided for @apiErrorCustomersCustomerNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer name is required.'**
  String get apiErrorCustomersCustomerNameIsRequired;

  /// No description provided for @apiErrorCustomersCustomerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get apiErrorCustomersCustomerNotFound;

  /// No description provided for @apiErrorCustomersDeleteHasLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be deleted because it has ledger entries. Deactivate it instead.'**
  String get apiErrorCustomersDeleteHasLedgerEntries;

  /// No description provided for @apiErrorCustomersDeleteHasOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be deleted because it has an opening balance. Deactivate it instead.'**
  String get apiErrorCustomersDeleteHasOpeningBalance;

  /// No description provided for @apiErrorCustomersDeleteHasOrders.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be deleted because it has orders. Deactivate it instead.'**
  String get apiErrorCustomersDeleteHasOrders;

  /// No description provided for @apiErrorCustomersTheWalkInCustomerIsUsed.
  ///
  /// In en, this message translates to:
  /// **'The walk-in customer is used by the POS and cannot be deleted.'**
  String get apiErrorCustomersTheWalkInCustomerIsUsed;

  /// No description provided for @apiErrorDbNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found.'**
  String get apiErrorDbNotFound;

  /// No description provided for @apiErrorDbStillReferenced.
  ///
  /// In en, this message translates to:
  /// **'This record is still referenced by other records.'**
  String get apiErrorDbStillReferenced;

  /// No description provided for @apiErrorDbUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected database error'**
  String get apiErrorDbUnexpected;

  /// No description provided for @apiErrorDbUniqueViolation.
  ///
  /// In en, this message translates to:
  /// **'A record with the same unique value already exists.'**
  String get apiErrorDbUniqueViolation;

  /// No description provided for @apiErrorIdempotencyARequestWithThisIdempotencyKey.
  ///
  /// In en, this message translates to:
  /// **'A request with this Idempotency-Key is still in progress. Try again shortly.'**
  String get apiErrorIdempotencyARequestWithThisIdempotencyKey;

  /// No description provided for @apiErrorIdempotencyIdempotencyKeyIsTooLong200.
  ///
  /// In en, this message translates to:
  /// **'Idempotency-Key is too long (200 characters at most).'**
  String get apiErrorIdempotencyIdempotencyKeyIsTooLong200;

  /// No description provided for @apiErrorIdempotencyPleaseRetryTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Please retry the request.'**
  String get apiErrorIdempotencyPleaseRetryTheRequest;

  /// No description provided for @apiErrorIdempotencyThisIdempotencyKeyWasAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This Idempotency-Key was already used for a different request.'**
  String get apiErrorIdempotencyThisIdempotencyKeyWasAlreadyUsed;

  /// No description provided for @apiErrorImagesAProductCanHavePhotosAt.
  ///
  /// In en, this message translates to:
  /// **'A product can have {max} photos at most.'**
  String apiErrorImagesAProductCanHavePhotosAt(String max);

  /// No description provided for @apiErrorImagesListEveryPhotoOfThisProduct.
  ///
  /// In en, this message translates to:
  /// **'List every photo of this product exactly once.'**
  String get apiErrorImagesListEveryPhotoOfThisProduct;

  /// No description provided for @apiErrorImagesPhotoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Photo not found'**
  String get apiErrorImagesPhotoNotFound;

  /// No description provided for @apiErrorImagesProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get apiErrorImagesProductNotFound;

  /// No description provided for @apiErrorImagesThatVariantDoesNotBelongTo.
  ///
  /// In en, this message translates to:
  /// **'That variant does not belong to this product.'**
  String get apiErrorImagesThatVariantDoesNotBelongTo;

  /// No description provided for @apiErrorImagesTheFileHasNotBeenUploaded.
  ///
  /// In en, this message translates to:
  /// **'The file has not been uploaded yet.'**
  String get apiErrorImagesTheFileHasNotBeenUploaded;

  /// No description provided for @apiErrorImagesTheUploadedFileDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The uploaded file does not match the size that was declared.'**
  String get apiErrorImagesTheUploadedFileDoesNotMatch;

  /// No description provided for @apiErrorImagesTheUploadedFileIsNotA.
  ///
  /// In en, this message translates to:
  /// **'The uploaded file is not a valid JPEG, PNG or WebP photo.'**
  String get apiErrorImagesTheUploadedFileIsNotA;

  /// No description provided for @apiErrorLedgerLedgerEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ledger entry not found'**
  String get apiErrorLedgerLedgerEntryNotFound;

  /// No description provided for @apiErrorLedgerOnlyAdminsAndManagersCanRead.
  ///
  /// In en, this message translates to:
  /// **'Only admins and managers can read vendor ledgers.'**
  String get apiErrorLedgerOnlyAdminsAndManagersCanRead;

  /// No description provided for @apiErrorLedgerThisEntryBelongsToAPurchase.
  ///
  /// In en, this message translates to:
  /// **'This entry belongs to a purchase and cannot be deleted.'**
  String get apiErrorLedgerThisEntryBelongsToAPurchase;

  /// No description provided for @apiErrorLedgerThisEntryBelongsToAnOrder.
  ///
  /// In en, this message translates to:
  /// **'This entry belongs to an order and cannot be deleted.'**
  String get apiErrorLedgerThisEntryBelongsToAnOrder;

  /// No description provided for @apiErrorLedgerThisPartyNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This party no longer exists.'**
  String get apiErrorLedgerThisPartyNoLongerExists;

  /// No description provided for @apiErrorOrdersACancelledOrderCannotTakePayments.
  ///
  /// In en, this message translates to:
  /// **'A cancelled order cannot take payments.'**
  String get apiErrorOrdersACancelledOrderCannotTakePayments;

  /// No description provided for @apiErrorOrdersCannotCancelInStatus.
  ///
  /// In en, this message translates to:
  /// **'A {status} order cannot be cancelled.'**
  String apiErrorOrdersCannotCancelInStatus(String status);

  /// No description provided for @apiErrorOrdersCannotChangeStatusInStatus.
  ///
  /// In en, this message translates to:
  /// **'A {status} order cannot change status.'**
  String apiErrorOrdersCannotChangeStatusInStatus(String status);

  /// No description provided for @apiErrorOrdersAnOrderCannotMoveFromTo.
  ///
  /// In en, this message translates to:
  /// **'An order cannot move from {from} to {to}.'**
  String apiErrorOrdersAnOrderCannotMoveFromTo(String from, String to);

  /// No description provided for @apiErrorOrdersCouldNotGenerateAnOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Could not generate an order number, try again.'**
  String get apiErrorOrdersCouldNotGenerateAnOrderNumber;

  /// No description provided for @apiErrorOrdersItemInactive.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is inactive.'**
  String apiErrorOrdersItemInactive(String name);

  /// No description provided for @apiErrorOrdersOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get apiErrorOrdersOrderNotFound;

  /// No description provided for @apiErrorOrdersOrderNumberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Order number {supplied} already exists.'**
  String apiErrorOrdersOrderNumberAlreadyExists(String supplied);

  /// No description provided for @apiErrorOrdersSendEitherTheAmountPaidOr.
  ///
  /// In en, this message translates to:
  /// **'Send either the amount paid or the payments, not both.'**
  String get apiErrorOrdersSendEitherTheAmountPaidOr;

  /// No description provided for @apiErrorOrdersTheAmountPaidMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'The amount paid must be between 0 and the order total.'**
  String get apiErrorOrdersTheAmountPaidMustBeBetween;

  /// No description provided for @apiErrorOrdersTheDiscountOnMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'The discount on \"{name}\" must be between 0 and the line amount.'**
  String apiErrorOrdersTheDiscountOnMustBeBetween(String name);

  /// No description provided for @apiErrorOrdersTheOrderDiscountMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'The order discount must be between 0 and the order subtotal.'**
  String get apiErrorOrdersTheOrderDiscountMustBeBetween;

  /// No description provided for @apiErrorOrdersThisCustomerIsInactive.
  ///
  /// In en, this message translates to:
  /// **'This customer is inactive.'**
  String get apiErrorOrdersThisCustomerIsInactive;

  /// No description provided for @apiErrorOrdersThisCustomerNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This customer no longer exists.'**
  String get apiErrorOrdersThisCustomerNoLongerExists;

  /// No description provided for @apiErrorOrdersThisOrderAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This order already exists.'**
  String get apiErrorOrdersThisOrderAlreadyExists;

  /// No description provided for @apiErrorOrdersThisOrderWouldTakeOverThe.
  ///
  /// In en, this message translates to:
  /// **'This order would take {name} over the credit limit (limit {limit}, balance after {balance}).'**
  String apiErrorOrdersThisOrderWouldTakeOverThe(
      String name, String limit, String balance);

  /// No description provided for @apiErrorOrdersUseTheCancelActionToCancel.
  ///
  /// In en, this message translates to:
  /// **'Use the cancel action to cancel an order.'**
  String get apiErrorOrdersUseTheCancelActionToCancel;

  /// No description provided for @apiErrorPhotosAPhotoCanBe10Mb.
  ///
  /// In en, this message translates to:
  /// **'A photo can be 10 MB at most.'**
  String get apiErrorPhotosAPhotoCanBe10Mb;

  /// No description provided for @apiErrorPhotosNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get apiErrorPhotosNotFound;

  /// No description provided for @apiErrorPhotosOnlyJpegPngOrWebpPhotos.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG, PNG or WebP photos are accepted.'**
  String get apiErrorPhotosOnlyJpegPngOrWebpPhotos;

  /// No description provided for @apiErrorPhotosPhotosBelongToOneOf.
  ///
  /// In en, this message translates to:
  /// **'Photos belong to one of: {kinds}.'**
  String apiErrorPhotosPhotosBelongToOneOf(String kinds);

  /// No description provided for @apiErrorProductsAVariantIdAlreadyBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'A variant id already belongs to another product.'**
  String get apiErrorProductsAVariantIdAlreadyBelongsTo;

  /// No description provided for @apiErrorProductsAVariantIdIsUsedTwice.
  ///
  /// In en, this message translates to:
  /// **'A variant id is used twice.'**
  String get apiErrorProductsAVariantIdIsUsedTwice;

  /// No description provided for @apiErrorProductsEveryVariantNeedsASku.
  ///
  /// In en, this message translates to:
  /// **'Every variant needs a SKU.'**
  String get apiErrorProductsEveryVariantNeedsASku;

  /// No description provided for @apiErrorProductsVariantHasStockHistory.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has stock history and cannot be removed. Mark it inactive instead.'**
  String apiErrorProductsVariantHasStockHistory(String name);

  /// No description provided for @apiErrorProductsProductNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required.'**
  String get apiErrorProductsProductNameIsRequired;

  /// No description provided for @apiErrorProductsSkuAlreadyBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'SKU \"{sku}\" already belongs to \"{name}\".'**
  String apiErrorProductsSkuAlreadyBelongsTo(String sku, String name);

  /// No description provided for @apiErrorProductsSkuIsUsedTwiceInThis.
  ///
  /// In en, this message translates to:
  /// **'SKU \"{sku}\" is used twice in this product.'**
  String apiErrorProductsSkuIsUsedTwiceInThis(String sku);

  /// No description provided for @apiErrorProductsTheSelectedCategoryNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'The selected category no longer exists.'**
  String get apiErrorProductsTheSelectedCategoryNoLongerExists;

  /// No description provided for @apiErrorProductsDeleteHasStockHistory.
  ///
  /// In en, this message translates to:
  /// **'This product cannot be deleted because it has stock history. Mark it inactive instead.'**
  String get apiErrorProductsDeleteHasStockHistory;

  /// No description provided for @apiErrorPurchasesCouldNotGenerateAPurchaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a purchase number, try again.'**
  String get apiErrorPurchasesCouldNotGenerateAPurchaseNumber;

  /// No description provided for @apiErrorPurchasesItemNoLongerExistsInThe.
  ///
  /// In en, this message translates to:
  /// **'Item {item} no longer exists in the catalog.'**
  String apiErrorPurchasesItemNoLongerExistsInThe(String item);

  /// No description provided for @apiErrorPurchasesPurchaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Purchase not found'**
  String get apiErrorPurchasesPurchaseNotFound;

  /// No description provided for @apiErrorPurchasesPurchaseNumberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Purchase number {supplied} already exists.'**
  String apiErrorPurchasesPurchaseNumberAlreadyExists(String supplied);

  /// No description provided for @apiErrorPurchasesTheAmountPaidMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'The amount paid must be between 0 and the purchase total.'**
  String get apiErrorPurchasesTheAmountPaidMustBeBetween;

  /// No description provided for @apiErrorPurchasesThePaymentIsMoreThanThe.
  ///
  /// In en, this message translates to:
  /// **'The payment is more than the amount due ({due}).'**
  String apiErrorPurchasesThePaymentIsMoreThanThe(String due);

  /// No description provided for @apiErrorPurchasesThisPurchaseAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This purchase already exists.'**
  String get apiErrorPurchasesThisPurchaseAlreadyExists;

  /// No description provided for @apiErrorPurchasesThisVendorIsInactive.
  ///
  /// In en, this message translates to:
  /// **'This vendor is inactive.'**
  String get apiErrorPurchasesThisVendorIsInactive;

  /// No description provided for @apiErrorPurchasesThisVendorNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This vendor no longer exists.'**
  String get apiErrorPurchasesThisVendorNoLongerExists;

  /// No description provided for @apiErrorRequestTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get apiErrorRequestTooManyRequests;

  /// No description provided for @apiErrorRequestValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Some of the values sent are not valid.'**
  String get apiErrorRequestValidationFailed;

  /// No description provided for @apiErrorStarterPacksChooseAtLeastOneGroupTo.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one group to add.'**
  String get apiErrorStarterPacksChooseAtLeastOneGroupTo;

  /// No description provided for @apiErrorStarterPacksNotInThisPack.
  ///
  /// In en, this message translates to:
  /// **'Not in this pack: {names}.'**
  String apiErrorStarterPacksNotInThisPack(String names);

  /// No description provided for @apiErrorStarterPacksThereIsNoSuchStarterPack.
  ///
  /// In en, this message translates to:
  /// **'There is no such starter pack.'**
  String get apiErrorStarterPacksThereIsNoSuchStarterPack;

  /// No description provided for @apiErrorStockNotEnoughStockForOnHand.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for {name}: {quantity} on hand, {needed} needed.'**
  String apiErrorStockNotEnoughStockForOnHand(
      String name, String quantity, String needed);

  /// No description provided for @apiErrorStoreAnAccountWithThisEmailAlready.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in.'**
  String get apiErrorStoreAnAccountWithThisEmailAlready;

  /// No description provided for @apiErrorStoreAnItemInYourCartIs.
  ///
  /// In en, this message translates to:
  /// **'An item in your cart is no longer available. Please review your cart.'**
  String get apiErrorStoreAnItemInYourCartIs;

  /// No description provided for @apiErrorStoreEMailIsOnlySetUp.
  ///
  /// In en, this message translates to:
  /// **'E-mail is only set up for the business that runs the online store.'**
  String get apiErrorStoreEMailIsOnlySetUp;

  /// No description provided for @apiErrorStorePleaseEnterAValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number so we can reach you.'**
  String get apiErrorStorePleaseEnterAValidPhoneNumber;

  /// No description provided for @apiErrorStorePleaseOrderAtMost100Of.
  ///
  /// In en, this message translates to:
  /// **'Please order at most 100 of one item.'**
  String get apiErrorStorePleaseOrderAtMost100Of;

  /// No description provided for @apiErrorStorePleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in.'**
  String get apiErrorStorePleaseSignIn;

  /// No description provided for @apiErrorStorePleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get apiErrorStorePleaseSignInAgain;

  /// No description provided for @apiErrorStoreSorryOneOfYourItemsIs.
  ///
  /// In en, this message translates to:
  /// **'Sorry, one of your items is no longer available in the quantity you chose. Please review your cart.'**
  String get apiErrorStoreSorryOneOfYourItemsIs;

  /// No description provided for @apiErrorStoreTheStoreIsClosedRightNow.
  ///
  /// In en, this message translates to:
  /// **'The store is closed right now. Please come back later.'**
  String get apiErrorStoreTheStoreIsClosedRightNow;

  /// No description provided for @apiErrorStoreTheStoreIsNotTakingOrders.
  ///
  /// In en, this message translates to:
  /// **'The store is not taking orders right now.'**
  String get apiErrorStoreTheStoreIsNotTakingOrders;

  /// No description provided for @apiErrorStoreThisLinkHasExpiredPleaseAsk.
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Please ask for a new one.'**
  String get apiErrorStoreThisLinkHasExpiredPleaseAsk;

  /// No description provided for @apiErrorStoreThisOrderNumberIsAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This order number is already used. Please try again.'**
  String get apiErrorStoreThisOrderNumberIsAlreadyUsed;

  /// No description provided for @apiErrorStoreThisProductIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This product is not available.'**
  String get apiErrorStoreThisProductIsNotAvailable;

  /// No description provided for @apiErrorStoreWeCannotTakeOnlineOrdersFor.
  ///
  /// In en, this message translates to:
  /// **'We cannot take online orders for this phone number. Please call us.'**
  String get apiErrorStoreWeCannotTakeOnlineOrdersFor;

  /// No description provided for @apiErrorStoreWeCouldNotFindThisOrder.
  ///
  /// In en, this message translates to:
  /// **'We could not find this order. Check the link and try again.'**
  String get apiErrorStoreWeCouldNotFindThisOrder;

  /// No description provided for @apiErrorStoreWrongEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get apiErrorStoreWrongEmailOrPassword;

  /// No description provided for @apiErrorUsersAUserWithThisEmailAlready.
  ///
  /// In en, this message translates to:
  /// **'A user with this email already exists'**
  String get apiErrorUsersAUserWithThisEmailAlready;

  /// No description provided for @apiErrorUsersThereMustBeAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'There must be at least one active admin'**
  String get apiErrorUsersThereMustBeAtLeastOne;

  /// No description provided for @apiErrorUsersUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get apiErrorUsersUserNotFound;

  /// No description provided for @apiErrorUsersYouCannotDemoteOrDisableYour.
  ///
  /// In en, this message translates to:
  /// **'You cannot demote or disable your own admin account'**
  String get apiErrorUsersYouCannotDemoteOrDisableYour;

  /// No description provided for @apiErrorVendorsAVendorNamedAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A vendor named \"{name}\" already exists.'**
  String apiErrorVendorsAVendorNamedAlreadyExists(String name);

  /// No description provided for @apiErrorVendorsAVendorWithThisPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'A vendor with this phone number already exists.'**
  String get apiErrorVendorsAVendorWithThisPhoneNumber;

  /// No description provided for @apiErrorVendorsDeleteHasLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'This vendor cannot be deleted because it has ledger entries. Deactivate it instead.'**
  String get apiErrorVendorsDeleteHasLedgerEntries;

  /// No description provided for @apiErrorVendorsDeleteHasOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'This vendor cannot be deleted because it has an opening balance. Deactivate it instead.'**
  String get apiErrorVendorsDeleteHasOpeningBalance;

  /// No description provided for @apiErrorVendorsDeleteHasPurchases.
  ///
  /// In en, this message translates to:
  /// **'This vendor cannot be deleted because it has purchases. Deactivate it instead.'**
  String get apiErrorVendorsDeleteHasPurchases;

  /// No description provided for @apiErrorVendorsVendorNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Vendor name is required.'**
  String get apiErrorVendorsVendorNameIsRequired;

  /// No description provided for @apiErrorVendorsVendorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vendor not found'**
  String get apiErrorVendorsVendorNotFound;

  /// No description provided for @apiErrorStreamTooManyConnections.
  ///
  /// In en, this message translates to:
  /// **'Too many open update streams for this account.'**
  String get apiErrorStreamTooManyConnections;

  /// The bell: its tooltip and the heading of its list.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing new. Online orders and low stock will show here.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'The notifications could not be loaded. They need a connection to the server.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get notificationsRetry;

  /// Button of the pop-up for a new notification: opens what it is about.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get notificationsView;

  /// No description provided for @notificationNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New online order {orderNo}'**
  String notificationNewOrder(String orderNo);

  /// No description provided for @notificationNewOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'{customer} · {total}'**
  String notificationNewOrderDetail(String customer, String total);

  /// No description provided for @notificationLowStock.
  ///
  /// In en, this message translates to:
  /// **'{product} is running low'**
  String notificationLowStock(String product);

  /// No description provided for @notificationLowStockDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 left} other{{count} left}} · alert level {threshold}'**
  String notificationLowStockDetail(int count, int threshold);

  /// No description provided for @notificationOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'{product} is out of stock'**
  String notificationOutOfStock(String product);

  /// No description provided for @notificationOutOfStockDetail.
  ///
  /// In en, this message translates to:
  /// **'Alert level {threshold}'**
  String notificationOutOfStockDetail(int threshold);

  /// Shown for a kind of notification this version of the app does not know.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notificationUnknown;

  /// Settings section: sound and desktop alerts for new notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sound and desktop alerts'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @notifSettingsSound.
  ///
  /// In en, this message translates to:
  /// **'Play a sound'**
  String get notifSettingsSound;

  /// No description provided for @notifSettingsSoundHint.
  ///
  /// In en, this message translates to:
  /// **'A chime for a new online order, a calmer tone for low stock.'**
  String get notifSettingsSoundHint;

  /// No description provided for @notifSettingsSystem.
  ///
  /// In en, this message translates to:
  /// **'Show desktop notifications'**
  String get notifSettingsSystem;

  /// No description provided for @notifSettingsSystemHint.
  ///
  /// In en, this message translates to:
  /// **'When this window is in the background or minimised, a new notification also appears on your screen.'**
  String get notifSettingsSystemHint;

  /// No description provided for @notifSettingsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for this site. Allow them in your browser\'s site settings, then switch this on again.'**
  String get notifSettingsBlocked;

  /// No description provided for @notifSettingsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device cannot show desktop notifications.'**
  String get notifSettingsUnsupported;

  /// No description provided for @notifSettingsTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test'**
  String get notifSettingsTest;

  /// No description provided for @notifSettingsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get notifSettingsTestTitle;

  /// No description provided for @notifSettingsTestBody.
  ///
  /// In en, this message translates to:
  /// **'A new online order will look like this.'**
  String get notifSettingsTestBody;

  /// No description provided for @notifSettingsTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test sent. It shows on your screen when this window is in the background.'**
  String get notifSettingsTestSent;

  /// No description provided for @notifSettingsTestSoundOnly.
  ///
  /// In en, this message translates to:
  /// **'Sound played. Desktop notifications are switched off above.'**
  String get notifSettingsTestSoundOnly;

  /// No description provided for @notifSettingsTestNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Sound played, but notifications are not allowed for this app yet. Switch the option on again to allow them.'**
  String get notifSettingsTestNotAllowed;

  /// No description provided for @apiErrorRegisterTheDayHasNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'This day has not started yet, so it cannot be closed.'**
  String get apiErrorRegisterTheDayHasNotStartedYet;

  /// No description provided for @apiErrorRegisterTheRegisterIsSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'The cash register is switched off for this business. An admin can switch it on in Settings.'**
  String get apiErrorRegisterTheRegisterIsSwitchedOff;

  /// Navigation: the page where the cash is counted at the end of the day.
  ///
  /// In en, this message translates to:
  /// **'Cash register'**
  String get moduleCashRegister;

  /// No description provided for @registerRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get registerRefresh;

  /// No description provided for @registerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get registerCancel;

  /// No description provided for @registerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get registerToday;

  /// No description provided for @registerClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get registerClosed;

  /// No description provided for @registerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get registerOpen;

  /// No description provided for @registerShouldHave.
  ///
  /// In en, this message translates to:
  /// **'Cash that should be in the drawer'**
  String get registerShouldHave;

  /// No description provided for @registerOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening cash'**
  String get registerOpening;

  /// No description provided for @registerOpeningHint.
  ///
  /// In en, this message translates to:
  /// **'The cash that was in the drawer when the day began. Change it if it is not right.'**
  String get registerOpeningHint;

  /// No description provided for @registerFromCustomers.
  ///
  /// In en, this message translates to:
  /// **'Cash from customers'**
  String get registerFromCustomers;

  /// No description provided for @registerToVendors.
  ///
  /// In en, this message translates to:
  /// **'Cash paid to vendors'**
  String get registerToVendors;

  /// No description provided for @registerNotCash.
  ///
  /// In en, this message translates to:
  /// **'Also received, not in cash'**
  String get registerNotCash;

  /// Sales of the day: how many and their total.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sales} =1{1 sale} other{{count} sales}} · {amount}'**
  String registerSalesLine(int count, String amount);

  /// No description provided for @registerCounted.
  ///
  /// In en, this message translates to:
  /// **'Cash counted'**
  String get registerCounted;

  /// No description provided for @registerCountedHint.
  ///
  /// In en, this message translates to:
  /// **'Count the cash in the drawer and type the total.'**
  String get registerCountedHint;

  /// No description provided for @registerNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get registerNote;

  /// No description provided for @registerCloseDay.
  ///
  /// In en, this message translates to:
  /// **'Close the day'**
  String get registerCloseDay;

  /// No description provided for @registerCountAgain.
  ///
  /// In en, this message translates to:
  /// **'Count again'**
  String get registerCountAgain;

  /// No description provided for @registerDayClosed.
  ///
  /// In en, this message translates to:
  /// **'The day is closed.'**
  String get registerDayClosed;

  /// No description provided for @registerBalanced.
  ///
  /// In en, this message translates to:
  /// **'The cash matches'**
  String get registerBalanced;

  /// No description provided for @registerBalancedShort.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get registerBalancedShort;

  /// The counted cash is less than it should be.
  ///
  /// In en, this message translates to:
  /// **'{amount} short'**
  String registerShort(String amount);

  /// The counted cash is more than it should be.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String registerOver(String amount);

  /// No description provided for @registerCountedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} counted'**
  String registerCountedAmount(String amount);

  /// No description provided for @registerClosedBy.
  ///
  /// In en, this message translates to:
  /// **'Closed by {name} on {date}'**
  String registerClosedBy(String name, String date);

  /// Shown while the device still has unsent work; the day cannot be closed meanwhile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 action} other{{count} actions}} on this device not sent to the server yet. Wait for them to sync, so the cash of the day is complete.'**
  String registerUnsent(int count);

  /// No description provided for @registerHistory.
  ///
  /// In en, this message translates to:
  /// **'Days closed before'**
  String get registerHistory;

  /// No description provided for @registerHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No day has been closed yet.'**
  String get registerHistoryEmpty;

  /// Switch in Settings and in the welcome guide.
  ///
  /// In en, this message translates to:
  /// **'I use a cash register'**
  String get registerChoiceTitle;

  /// No description provided for @registerChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Adds a Cash register page where you count the cash at the end of each day and see whether it matches. You can switch it on or off at any time.'**
  String get registerChoiceHint;

  /// No description provided for @onboardingContentCashRegister.
  ///
  /// In en, this message translates to:
  /// **'Do you keep a cash register?'**
  String get onboardingContentCashRegister;

  /// No description provided for @onboardingContentCashRegisterBody.
  ///
  /// In en, this message translates to:
  /// **'If cash goes into a drawer or a cash box, A2 Stocks can help you check it at the end of each day: you count the cash and it tells you if anything is missing.'**
  String get onboardingContentCashRegisterBody;

  /// No description provided for @onboardingContentCashRegisterNoRegister.
  ///
  /// In en, this message translates to:
  /// **'No register? Leave it off. You can switch it on later in Settings > Shop details.'**
  String get onboardingContentCashRegisterNoRegister;

  /// No description provided for @apiErrorReturnsAWalkInCustomerCannotKeepCredit.
  ///
  /// In en, this message translates to:
  /// **'A walk-in customer cannot keep credit: hand back {amount}.'**
  String apiErrorReturnsAWalkInCustomerCannotKeepCredit(String amount);

  /// No description provided for @apiErrorReturnsCouldNotGenerateAReturnNumber.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a return number, try again.'**
  String get apiErrorReturnsCouldNotGenerateAReturnNumber;

  /// No description provided for @apiErrorReturnsOnlyADeliveredOrderCanHave.
  ///
  /// In en, this message translates to:
  /// **'Only a delivered order can have goods returned. Cancel an order that has not been delivered.'**
  String get apiErrorReturnsOnlyADeliveredOrderCanHave;

  /// No description provided for @apiErrorReturnsOnlyCanStillBeReturned.
  ///
  /// In en, this message translates to:
  /// **'Only {max} of {name} can still be returned.'**
  String apiErrorReturnsOnlyCanStillBeReturned(String max, String name);

  /// No description provided for @apiErrorReturnsReturnNotFound.
  ///
  /// In en, this message translates to:
  /// **'Return not found'**
  String get apiErrorReturnsReturnNotFound;

  /// No description provided for @apiErrorReturnsThatItemIsNotOnThisOrder.
  ///
  /// In en, this message translates to:
  /// **'That item is not on this order.'**
  String get apiErrorReturnsThatItemIsNotOnThisOrder;

  /// No description provided for @apiErrorReturnsTheRefundCannotBeMoreThan.
  ///
  /// In en, this message translates to:
  /// **'The money handed back cannot be more than {max}.'**
  String apiErrorReturnsTheRefundCannotBeMoreThan(String max);

  /// Button on a delivered order: goods are coming back.
  ///
  /// In en, this message translates to:
  /// **'Return items'**
  String get returnButton;

  /// No description provided for @returnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return items · {orderNo}'**
  String returnTitle(String orderNo);

  /// No description provided for @returnDone.
  ///
  /// In en, this message translates to:
  /// **'Return {returnNo} recorded.'**
  String returnDone(String returnNo);

  /// No description provided for @returnSold.
  ///
  /// In en, this message translates to:
  /// **'Sold {sold} · returned before {back}'**
  String returnSold(int sold, int back);

  /// No description provided for @returnFullyReturned.
  ///
  /// In en, this message translates to:
  /// **'All of this was returned already.'**
  String get returnFullyReturned;

  /// No description provided for @returnDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged: do not put it back in stock'**
  String get returnDamaged;

  /// No description provided for @returnGoodsValue.
  ///
  /// In en, this message translates to:
  /// **'Value of the goods'**
  String get returnGoodsValue;

  /// No description provided for @returnSettledSoFar.
  ///
  /// In en, this message translates to:
  /// **'Settled so far'**
  String get returnSettledSoFar;

  /// No description provided for @returnLowersDue.
  ///
  /// In en, this message translates to:
  /// **'This lowers what the customer still owes.'**
  String get returnLowersDue;

  /// Heading of the money choice: how much the customer paid beyond what is left of the order.
  ///
  /// In en, this message translates to:
  /// **'{amount} was paid for goods that are coming back'**
  String returnMoneyTitle(String amount);

  /// No description provided for @returnHandBack.
  ///
  /// In en, this message translates to:
  /// **'Hand the money back'**
  String get returnHandBack;

  /// No description provided for @returnKeepCredit.
  ///
  /// In en, this message translates to:
  /// **'Keep it as credit on the customer\'s account'**
  String get returnKeepCredit;

  /// No description provided for @returnWalkInHint.
  ///
  /// In en, this message translates to:
  /// **'A walk-in customer cannot keep credit, so the money is handed back.'**
  String get returnWalkInHint;

  /// No description provided for @returnMethod.
  ///
  /// In en, this message translates to:
  /// **'Paid back by'**
  String get returnMethod;

  /// No description provided for @returnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount handed back'**
  String get returnAmount;

  /// No description provided for @returnUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount}'**
  String returnUpTo(String amount);

  /// No description provided for @returnNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get returnNote;

  /// No description provided for @returnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Return the items'**
  String get returnConfirm;

  /// No description provided for @returnNothingChosen.
  ///
  /// In en, this message translates to:
  /// **'Choose how many units come back'**
  String get returnNothingChosen;

  /// No description provided for @orderDetailReturnedGoods.
  ///
  /// In en, this message translates to:
  /// **'Returned goods'**
  String get orderDetailReturnedGoods;

  /// No description provided for @orderDetailRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get orderDetailRefund;

  /// No description provided for @registerRefunded.
  ///
  /// In en, this message translates to:
  /// **'Cash handed back for returns'**
  String get registerRefunded;

  /// No description provided for @orderDetailReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get orderDetailReturns;

  /// No description provided for @orderDetailReturnUnits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unit} other{{count} units}}'**
  String orderDetailReturnUnits(int count);

  /// No description provided for @orderDetailReturnRefunded.
  ///
  /// In en, this message translates to:
  /// **'{amount} handed back by {method}'**
  String orderDetailReturnRefunded(String amount, String method);

  /// No description provided for @orderDetailReturnCredit.
  ///
  /// In en, this message translates to:
  /// **'Kept as credit on the account'**
  String get orderDetailReturnCredit;

  /// No description provided for @apiErrorExpensesACategoryNamedAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An expense category named \"{name}\" already exists.'**
  String apiErrorExpensesACategoryNamedAlreadyExists(String name);

  /// No description provided for @apiErrorExpensesCategoryNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'The category name is required.'**
  String get apiErrorExpensesCategoryNameIsRequired;

  /// No description provided for @apiErrorExpensesCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense category not found'**
  String get apiErrorExpensesCategoryNotFound;

  /// No description provided for @apiErrorExpensesExpenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found'**
  String get apiErrorExpensesExpenseNotFound;

  /// No description provided for @apiErrorExpensesThisCategoryIsSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'This expense category is switched off. Choose another one.'**
  String get apiErrorExpensesThisCategoryIsSwitchedOff;

  /// No description provided for @apiErrorExpensesThisExpenseWasAlreadyVoided.
  ///
  /// In en, this message translates to:
  /// **'This expense was already voided.'**
  String get apiErrorExpensesThisExpenseWasAlreadyVoided;

  /// Navigation: money spent that is not stock (rent, salaries, electricity...).
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get moduleExpenses;

  /// No description provided for @expensesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesAdd;

  /// No description provided for @expensesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get expensesCancel;

  /// No description provided for @expensesCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get expensesCategories;

  /// No description provided for @expensesPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get expensesPreviousMonth;

  /// No description provided for @expensesNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get expensesNextMonth;

  /// No description provided for @expensesAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expensesAllCategories;

  /// No description provided for @expensesSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get expensesSpent;

  /// No description provided for @expensesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesCountLabel;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get expensesByCategory;

  /// No description provided for @expensesNone.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded for this month yet.'**
  String get expensesNone;

  /// No description provided for @expensesVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get expensesVoid;

  /// No description provided for @expensesVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get expensesVoided;

  /// No description provided for @expensesVoidTitle.
  ///
  /// In en, this message translates to:
  /// **'Void this expense?'**
  String get expensesVoidTitle;

  /// No description provided for @expensesVoidBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} under {category} stays in the list but no longer counts. If it was a mistake, enter it again.'**
  String expensesVoidBody(String amount, String category);

  /// No description provided for @expensesVoidReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get expensesVoidReason;

  /// No description provided for @expensesVoidDone.
  ///
  /// In en, this message translates to:
  /// **'Expense voided.'**
  String get expensesVoidDone;

  /// No description provided for @expensesSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded.'**
  String get expensesSaved;

  /// No description provided for @expenseFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseFormTitle;

  /// No description provided for @expenseFormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseFormCategory;

  /// No description provided for @expenseFormAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseFormAmount;

  /// No description provided for @expenseFormEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get expenseFormEnterAmount;

  /// No description provided for @expenseFormMethod.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expenseFormMethod;

  /// No description provided for @expenseFormReference.
  ///
  /// In en, this message translates to:
  /// **'Transaction number or bank'**
  String get expenseFormReference;

  /// No description provided for @expenseFormPayee.
  ///
  /// In en, this message translates to:
  /// **'Paid to (optional)'**
  String get expenseFormPayee;

  /// No description provided for @expenseFormNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get expenseFormNote;

  /// No description provided for @expenseFormNoCategories.
  ///
  /// In en, this message translates to:
  /// **'There are no expense categories yet. Add some first (Rent, Salaries, Electricity...) with the categories button.'**
  String get expenseFormNoCategories;

  /// No description provided for @expenseFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get expenseFormSave;

  /// No description provided for @expenseCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get expenseCatTitle;

  /// No description provided for @expenseCatNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get expenseCatNew;

  /// No description provided for @expenseCatAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get expenseCatAdd;

  /// No description provided for @expenseCatAddCommon.
  ///
  /// In en, this message translates to:
  /// **'Add the usual ones'**
  String get expenseCatAddCommon;

  /// No description provided for @expenseCatRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get expenseCatRename;

  /// No description provided for @expenseCatSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get expenseCatSave;

  /// No description provided for @expenseCatDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get expenseCatDone;

  /// No description provided for @expenseCatCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No expenses} =1{1 expense} other{{count} expenses}}'**
  String expenseCatCount(int count);

  /// No description provided for @expenseCatCommonAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All the usual categories are already there.} =1{1 category added.} other{{count} categories added.}}'**
  String expenseCatCommonAdded(int count);

  /// No description provided for @expenseCommonRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCommonRent;

  /// No description provided for @expenseCommonSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get expenseCommonSalaries;

  /// No description provided for @expenseCommonElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get expenseCommonElectricity;

  /// No description provided for @expenseCommonWaterGas.
  ///
  /// In en, this message translates to:
  /// **'Water and gas'**
  String get expenseCommonWaterGas;

  /// No description provided for @expenseCommonInternetPhone.
  ///
  /// In en, this message translates to:
  /// **'Internet and phone'**
  String get expenseCommonInternetPhone;

  /// No description provided for @expenseCommonTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport and fuel'**
  String get expenseCommonTransport;

  /// No description provided for @expenseCommonRepairs.
  ///
  /// In en, this message translates to:
  /// **'Repairs and maintenance'**
  String get expenseCommonRepairs;

  /// No description provided for @expenseCommonPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get expenseCommonPackaging;

  /// No description provided for @expenseCommonMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get expenseCommonMarketing;

  /// No description provided for @expenseCommonTeaFood.
  ///
  /// In en, this message translates to:
  /// **'Tea and food'**
  String get expenseCommonTeaFood;

  /// No description provided for @expenseCommonTaxesFees.
  ///
  /// In en, this message translates to:
  /// **'Taxes and fees'**
  String get expenseCommonTaxesFees;

  /// No description provided for @expenseCommonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCommonOther;

  /// No description provided for @registerSpent.
  ///
  /// In en, this message translates to:
  /// **'Cash spent on expenses'**
  String get registerSpent;

  /// No description provided for @dashboardExpensesMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month ({amount} today)'**
  String dashboardExpensesMonth(String amount);

  /// No description provided for @dashboardEstimatedProfit.
  ///
  /// In en, this message translates to:
  /// **'Estimated profit this month (sales less cost of goods and expenses)'**
  String get dashboardEstimatedProfit;

  /// Navigation: sales, profit, stock and debts for the owner.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get moduleReports;

  /// No description provided for @reportKindSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get reportKindSales;

  /// No description provided for @reportKindProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reportKindProfit;

  /// No description provided for @reportKindStock.
  ///
  /// In en, this message translates to:
  /// **'Stock that does not sell'**
  String get reportKindStock;

  /// No description provided for @reportKindReceivables.
  ///
  /// In en, this message translates to:
  /// **'Customers who owe'**
  String get reportKindReceivables;

  /// No description provided for @reportKindPayables.
  ///
  /// In en, this message translates to:
  /// **'Vendors owed'**
  String get reportKindPayables;

  /// No description provided for @reportRangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportRangeToday;

  /// No description provided for @reportRangeLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get reportRangeLast7;

  /// No description provided for @reportRangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get reportRangeThisMonth;

  /// No description provided for @reportRangeLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get reportRangeLastMonth;

  /// No description provided for @reportRangeThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get reportRangeThisYear;

  /// No description provided for @reportRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick days'**
  String get reportRangeCustom;

  /// No description provided for @reportExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Save as CSV (for a spreadsheet)'**
  String get reportExportCsv;

  /// No description provided for @reportExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get reportExportPdf;

  /// No description provided for @reportSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Save the report'**
  String get reportSaveAs;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved.'**
  String get reportSaved;

  /// No description provided for @reportNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show for this report.'**
  String get reportNothing;

  /// No description provided for @reportDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String reportDays(int count);

  /// No description provided for @reportTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportTotal;

  /// No description provided for @reportOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'Online store'**
  String get reportOnlineStore;

  /// No description provided for @reportNeverSold.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get reportNeverSold;

  /// No description provided for @reportSalesByProduct.
  ///
  /// In en, this message translates to:
  /// **'Sales by product'**
  String get reportSalesByProduct;

  /// No description provided for @reportSalesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Sales by category'**
  String get reportSalesByCategory;

  /// No description provided for @reportSalesByCustomer.
  ///
  /// In en, this message translates to:
  /// **'Sales by customer'**
  String get reportSalesByCustomer;

  /// No description provided for @reportSalesByCashier.
  ///
  /// In en, this message translates to:
  /// **'Sales by cashier'**
  String get reportSalesByCashier;

  /// No description provided for @reportColProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get reportColProduct;

  /// No description provided for @reportColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportColCategory;

  /// No description provided for @reportColCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get reportColCustomer;

  /// No description provided for @reportColVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get reportColVendor;

  /// No description provided for @reportColCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get reportColCashier;

  /// No description provided for @reportColUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get reportColUnits;

  /// No description provided for @reportColOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get reportColOrders;

  /// No description provided for @reportColRevenue.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get reportColRevenue;

  /// No description provided for @reportColReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get reportColReturned;

  /// No description provided for @reportColCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get reportColCost;

  /// No description provided for @reportColProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reportColProfit;

  /// No description provided for @reportColMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get reportColMargin;

  /// No description provided for @reportColExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportColExpenses;

  /// No description provided for @reportColDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get reportColDay;

  /// No description provided for @reportColSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get reportColSku;

  /// No description provided for @reportColOnHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get reportColOnHand;

  /// No description provided for @reportColStockValue.
  ///
  /// In en, this message translates to:
  /// **'Value at cost'**
  String get reportColStockValue;

  /// No description provided for @reportColSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get reportColSold;

  /// No description provided for @reportColLastSold.
  ///
  /// In en, this message translates to:
  /// **'Last sold'**
  String get reportColLastSold;

  /// No description provided for @reportColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportColStatus;

  /// No description provided for @reportColPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get reportColPhone;

  /// No description provided for @reportColBalance.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get reportColBalance;

  /// No description provided for @reportColAge030.
  ///
  /// In en, this message translates to:
  /// **'0-30 days'**
  String get reportColAge030;

  /// No description provided for @reportColAge3160.
  ///
  /// In en, this message translates to:
  /// **'31-60 days'**
  String get reportColAge3160;

  /// No description provided for @reportColAge6190.
  ///
  /// In en, this message translates to:
  /// **'61-90 days'**
  String get reportColAge6190;

  /// No description provided for @reportColAge90.
  ///
  /// In en, this message translates to:
  /// **'Over 90 days'**
  String get reportColAge90;

  /// No description provided for @reportColOldestDays.
  ///
  /// In en, this message translates to:
  /// **'Oldest (days)'**
  String get reportColOldestDays;

  /// No description provided for @reportProfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Profit and margin'**
  String get reportProfitTitle;

  /// No description provided for @reportProfitRevenue.
  ///
  /// In en, this message translates to:
  /// **'Sales after discounts'**
  String get reportProfitRevenue;

  /// No description provided for @reportProfitReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned by customers'**
  String get reportProfitReturned;

  /// No description provided for @reportProfitNetRevenue.
  ///
  /// In en, this message translates to:
  /// **'Net sales'**
  String get reportProfitNetRevenue;

  /// No description provided for @reportProfitCost.
  ///
  /// In en, this message translates to:
  /// **'Cost of the goods sold'**
  String get reportProfitCost;

  /// No description provided for @reportProfitGross.
  ///
  /// In en, this message translates to:
  /// **'Gross profit'**
  String get reportProfitGross;

  /// No description provided for @reportProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross margin'**
  String get reportProfitMargin;

  /// No description provided for @reportProfitExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportProfitExpenses;

  /// No description provided for @reportProfitNet.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get reportProfitNet;

  /// No description provided for @reportProfitShipping.
  ///
  /// In en, this message translates to:
  /// **'Delivery fees charged (not in the profit)'**
  String get reportProfitShipping;

  /// No description provided for @reportStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock that does not sell'**
  String get reportStockTitle;

  /// No description provided for @reportStockWindow.
  ///
  /// In en, this message translates to:
  /// **'Looking at the last {days} days'**
  String reportStockWindow(int days);

  /// No description provided for @reportStockDeadLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} with no sale (money tied up)'**
  String reportStockDeadLine(int count);

  /// No description provided for @reportStockSlowLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} selling slowly (money tied up)'**
  String reportStockSlowLine(int count);

  /// No description provided for @reportStockDead.
  ///
  /// In en, this message translates to:
  /// **'No sales'**
  String get reportStockDead;

  /// No description provided for @reportStockSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get reportStockSlow;

  /// No description provided for @reportStockNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get reportStockNew;

  /// No description provided for @reportStockOk.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get reportStockOk;

  /// No description provided for @reportReceivablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers who owe money'**
  String get reportReceivablesTitle;

  /// No description provided for @reportPayablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vendors who are owed money'**
  String get reportPayablesTitle;

  /// No description provided for @apiErrorReportsTheFirstDayIsAfterTheLastDay.
  ///
  /// In en, this message translates to:
  /// **'The first day is after the last day.'**
  String get apiErrorReportsTheFirstDayIsAfterTheLastDay;

  /// Goods and services tax: the name on receipts.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get taxNameGst;

  /// Value added tax: the name on receipts.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get taxNameVat;

  /// A tax line: the tax added on top of the price.
  ///
  /// In en, this message translates to:
  /// **'{name} {rate}%'**
  String taxLine(String name, String rate);

  /// A tax line: the price already contains this tax.
  ///
  /// In en, this message translates to:
  /// **'Includes {name} {rate}%'**
  String taxLineIncluded(String name, String rate);

  /// No description provided for @receiptTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax no. {number}'**
  String receiptTaxNumber(String number);

  /// No description provided for @taxSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxSettingsTitle;

  /// No description provided for @taxSettingsSwitch.
  ///
  /// In en, this message translates to:
  /// **'Charge tax on sales'**
  String get taxSettingsSwitch;

  /// No description provided for @taxSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'GST and VAT are charged on the goods after discounts, never on the delivery fee. If you charge both, both apply to the same price. Leave a rate at 0 if you do not charge it.'**
  String get taxSettingsHint;

  /// No description provided for @taxGstRate.
  ///
  /// In en, this message translates to:
  /// **'GST rate (%)'**
  String get taxGstRate;

  /// No description provided for @taxVatRate.
  ///
  /// In en, this message translates to:
  /// **'VAT rate (%)'**
  String get taxVatRate;

  /// No description provided for @taxIncludesTitle.
  ///
  /// In en, this message translates to:
  /// **'Do your shelf prices already include tax?'**
  String get taxIncludesTitle;

  /// No description provided for @taxIncludesYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, the tax is inside the price'**
  String get taxIncludesYes;

  /// No description provided for @taxIncludesNo.
  ///
  /// In en, this message translates to:
  /// **'No, add the tax on top'**
  String get taxIncludesNo;

  /// No description provided for @taxNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax registration number (printed on receipts)'**
  String get taxNumberLabel;

  /// No description provided for @taxSave.
  ///
  /// In en, this message translates to:
  /// **'Save tax settings'**
  String get taxSave;

  /// No description provided for @taxSaved.
  ///
  /// In en, this message translates to:
  /// **'Tax settings saved.'**
  String get taxSaved;

  /// No description provided for @taxNeedsRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a GST or VAT rate above 0.'**
  String get taxNeedsRate;

  /// No description provided for @taxRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'A rate is a number from 0 to 100.'**
  String get taxRateInvalid;

  /// No description provided for @taxAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Only an admin can change the tax settings.'**
  String get taxAdminOnly;

  /// No description provided for @reportKindTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get reportKindTax;

  /// No description provided for @reportTaxTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax summary'**
  String get reportTaxTitle;

  /// No description provided for @reportColTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get reportColTax;

  /// No description provided for @reportColCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected on sales'**
  String get reportColCollected;

  /// No description provided for @reportColGivenBack.
  ///
  /// In en, this message translates to:
  /// **'Given back on returns'**
  String get reportColGivenBack;

  /// No description provided for @reportColTaxOwed.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get reportColTaxOwed;

  /// No description provided for @reportTaxSalesWithoutTax.
  ///
  /// In en, this message translates to:
  /// **'Sales before tax (orders that carried tax)'**
  String get reportTaxSalesWithoutTax;

  /// No description provided for @reportTaxOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders with tax'**
  String get reportTaxOrders;

  /// No description provided for @reportTaxReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns with tax'**
  String get reportTaxReturns;

  /// No description provided for @returnTaxGivenBack.
  ///
  /// In en, this message translates to:
  /// **'Tax on these goods (given back too)'**
  String get returnTaxGivenBack;

  /// No description provided for @returnTaxIncluded.
  ///
  /// In en, this message translates to:
  /// **'Tax inside these prices'**
  String get returnTaxIncluded;

  /// Navigation: what was ordered from vendors and what has arrived.
  ///
  /// In en, this message translates to:
  /// **'Purchase orders'**
  String get modulePurchaseOrders;

  /// No description provided for @poStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get poStatusOpen;

  /// No description provided for @poStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly received'**
  String get poStatusPartial;

  /// No description provided for @poStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get poStatusReceived;

  /// No description provided for @poStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get poStatusClosed;

  /// No description provided for @poStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get poStatusCancelled;

  /// No description provided for @poFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get poFilterAll;

  /// No description provided for @poNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get poNewOrder;

  /// No description provided for @poSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order number or vendor'**
  String get poSearchHint;

  /// No description provided for @poNone.
  ///
  /// In en, this message translates to:
  /// **'No purchase orders yet.'**
  String get poNone;

  /// No description provided for @poReceivedOfUnits.
  ///
  /// In en, this message translates to:
  /// **'{received} of {ordered} units received'**
  String poReceivedOfUnits(int received, int ordered);

  /// No description provided for @poExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected {date}'**
  String poExpected(String date);

  /// No description provided for @poExpectedLate.
  ///
  /// In en, this message translates to:
  /// **'Expected {date}: late'**
  String poExpectedLate(String date);

  /// No description provided for @poCreated.
  ///
  /// In en, this message translates to:
  /// **'Purchase order {number} created.'**
  String poCreated(String number);

  /// No description provided for @poFormHint.
  ///
  /// In en, this message translates to:
  /// **'An order only records what you asked the vendor for. Stock and what you owe change when the goods arrive.'**
  String get poFormHint;

  /// No description provided for @poChooseVendor.
  ///
  /// In en, this message translates to:
  /// **'Choose a vendor'**
  String get poChooseVendor;

  /// No description provided for @poExpectedOptional.
  ///
  /// In en, this message translates to:
  /// **'When do you expect it? (optional)'**
  String get poExpectedOptional;

  /// No description provided for @poItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get poItems;

  /// No description provided for @poAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get poAddItem;

  /// No description provided for @poNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'Add what you want to order.'**
  String get poNoItemsYet;

  /// No description provided for @poRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get poRemoveItem;

  /// No description provided for @poQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get poQuantity;

  /// No description provided for @poUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get poUnitCost;

  /// No description provided for @poNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get poNote;

  /// No description provided for @poOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order total: {amount}'**
  String poOrderTotal(String amount);

  /// No description provided for @poPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get poPlaceOrder;

  /// No description provided for @poOrderedValue.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get poOrderedValue;

  /// No description provided for @poReceivedValue.
  ///
  /// In en, this message translates to:
  /// **'Received so far'**
  String get poReceivedValue;

  /// No description provided for @poReceiveGoods.
  ///
  /// In en, this message translates to:
  /// **'Receive goods'**
  String get poReceiveGoods;

  /// No description provided for @poConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get poConfirm;

  /// No description provided for @poCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get poCancelOrder;

  /// No description provided for @poCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order? Nothing has arrived for it.'**
  String get poCancelConfirm;

  /// No description provided for @poCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get poCancelled;

  /// No description provided for @poCloseOrder.
  ///
  /// In en, this message translates to:
  /// **'Close order'**
  String get poCloseOrder;

  /// No description provided for @poCloseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close this order? What has not arrived will not be received on it.'**
  String get poCloseConfirm;

  /// No description provided for @poClosed.
  ///
  /// In en, this message translates to:
  /// **'Order closed.'**
  String get poClosed;

  /// No description provided for @poLineProgress.
  ///
  /// In en, this message translates to:
  /// **'{received} of {ordered} received at {price}'**
  String poLineProgress(int received, int ordered, String price);

  /// No description provided for @poStillToCome.
  ///
  /// In en, this message translates to:
  /// **'{count} still to come'**
  String poStillToCome(int count);

  /// No description provided for @poReceipts.
  ///
  /// In en, this message translates to:
  /// **'Goods received'**
  String get poReceipts;

  /// No description provided for @poReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive goods · {number}'**
  String poReceiveTitle(String number);

  /// No description provided for @poReceiveHint.
  ///
  /// In en, this message translates to:
  /// **'Say how many of each item arrived from {vendor}. Stock goes up and what you owe the vendor goes up by the same step.'**
  String poReceiveHint(String vendor);

  /// No description provided for @poArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get poArrived;

  /// No description provided for @poMostIs.
  ///
  /// In en, this message translates to:
  /// **'At most {count}'**
  String poMostIs(int count);

  /// No description provided for @poInvoicePrice.
  ///
  /// In en, this message translates to:
  /// **'Price on the invoice'**
  String get poInvoicePrice;

  /// No description provided for @poInvoiceNo.
  ///
  /// In en, this message translates to:
  /// **'Invoice number (optional)'**
  String get poInvoiceNo;

  /// No description provided for @poPaidNow.
  ///
  /// In en, this message translates to:
  /// **'Paid to the vendor now (optional)'**
  String get poPaidNow;

  /// No description provided for @poPaidNowHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to pay later.'**
  String get poPaidNowHint;

  /// No description provided for @poPaidTooMuch.
  ///
  /// In en, this message translates to:
  /// **'More than the {total} that arrived'**
  String poPaidTooMuch(String total);

  /// No description provided for @poReceivingValue.
  ///
  /// In en, this message translates to:
  /// **'Receiving: {amount}'**
  String poReceivingValue(String amount);

  /// No description provided for @poReceivedDone.
  ///
  /// In en, this message translates to:
  /// **'Goods received.'**
  String get poReceivedDone;

  /// No description provided for @apiErrorBusinessTaxNeedsARate.
  ///
  /// In en, this message translates to:
  /// **'To charge tax, set a GST rate or a VAT rate above 0.'**
  String get apiErrorBusinessTaxNeedsARate;

  /// No description provided for @apiErrorPurchaseOrdersCouldNotGenerateAnOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Could not generate an order number, try again.'**
  String get apiErrorPurchaseOrdersCouldNotGenerateAnOrderNumber;

  /// No description provided for @apiErrorPurchaseOrdersOnlyAPartlyReceivedOrderCanBeClosed.
  ///
  /// In en, this message translates to:
  /// **'Only a partly received order can be closed.'**
  String get apiErrorPurchaseOrdersOnlyAPartlyReceivedOrderCanBeClosed;

  /// No description provided for @apiErrorPurchaseOrdersOnlyAnOpenOrderCanBeReceived.
  ///
  /// In en, this message translates to:
  /// **'Goods can only be received against an order that is open or partly received.'**
  String get apiErrorPurchaseOrdersOnlyAnOpenOrderCanBeReceived;

  /// No description provided for @apiErrorPurchaseOrdersOnlyAnOrderNothingArrivedForCanBeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Only an order that nothing has arrived for can be cancelled. Close it instead.'**
  String get apiErrorPurchaseOrdersOnlyAnOrderNothingArrivedForCanBeCancelled;

  /// No description provided for @apiErrorPurchaseOrdersOnlyCanStillBeReceived.
  ///
  /// In en, this message translates to:
  /// **'Only {max} of {name} can still be received on this order.'**
  String apiErrorPurchaseOrdersOnlyCanStillBeReceived(String max, String name);

  /// No description provided for @apiErrorPurchaseOrdersPurchaseOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Purchase order not found'**
  String get apiErrorPurchaseOrdersPurchaseOrderNotFound;

  /// No description provided for @apiErrorPurchaseOrdersThatLineIsNotOnThisOrder.
  ///
  /// In en, this message translates to:
  /// **'That line is not on this order.'**
  String get apiErrorPurchaseOrdersThatLineIsNotOnThisOrder;

  /// No description provided for @apiErrorPurchaseOrdersThisOrderAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This purchase order already exists.'**
  String get apiErrorPurchaseOrdersThisOrderAlreadyExists;

  /// Navigation: what to order from vendors, worked out from stock and sales.
  ///
  /// In en, this message translates to:
  /// **'Reorder suggestions'**
  String get moduleReorder;

  /// No description provided for @reorderLookBack.
  ///
  /// In en, this message translates to:
  /// **'Sales looked at:'**
  String get reorderLookBack;

  /// No description provided for @reorderCover.
  ///
  /// In en, this message translates to:
  /// **'Order enough for:'**
  String get reorderCover;

  /// No description provided for @reorderNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs ordering right now.'**
  String get reorderNone;

  /// No description provided for @reorderReasonOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get reorderReasonOut;

  /// No description provided for @reorderReasonLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reorderReasonLow;

  /// No description provided for @reorderReasonRunning.
  ///
  /// In en, this message translates to:
  /// **'Running out'**
  String get reorderReasonRunning;

  /// No description provided for @reorderLine.
  ///
  /// In en, this message translates to:
  /// **'On hand {onHand} · on order {onOrder}'**
  String reorderLine(int onHand, int onOrder);

  /// No description provided for @reorderSpeed.
  ///
  /// In en, this message translates to:
  /// **'Sells {perDay} a day, about {days} days left'**
  String reorderSpeed(String perDay, String days);

  /// No description provided for @reorderNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period'**
  String get reorderNoSales;

  /// No description provided for @reorderNoVendor.
  ///
  /// In en, this message translates to:
  /// **'No vendor yet'**
  String get reorderNoVendor;

  /// No description provided for @reorderNoVendorHint.
  ///
  /// In en, this message translates to:
  /// **'These were never bought from an active vendor. Choose one to order them.'**
  String get reorderNoVendorHint;

  /// No description provided for @reorderChooseVendor.
  ///
  /// In en, this message translates to:
  /// **'Choose vendor'**
  String get reorderChooseVendor;

  /// No description provided for @reorderCreate.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get reorderCreate;

  /// No description provided for @reorderGroupTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {amount}'**
  String reorderGroupTotal(int count, String amount);

  /// No description provided for @reorderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order {number} created. Nothing changes in stock until the goods arrive.'**
  String reorderCreated(String number);

  /// No description provided for @reorderOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get reorderOpen;

  /// No description provided for @reorderNote.
  ///
  /// In en, this message translates to:
  /// **'From reorder suggestions'**
  String get reorderNote;

  /// No description provided for @poSendToVendor.
  ///
  /// In en, this message translates to:
  /// **'Send to vendor'**
  String get poSendToVendor;

  /// No description provided for @poSendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get poSendWhatsApp;

  /// No description provided for @poSendWhatsAppHint.
  ///
  /// In en, this message translates to:
  /// **'Opens a chat with the order written out; you press send.'**
  String get poSendWhatsAppHint;

  /// No description provided for @poSendSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get poSendSharePdf;

  /// No description provided for @poSendPrintPdf.
  ///
  /// In en, this message translates to:
  /// **'Print or save PDF'**
  String get poSendPrintPdf;

  /// No description provided for @poSendVendorPhone.
  ///
  /// In en, this message translates to:
  /// **'Vendor phone'**
  String get poSendVendorPhone;

  /// No description provided for @poMsgTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase order {number}'**
  String poMsgTitle(String number);

  /// No description provided for @poMsgTo.
  ///
  /// In en, this message translates to:
  /// **'To: {vendor}'**
  String poMsgTo(String vendor);

  /// No description provided for @poMsgDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String poMsgDate(String date);

  /// No description provided for @poMsgExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected by: {date}'**
  String poMsgExpected(String date);

  /// On a partly received order only what has not arrived is listed.
  ///
  /// In en, this message translates to:
  /// **'Still to be delivered:'**
  String get poMsgStillToCome;

  /// No description provided for @poMsgLine.
  ///
  /// In en, this message translates to:
  /// **'{quantity} x {name} @ {price} = {total}'**
  String poMsgLine(int quantity, String name, String price, String total);

  /// No description provided for @poMsgTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String poMsgTotal(String amount);

  /// No description provided for @poMsgNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String poMsgNote(String note);

  /// No description provided for @poMsgClosing.
  ///
  /// In en, this message translates to:
  /// **'Please confirm availability and the delivery date. Thank you.'**
  String get poMsgClosing;

  /// No description provided for @poPdfVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get poPdfVendor;

  /// No description provided for @poPdfDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get poPdfDate;

  /// No description provided for @poPdfExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected by'**
  String get poPdfExpected;

  /// No description provided for @poPdfNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get poPdfNote;

  /// Switch in Settings and in the welcome guide: off means a barcode is optional on every item.
  ///
  /// In en, this message translates to:
  /// **'Barcodes are required'**
  String get barcodeRequiredTitle;

  /// No description provided for @barcodeRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Off: a barcode is optional. On: every new item needs one (items you already have are not affected). You can switch it any time.'**
  String get barcodeRequiredHint;

  /// No description provided for @variantBarcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get variantBarcodeRequired;

  /// No description provided for @variantBarcodeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a barcode'**
  String get variantBarcodeCreate;

  /// No description provided for @variantBarcodeNeeded.
  ///
  /// In en, this message translates to:
  /// **'A barcode is required. Scan one, type it, or press the wand to create one.'**
  String get variantBarcodeNeeded;

  /// No description provided for @variantBarcodeUsed.
  ///
  /// In en, this message translates to:
  /// **'Another item already has this barcode.'**
  String get variantBarcodeUsed;

  /// No description provided for @catalogBarcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'A barcode is required for {sku}.'**
  String catalogBarcodeRequired(String sku);

  /// No description provided for @catalogBarcodeTwice.
  ///
  /// In en, this message translates to:
  /// **'The barcode {barcode} is used twice in this product.'**
  String catalogBarcodeTwice(String barcode);

  /// No description provided for @catalogBarcodeBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'The barcode {barcode} already belongs to {name}.'**
  String catalogBarcodeBelongsTo(String barcode, String name);

  /// No description provided for @onboardingContentBarcodes.
  ///
  /// In en, this message translates to:
  /// **'Do you use barcodes?'**
  String get onboardingContentBarcodes;

  /// No description provided for @onboardingContentBarcodesBody.
  ///
  /// In en, this message translates to:
  /// **'A barcode lets you ring up an item by scanning it, and lets you print price labels. It is optional by default: you can add one to any item when you like. Switch this on only if every item must have one.'**
  String get onboardingContentBarcodesBody;

  /// No description provided for @onboardingContentBarcodesLabels.
  ///
  /// In en, this message translates to:
  /// **'You can print labels for any item, with its barcode or its SKU, from the Labels page.'**
  String get onboardingContentBarcodesLabels;

  /// No description provided for @apiErrorProductsABarcodeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'A barcode is required for {sku}.'**
  String apiErrorProductsABarcodeIsRequired(String sku);

  /// No description provided for @apiErrorProductsBarcodeAlreadyBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'The barcode {barcode} already belongs to {name} ({sku}).'**
  String apiErrorProductsBarcodeAlreadyBelongsTo(
      String barcode, String name, String sku);

  /// No description provided for @apiErrorProductsBarcodeIsUsedTwiceInThis.
  ///
  /// In en, this message translates to:
  /// **'The barcode {barcode} is used twice in this product.'**
  String apiErrorProductsBarcodeIsUsedTwiceInThis(String barcode);

  /// Navigation: print price and barcode labels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get moduleLabels;

  /// No description provided for @labelsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, SKU or barcode'**
  String get labelsSearch;

  /// No description provided for @labelsSize.
  ///
  /// In en, this message translates to:
  /// **'Label size'**
  String get labelsSize;

  /// No description provided for @labelsSizeRoll.
  ///
  /// In en, this message translates to:
  /// **'Label roll {size} mm'**
  String labelsSizeRoll(String size);

  /// No description provided for @labelsSizeSheet.
  ///
  /// In en, this message translates to:
  /// **'A4 sheet of {count} labels ({grid})'**
  String labelsSizeSheet(int count, String grid);

  /// No description provided for @labelsSkip.
  ///
  /// In en, this message translates to:
  /// **'Places already used'**
  String get labelsSkip;

  /// No description provided for @labelsShowName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelsShowName;

  /// No description provided for @labelsShowPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelsShowPrice;

  /// No description provided for @labelsShowSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get labelsShowSku;

  /// No description provided for @labelsUseSku.
  ///
  /// In en, this message translates to:
  /// **'SKU as the bar code when there is no barcode'**
  String get labelsUseSku;

  /// No description provided for @labelsCopies.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsCopies;

  /// No description provided for @labelsOneEach.
  ///
  /// In en, this message translates to:
  /// **'1 each'**
  String get labelsOneEach;

  /// No description provided for @labelsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get labelsClear;

  /// No description provided for @labelsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items to show.'**
  String get labelsNoItems;

  /// No description provided for @labelsNothing.
  ///
  /// In en, this message translates to:
  /// **'Choose how many labels each item needs.'**
  String get labelsNothing;

  /// No description provided for @labelsSummary.
  ///
  /// In en, this message translates to:
  /// **'{labels} labels, {pages} pages'**
  String labelsSummary(int labels, int pages);

  /// No description provided for @labelsPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get labelsPrint;

  /// No description provided for @labelsShare.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get labelsShare;

  /// No description provided for @labelsSkuCode.
  ///
  /// In en, this message translates to:
  /// **'SKU as the bar code'**
  String get labelsSkuCode;

  /// No description provided for @labelsNoCode.
  ///
  /// In en, this message translates to:
  /// **'No bar code'**
  String get labelsNoCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
