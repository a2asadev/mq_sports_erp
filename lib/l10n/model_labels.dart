import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/activity_log_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_role.dart';

// The words for the app's enums, in the language the app is showing. The models
// stay pure Dart (they only know their names); the text is added here.

extension OrderStatusLabel on OrderStatus {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.processing:
        return l10n.orderStatusProcessing;
      case OrderStatus.shipped:
        return l10n.orderStatusShipped;
      case OrderStatus.delivered:
        return l10n.orderStatusDelivered;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }
}

extension OrderSaleTypeLabel on OrderSaleType {
  String get label => this == OrderSaleType.retail ? L10n.current.saleTypeRetail : L10n.current.saleTypeWholesale;
}

extension CustomerTypeLabel on CustomerType {
  String get label => this == CustomerType.retail ? L10n.current.saleTypeRetail : L10n.current.saleTypeWholesale;
}

extension PartyTypeLabel on PartyType {
  String get label => this == PartyType.vendor ? L10n.current.partyTypeVendor : L10n.current.partyTypeCustomer;

  /// Wording for a balance. A positive balance means the customer owes us,
  /// or that we owe the vendor.
  String balanceCaption(double balance) {
    final AppLocalizations l10n = L10n.current;
    if (balance.abs() < 0.005) {
      return l10n.balanceSettled;
    }
    final bool positive = balance > 0;
    if (this == PartyType.customer) {
      return positive ? l10n.balanceToReceive : l10n.balanceAdvanceReceived;
    }
    return positive ? l10n.balanceToPay : l10n.balanceAdvancePaid;
  }
}

extension LedgerEntryTypeLabel on LedgerEntryType {
  String labelFor(PartyType party) {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case LedgerEntryType.charge:
        return party == PartyType.customer ? l10n.ledgerSaleOnCredit : l10n.ledgerPurchaseOnCredit;
      case LedgerEntryType.payment:
        return party == PartyType.customer ? l10n.ledgerPaymentReceived : l10n.ledgerPaymentMade;
    }
  }
}

extension VendorTypeLabel on VendorType {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case VendorType.manufacturer:
        return l10n.vendorTypeManufacturer;
      case VendorType.shop:
        return l10n.vendorTypeShop;
      case VendorType.other:
        return l10n.vendorTypeOther;
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case PaymentMethod.cash:
        return l10n.paymentMethodCash;
      case PaymentMethod.easypaisa:
        return l10n.paymentMethodEasypaisa;
      case PaymentMethod.jazzcash:
        return l10n.paymentMethodJazzcash;
      case PaymentMethod.bank:
        return l10n.paymentMethodBank;
    }
  }
}

/// What to show for a stored payment method name ('' = not recorded).
String paymentMethodLabelOf(String? name) =>
    PaymentMethod.fromName(name)?.label ?? L10n.current.paymentMethodUnknown;

extension PurchaseStatusLabel on PurchaseStatus {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case PurchaseStatus.pending:
        return l10n.purchaseStatusPending;
      case PurchaseStatus.partial:
        return l10n.purchaseStatusPartial;
      case PurchaseStatus.paid:
        return l10n.purchaseStatusPaid;
    }
  }
}

extension StockMovementTypeLabel on StockMovementType {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case StockMovementType.purchase:
        return l10n.stockMovementPurchase;
      case StockMovementType.sale:
        return l10n.stockMovementSale;
      case StockMovementType.adjustment:
        return l10n.stockMovementAdjustment;
    }
  }
}

extension UserRoleLabel on UserRole {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case UserRole.admin:
        return l10n.userRoleAdmin;
      case UserRole.manager:
        return l10n.userRoleManager;
      case UserRole.staff:
        return l10n.userRoleStaff;
    }
  }
}

extension LogLevelLabel on LogLevel {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case LogLevel.info:
        return l10n.logLevelInfo;
      case LogLevel.warning:
        return l10n.logLevelWarning;
      case LogLevel.error:
        return l10n.logLevelError;
    }
  }
}

extension LogKindLabel on LogKind {
  String get label {
    final AppLocalizations l10n = L10n.current;
    switch (this) {
      case LogKind.record:
        return l10n.logKindRecord;
      case LogKind.action:
        return l10n.logKindAction;
      case LogKind.failure:
        return l10n.logKindFailure;
      case LogKind.sync:
        return l10n.logKindSync;
      case LogKind.session:
        return l10n.logKindSession;
    }
  }
}
