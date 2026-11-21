import 'package:a2_stocks/l10n/l10n.dart';

// GENERATED from the API's src/common/error-codes.ts (docs/error_codes.md): one
// case per error code. Regenerate when the API adds a code; an unknown code
// simply shows the server's own English message.

/// The text of an API error in the language of the app, or null for a code this
/// version of the app does not know (show the server's `message` then).
String? apiErrorText(AppLocalizations l10n, String code, Map<String, Object?> params) {
  switch (code) {
    case 'audits.a_counted_item_no_longer_exists':
      return l10n.apiErrorAuditsACountedItemNoLongerExists;
    case 'audits.audit_number_already_exists':
      return l10n.apiErrorAuditsAuditNumberAlreadyExists(_text(params, 'supplied'));
    case 'audits.could_not_generate_an_audit_number':
      return l10n.apiErrorAuditsCouldNotGenerateAnAuditNumber;
    case 'audits.every_counted_quantity_matches_the_system':
      return l10n.apiErrorAuditsEveryCountedQuantityMatchesTheSystem;
    case 'audits.stock_audit_not_found':
      return l10n.apiErrorAuditsStockAuditNotFound;
    case 'audits.the_same_item_was_counted_twice':
      return l10n.apiErrorAuditsTheSameItemWasCountedTwice;
    case 'audits.this_stock_audit_already_exists':
      return l10n.apiErrorAuditsThisStockAuditAlreadyExists;
    case 'auth.account_disabled':
      return l10n.apiErrorAuthAccountDisabled;
    case 'auth.account_disabled_token':
      return l10n.apiErrorAuthAccountDisabledToken;
    case 'auth.invalid_email_or_password':
      return l10n.apiErrorAuthInvalidEmailOrPassword;
    case 'auth.invalid_or_expired_access_token':
      return l10n.apiErrorAuthInvalidOrExpiredAccessToken;
    case 'auth.invalid_refresh_token':
      return l10n.apiErrorAuthInvalidRefreshToken;
    case 'auth.missing_access_token':
      return l10n.apiErrorAuthMissingAccessToken;
    case 'auth.refresh_token_expired':
      return l10n.apiErrorAuthRefreshTokenExpired;
    case 'auth.refresh_token_was_already_used':
      return l10n.apiErrorAuthRefreshTokenWasAlreadyUsed;
    case 'auth.you_do_not_have_permission_for':
      return l10n.apiErrorAuthYouDoNotHavePermissionFor;
    case 'business.tax_needs_a_rate':
      return l10n.apiErrorBusinessTaxNeedsARate;
    case 'categories.a_category_cannot_be_placed_inside':
      return l10n.apiErrorCategoriesACategoryCannotBePlacedInside;
    case 'categories.a_category_named_already_exists_here':
      return l10n.apiErrorCategoriesACategoryNamedAlreadyExistsHere(_text(params, 'name'));
    case 'categories.category_name_is_required':
      return l10n.apiErrorCategoriesCategoryNameIsRequired;
    case 'categories.category_not_found':
      return l10n.apiErrorCategoriesCategoryNotFound;
    case 'categories.the_selected_parent_category_no_longer':
      return l10n.apiErrorCategoriesTheSelectedParentCategoryNoLonger;
    case 'categories.delete_has_subcategories':
      return l10n.apiErrorCategoriesDeleteHasSubcategories;
    case 'categories.delete_used_by_products':
      return l10n.apiErrorCategoriesDeleteUsedByProducts(_int(params, 'count'));
    case 'customers.a_customer_with_this_phone_number':
      return l10n.apiErrorCustomersACustomerWithThisPhoneNumber;
    case 'customers.customer_name_is_required':
      return l10n.apiErrorCustomersCustomerNameIsRequired;
    case 'customers.customer_not_found':
      return l10n.apiErrorCustomersCustomerNotFound;
    case 'customers.delete_has_ledger_entries':
      return l10n.apiErrorCustomersDeleteHasLedgerEntries;
    case 'customers.delete_has_opening_balance':
      return l10n.apiErrorCustomersDeleteHasOpeningBalance;
    case 'customers.delete_has_orders':
      return l10n.apiErrorCustomersDeleteHasOrders;
    case 'customers.the_walk_in_customer_is_used':
      return l10n.apiErrorCustomersTheWalkInCustomerIsUsed;
    case 'db.not_found':
      return l10n.apiErrorDbNotFound;
    case 'db.still_referenced':
      return l10n.apiErrorDbStillReferenced;
    case 'db.unexpected':
      return l10n.apiErrorDbUnexpected;
    case 'db.unique_violation':
      return l10n.apiErrorDbUniqueViolation;
    case 'expenses.a_category_named_already_exists':
      return l10n.apiErrorExpensesACategoryNamedAlreadyExists(_text(params, 'name'));
    case 'expenses.category_name_is_required':
      return l10n.apiErrorExpensesCategoryNameIsRequired;
    case 'expenses.category_not_found':
      return l10n.apiErrorExpensesCategoryNotFound;
    case 'expenses.expense_not_found':
      return l10n.apiErrorExpensesExpenseNotFound;
    case 'expenses.this_category_is_switched_off':
      return l10n.apiErrorExpensesThisCategoryIsSwitchedOff;
    case 'expenses.this_expense_was_already_voided':
      return l10n.apiErrorExpensesThisExpenseWasAlreadyVoided;
    case 'idempotency.a_request_with_this_idempotency_key':
      return l10n.apiErrorIdempotencyARequestWithThisIdempotencyKey;
    case 'idempotency.idempotency_key_is_too_long_200':
      return l10n.apiErrorIdempotencyIdempotencyKeyIsTooLong200;
    case 'idempotency.please_retry_the_request':
      return l10n.apiErrorIdempotencyPleaseRetryTheRequest;
    case 'idempotency.this_idempotency_key_was_already_used':
      return l10n.apiErrorIdempotencyThisIdempotencyKeyWasAlreadyUsed;
    case 'images.a_product_can_have_photos_at':
      return l10n.apiErrorImagesAProductCanHavePhotosAt(_text(params, 'max'));
    case 'images.list_every_photo_of_this_product':
      return l10n.apiErrorImagesListEveryPhotoOfThisProduct;
    case 'images.photo_not_found':
      return l10n.apiErrorImagesPhotoNotFound;
    case 'images.product_not_found':
      return l10n.apiErrorImagesProductNotFound;
    case 'images.that_variant_does_not_belong_to':
      return l10n.apiErrorImagesThatVariantDoesNotBelongTo;
    case 'images.the_file_has_not_been_uploaded':
      return l10n.apiErrorImagesTheFileHasNotBeenUploaded;
    case 'images.the_uploaded_file_does_not_match':
      return l10n.apiErrorImagesTheUploadedFileDoesNotMatch;
    case 'images.the_uploaded_file_is_not_a':
      return l10n.apiErrorImagesTheUploadedFileIsNotA;
    case 'ledger.ledger_entry_not_found':
      return l10n.apiErrorLedgerLedgerEntryNotFound;
    case 'ledger.only_admins_and_managers_can_read':
      return l10n.apiErrorLedgerOnlyAdminsAndManagersCanRead;
    case 'ledger.this_entry_belongs_to_a_purchase':
      return l10n.apiErrorLedgerThisEntryBelongsToAPurchase;
    case 'ledger.this_entry_belongs_to_an_order':
      return l10n.apiErrorLedgerThisEntryBelongsToAnOrder;
    case 'ledger.this_party_no_longer_exists':
      return l10n.apiErrorLedgerThisPartyNoLongerExists;
    case 'orders.a_cancelled_order_cannot_take_payments':
      return l10n.apiErrorOrdersACancelledOrderCannotTakePayments;
    case 'orders.cannot_cancel_in_status':
      return l10n.apiErrorOrdersCannotCancelInStatus(_orderStatus(l10n, _text(params, 'status'), lower: true));
    case 'orders.cannot_change_status_in_status':
      return l10n.apiErrorOrdersCannotChangeStatusInStatus(_orderStatus(l10n, _text(params, 'status'), lower: true));
    case 'orders.an_order_cannot_move_from_to':
      return l10n.apiErrorOrdersAnOrderCannotMoveFromTo(_orderStatus(l10n, _text(params, 'from'), lower: false), _orderStatus(l10n, _text(params, 'to'), lower: false));
    case 'orders.could_not_generate_an_order_number':
      return l10n.apiErrorOrdersCouldNotGenerateAnOrderNumber;
    case 'orders.item_inactive':
      return l10n.apiErrorOrdersItemInactive(_text(params, 'name'));
    case 'orders.order_not_found':
      return l10n.apiErrorOrdersOrderNotFound;
    case 'orders.order_number_already_exists':
      return l10n.apiErrorOrdersOrderNumberAlreadyExists(_text(params, 'supplied'));
    case 'orders.send_either_the_amount_paid_or':
      return l10n.apiErrorOrdersSendEitherTheAmountPaidOr;
    case 'orders.the_amount_paid_must_be_between':
      return l10n.apiErrorOrdersTheAmountPaidMustBeBetween;
    case 'orders.the_discount_on_must_be_between':
      return l10n.apiErrorOrdersTheDiscountOnMustBeBetween(_text(params, 'name'));
    case 'orders.the_order_discount_must_be_between':
      return l10n.apiErrorOrdersTheOrderDiscountMustBeBetween;
    case 'orders.this_customer_is_inactive':
      return l10n.apiErrorOrdersThisCustomerIsInactive;
    case 'orders.this_customer_no_longer_exists':
      return l10n.apiErrorOrdersThisCustomerNoLongerExists;
    case 'orders.this_order_already_exists':
      return l10n.apiErrorOrdersThisOrderAlreadyExists;
    case 'banners.a_banner_needs_a_title':
      return l10n.apiErrorBannersABannerNeedsATitle;
    case 'banners.banner_not_found':
      return l10n.apiErrorBannersBannerNotFound;
    case 'banners.the_link_must_start_with_or_https':
      return l10n.apiErrorBannersTheLinkMustStartWithOrHttps;
    case 'banners.the_order_is_not_the_list_of':
      return l10n.apiErrorBannersTheOrderIsNotTheListOf;
    case 'orders.this_order_would_take_over_the':
      return l10n.apiErrorOrdersThisOrderWouldTakeOverThe(_text(params, 'name'), _text(params, 'limit'), _text(params, 'balance'));
    case 'orders.use_the_cancel_action_to_cancel':
      return l10n.apiErrorOrdersUseTheCancelActionToCancel;
    case 'promotions.a_percent_is_between_1_and_100':
      return l10n.apiErrorPromotionsAPercentIsBetween1And100;
    case 'promotions.choose_a_category_or_a_product':
      return l10n.apiErrorPromotionsChooseACategoryOrAProduct;
    case 'promotions.give_the_promotion_a_name':
      return l10n.apiErrorPromotionsGiveThePromotionAName;
    case 'promotions.promotion_not_found':
      return l10n.apiErrorPromotionsPromotionNotFound;
    case 'promotions.that_code_is_already_used':
      return l10n.apiErrorPromotionsThatCodeIsAlreadyUsed(_text(params, 'code'));
    case 'promotions.that_coupon_code_is_not_valid':
      return l10n.apiErrorPromotionsThatCouponCodeIsNotValid;
    case 'promotions.the_end_is_before_the_start':
      return l10n.apiErrorPromotionsTheEndIsBeforeTheStart;
    case 'purchase_orders.could_not_generate_an_order_number':
      return l10n.apiErrorPurchaseOrdersCouldNotGenerateAnOrderNumber;
    case 'purchase_orders.only_a_partly_received_order_can_be_closed':
      return l10n.apiErrorPurchaseOrdersOnlyAPartlyReceivedOrderCanBeClosed;
    case 'purchase_orders.only_an_open_order_can_be_received':
      return l10n.apiErrorPurchaseOrdersOnlyAnOpenOrderCanBeReceived;
    case 'purchase_orders.only_an_order_nothing_arrived_for_can_be_cancelled':
      return l10n.apiErrorPurchaseOrdersOnlyAnOrderNothingArrivedForCanBeCancelled;
    case 'purchase_orders.only_can_still_be_received':
      return l10n.apiErrorPurchaseOrdersOnlyCanStillBeReceived(_text(params, 'max'), _text(params, 'name'));
    case 'purchase_orders.purchase_order_not_found':
      return l10n.apiErrorPurchaseOrdersPurchaseOrderNotFound;
    case 'purchase_orders.that_line_is_not_on_this_order':
      return l10n.apiErrorPurchaseOrdersThatLineIsNotOnThisOrder;
    case 'purchase_orders.this_order_already_exists':
      return l10n.apiErrorPurchaseOrdersThisOrderAlreadyExists;
    case 'photos.a_photo_can_be_10_mb':
      return l10n.apiErrorPhotosAPhotoCanBe10Mb;
    case 'photos.not_found':
      return l10n.apiErrorPhotosNotFound;
    case 'photos.only_jpeg_png_or_webp_photos':
      return l10n.apiErrorPhotosOnlyJpegPngOrWebpPhotos;
    case 'photos.photos_belong_to_one_of':
      return l10n.apiErrorPhotosPhotosBelongToOneOf(_text(params, 'kinds'));
    case 'products.a_barcode_is_required':
      return l10n.apiErrorProductsABarcodeIsRequired(_text(params, 'sku'));
    case 'products.barcode_already_belongs_to':
      return l10n.apiErrorProductsBarcodeAlreadyBelongsTo(_text(params, 'barcode'), _text(params, 'name'), _text(params, 'sku'));
    case 'products.barcode_is_used_twice_in_this':
      return l10n.apiErrorProductsBarcodeIsUsedTwiceInThis(_text(params, 'barcode'));
    case 'products.a_variant_id_already_belongs_to':
      return l10n.apiErrorProductsAVariantIdAlreadyBelongsTo;
    case 'products.a_variant_id_is_used_twice':
      return l10n.apiErrorProductsAVariantIdIsUsedTwice;
    case 'products.every_variant_needs_a_sku':
      return l10n.apiErrorProductsEveryVariantNeedsASku;
    case 'products.variant_has_stock_history':
      return l10n.apiErrorProductsVariantHasStockHistory(_text(params, 'name'));
    case 'products.product_name_is_required':
      return l10n.apiErrorProductsProductNameIsRequired;
    case 'products.sku_already_belongs_to':
      return l10n.apiErrorProductsSkuAlreadyBelongsTo(_text(params, 'sku'), _text(params, 'name'));
    case 'products.sku_is_used_twice_in_this':
      return l10n.apiErrorProductsSkuIsUsedTwiceInThis(_text(params, 'sku'));
    case 'products.the_selected_category_no_longer_exists':
      return l10n.apiErrorProductsTheSelectedCategoryNoLongerExists;
    case 'products.delete_has_stock_history':
      return l10n.apiErrorProductsDeleteHasStockHistory;
    case 'purchases.could_not_generate_a_purchase_number':
      return l10n.apiErrorPurchasesCouldNotGenerateAPurchaseNumber;
    case 'purchases.item_no_longer_exists_in_the':
      return l10n.apiErrorPurchasesItemNoLongerExistsInThe(_text(params, 'item'));
    case 'purchases.purchase_not_found':
      return l10n.apiErrorPurchasesPurchaseNotFound;
    case 'purchases.purchase_number_already_exists':
      return l10n.apiErrorPurchasesPurchaseNumberAlreadyExists(_text(params, 'supplied'));
    case 'purchases.the_amount_paid_must_be_between':
      return l10n.apiErrorPurchasesTheAmountPaidMustBeBetween;
    case 'purchases.the_payment_is_more_than_the':
      return l10n.apiErrorPurchasesThePaymentIsMoreThanThe(_text(params, 'due'));
    case 'purchases.this_purchase_already_exists':
      return l10n.apiErrorPurchasesThisPurchaseAlreadyExists;
    case 'purchases.this_vendor_is_inactive':
      return l10n.apiErrorPurchasesThisVendorIsInactive;
    case 'purchases.this_vendor_no_longer_exists':
      return l10n.apiErrorPurchasesThisVendorNoLongerExists;
    case 'request.too_many_requests':
      return l10n.apiErrorRequestTooManyRequests;
    case 'request.validation_failed':
      return l10n.apiErrorRequestValidationFailed;
    case 'starter_packs.choose_at_least_one_group_to':
      return l10n.apiErrorStarterPacksChooseAtLeastOneGroupTo;
    case 'starter_packs.not_in_this_pack':
      return l10n.apiErrorStarterPacksNotInThisPack(_text(params, 'names'));
    case 'starter_packs.there_is_no_such_starter_pack':
      return l10n.apiErrorStarterPacksThereIsNoSuchStarterPack;
    case 'reports.the_first_day_is_after_the_last_day':
      return l10n.apiErrorReportsTheFirstDayIsAfterTheLastDay;
    case 'returns.a_walk_in_customer_cannot_keep_credit':
      return l10n.apiErrorReturnsAWalkInCustomerCannotKeepCredit(_text(params, 'amount'));
    case 'returns.could_not_generate_a_return_number':
      return l10n.apiErrorReturnsCouldNotGenerateAReturnNumber;
    case 'returns.only_a_delivered_order_can_have':
      return l10n.apiErrorReturnsOnlyADeliveredOrderCanHave;
    case 'returns.only_can_still_be_returned':
      return l10n.apiErrorReturnsOnlyCanStillBeReturned(_text(params, 'max'), _text(params, 'name'));
    case 'returns.return_not_found':
      return l10n.apiErrorReturnsReturnNotFound;
    case 'returns.that_item_is_not_on_this_order':
      return l10n.apiErrorReturnsThatItemIsNotOnThisOrder;
    case 'returns.the_refund_cannot_be_more_than':
      return l10n.apiErrorReturnsTheRefundCannotBeMoreThan(_text(params, 'max'));
    case 'stock.not_enough_stock_for_on_hand':
      return l10n.apiErrorStockNotEnoughStockForOnHand(_text(params, 'name'), _text(params, 'quantity'), _text(params, 'needed'));
    case 'register.the_day_has_not_started_yet':
      return l10n.apiErrorRegisterTheDayHasNotStartedYet;
    case 'register.the_register_is_switched_off':
      return l10n.apiErrorRegisterTheRegisterIsSwitchedOff;
    case 'store.an_account_with_this_email_already':
      return l10n.apiErrorStoreAnAccountWithThisEmailAlready;
    case 'store.an_item_in_your_cart_is':
      return l10n.apiErrorStoreAnItemInYourCartIs;
    case 'store.e_mail_is_only_set_up':
      return l10n.apiErrorStoreEMailIsOnlySetUp;
    case 'store.please_enter_a_valid_phone_number':
      return l10n.apiErrorStorePleaseEnterAValidPhoneNumber;
    case 'store.please_order_at_most_100_of':
      return l10n.apiErrorStorePleaseOrderAtMost100Of;
    case 'store.please_sign_in':
      return l10n.apiErrorStorePleaseSignIn;
    case 'store.please_sign_in_again':
      return l10n.apiErrorStorePleaseSignInAgain;
    case 'store.sorry_one_of_your_items_is':
      return l10n.apiErrorStoreSorryOneOfYourItemsIs;
    case 'store.the_store_is_closed_right_now':
      return l10n.apiErrorStoreTheStoreIsClosedRightNow;
    case 'store.the_store_is_not_taking_orders':
      return l10n.apiErrorStoreTheStoreIsNotTakingOrders;
    case 'store.this_link_has_expired_please_ask':
      return l10n.apiErrorStoreThisLinkHasExpiredPleaseAsk;
    case 'store.this_order_number_is_already_used':
      return l10n.apiErrorStoreThisOrderNumberIsAlreadyUsed;
    case 'store.this_product_is_not_available':
      return l10n.apiErrorStoreThisProductIsNotAvailable;
    case 'store.we_cannot_take_online_orders_for':
      return l10n.apiErrorStoreWeCannotTakeOnlineOrdersFor;
    case 'store.we_could_not_find_this_order':
      return l10n.apiErrorStoreWeCouldNotFindThisOrder;
    case 'store.wrong_email_or_password':
      return l10n.apiErrorStoreWrongEmailOrPassword;
    case 'stream.too_many_connections':
      return l10n.apiErrorStreamTooManyConnections;
    case 'users.a_user_with_this_email_already':
      return l10n.apiErrorUsersAUserWithThisEmailAlready;
    case 'users.there_must_be_at_least_one':
      return l10n.apiErrorUsersThereMustBeAtLeastOne;
    case 'users.user_not_found':
      return l10n.apiErrorUsersUserNotFound;
    case 'users.you_cannot_demote_or_disable_your':
      return l10n.apiErrorUsersYouCannotDemoteOrDisableYour;
    case 'vendors.a_vendor_named_already_exists':
      return l10n.apiErrorVendorsAVendorNamedAlreadyExists(_text(params, 'name'));
    case 'vendors.a_vendor_with_this_phone_number':
      return l10n.apiErrorVendorsAVendorWithThisPhoneNumber;
    case 'vendors.delete_has_ledger_entries':
      return l10n.apiErrorVendorsDeleteHasLedgerEntries;
    case 'vendors.delete_has_opening_balance':
      return l10n.apiErrorVendorsDeleteHasOpeningBalance;
    case 'vendors.delete_has_purchases':
      return l10n.apiErrorVendorsDeleteHasPurchases;
    case 'vendors.vendor_name_is_required':
      return l10n.apiErrorVendorsVendorNameIsRequired;
    case 'vendors.vendor_not_found':
      return l10n.apiErrorVendorsVendorNotFound;
    default:
      return null;
  }
}

String _text(Map<String, Object?> params, String name) => '${params[name] ?? ''}';

int _int(Map<String, Object?> params, String name) {
  final Object? value = params[name];
  return value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;
}

/// The server sends an order status as its English label ("Delivered").
String _orderStatus(AppLocalizations l10n, String label, {required bool lower}) {
  final String text;
  switch (label.toLowerCase()) {
    case 'pending':
      text = l10n.orderStatusPending;
    case 'processing':
      text = l10n.orderStatusProcessing;
    case 'shipped':
      text = l10n.orderStatusShipped;
    case 'delivered':
      text = l10n.orderStatusDelivered;
    case 'cancelled':
      text = l10n.orderStatusCancelled;
    default:
      return label;
  }
  return lower ? text.toLowerCase() : text;
}
