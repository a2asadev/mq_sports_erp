import 'dart:async';
import 'package:a2_stocks/core/utils/currency.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/category_tree.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/party_list_item.dart';
import 'package:a2_stocks/models/payment_method.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/pos_holds.dart';
import 'package:a2_stocks/providers/pos_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/pos/held_sales_dialog.dart';
import 'package:a2_stocks/screens/pos/pos_payment_dialog.dart';
import 'package:a2_stocks/screens/sales/orders_screen.dart';
import 'package:a2_stocks/widgets/business_brand.dart';
import 'package:a2_stocks/widgets/online_status_chip.dart';
import 'package:a2_stocks/widgets/party_picker.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:a2_stocks/widgets/receipt_actions.dart';
import 'package:a2_stocks/widgets/sync_status_chip.dart';

String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

const List<String> _weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = <String>[
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

IconData _methodIcon(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cash:
      return Icons.payments_outlined;
    case PaymentMethod.easypaisa:
      return Icons.phone_android;
    case PaymentMethod.jazzcash:
      return Icons.account_balance_wallet_outlined;
    case PaymentMethod.bank:
      return Icons.account_balance_outlined;
  }
}

/// The counter: find a product, tap it, take payment, give the receipt.
///
/// On a wide screen it is a till: a category rail, the product grid, and the
/// order on the right with the payment methods and a row of actions below.
/// On a phone the products and the order are two tabs. Barcodes are optional:
/// the search box also finds a product by barcode or SKU, so a scanner that
/// types (most of them do) and the Enter key add the item at once.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String _categoryId = '';
  bool _showCart = false;
  bool _charging = false;
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  // ---- adding items ---------------------------------------------------------

  void _addVariant(ProductModel product, VariantModel variant) {
    final PosCart cart = ref.read(posCartProvider);
    final int onHand = ref.read(stockOnHandProvider)[variant.id] ?? 0;
    if (cart.quantityOf(variant.id) + 1 > onHand) {
      _message(onHand <= 0
          ? '"${product.name} · ${variant.label}" is out of stock.'
          : 'Only $onHand of "${product.name} · ${variant.label}" in stock.');
      return;
    }
    ref.read(posCartProvider.notifier).set(cart.add(product, variant));
  }

  Future<void> _addProduct(ProductModel product) async {
    final List<VariantModel> variants =
        product.variants.where((VariantModel v) => v.isActive).toList();
    if (variants.isEmpty) {
      _message('"${product.name}" has no active variant.');
      return;
    }
    if (variants.length == 1) {
      _addVariant(product, variants.first);
      return;
    }
    final Map<String, int> stock = ref.read(stockOnHandProvider);
    final VariantModel? chosen = await showModalBottomSheet<VariantModel>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final VariantModel v in variants)
              ListTile(
                enabled: (stock[v.id] ?? 0) > 0,
                title: Text(v.label),
                subtitle: Text('${stock[v.id] ?? 0} in stock'),
                trailing: Text('${MoneyFormat.prefix}${_fmt(v.salePrice)}', style: Theme.of(context).textTheme.titleMedium),
                onTap: () => Navigator.of(context).pop(v),
              ),
          ],
        ),
      ),
    );
    if (chosen != null && mounted) {
      _addVariant(product, chosen);
    }
  }

  /// The minus on a product card: takes one unit off the product's latest line.
  void _removeProduct(ProductModel product) {
    final PosCart cart = ref.read(posCartProvider);
    final PosLine? line = cart.lines.where((PosLine l) => l.productId == product.id).lastOrNull;
    if (line != null) {
      ref.read(posCartProvider.notifier).set(cart.setQuantity(line.variantId, line.quantity - 1));
    }
  }

  /// Enter in the search box: an exact barcode or SKU adds that item.
  void _submitSearch(List<ProductModel> products) {
    final String code = _search.text.trim().toLowerCase();
    if (code.isEmpty) {
      return;
    }
    for (final ProductModel p in products) {
      for (final VariantModel v in p.variants) {
        if (v.isActive &&
            p.isActive &&
            (v.barcode.trim().toLowerCase() == code || v.sku.trim().toLowerCase() == code)) {
          _addVariant(p, v);
          _search.clear();
          setState(() => _query = '');
          _searchFocus.requestFocus();
          return;
        }
      }
    }
    _message('No product with barcode or SKU "${_search.text.trim()}".');
    _searchFocus.requestFocus();
  }

  // ---- charging -------------------------------------------------------------

  CustomerModel? _walkIn() {
    final List<CustomerModel> customers = ref.read(customersProvider).valueOrNull ?? <CustomerModel>[];
    return customers.where((CustomerModel c) => c.id == ref.read(businessProvider).walkInCustomerId).firstOrNull;
  }

  Future<void> _chooseCustomer() async {
    final List<PartyListItem> items = ref.read(customerItemsProvider);
    final PartyPickResult? picked = await showPartyPickerSheet(
      context,
      title: 'Customer',
      partyType: PartyType.customer,
      items: items.where((PartyListItem i) => i.id != ref.read(businessProvider).walkInCustomerId && i.isActive).toList(),
      typeOptions: <MapEntry<String, String>>[
        for (final CustomerType t in CustomerType.values) MapEntry<String, String>(t.name, t.label),
      ],
      selectedId: ref.read(posCartProvider).customer?.id,
      showCreditFilter: true,
      clearLabel: 'Walk-in customer',
    );
    if (picked == null || !mounted) {
      return;
    }
    final List<CustomerModel> customers = ref.read(customersProvider).valueOrNull ?? <CustomerModel>[];
    final CustomerModel? customer =
        customers.where((CustomerModel c) => c.id == picked.item?.id).firstOrNull;
    ref.read(posCartProvider.notifier).set(ref.read(posCartProvider).withCustomer(customer));
  }

  Future<void> _charge() async {
    final PosCart cart = ref.read(posCartProvider);
    if (cart.isEmpty || _charging) {
      return;
    }
    if (!ref.read(canCreateOrdersProvider)) {
      _message('Your login cannot make sales.');
      return;
    }
    final CustomerModel? customer = cart.customer ?? _walkIn();
    if (customer == null) {
      _message('The walk-in customer is not on this device yet. Sync once, then try again.');
      return;
    }
    final PosPaymentResult? payment = await showPosPaymentDialog(
      context,
      total: cart.total,
      allowCredit: cart.customer != null,
      initialMethod: _method,
    );
    if (payment == null || !mounted) {
      return;
    }
    setState(() => _charging = true);
    final OrdersNotifier orders = ref.read(ordersProvider.notifier);
    final bool ok = await orders.confirmOrder(
      customer: customer,
      saleType: customer.type == CustomerType.wholesale ? OrderSaleType.wholesale : OrderSaleType.retail,
      orderDate: DateTime.now(),
      notes: '',
      items: cart.toItems(),
      orderDiscount: cart.effectiveOrderDiscount,
      paidNow: 0,
      channel: 'pos',
      payments: payment.lines,
    );
    if (!mounted) {
      return;
    }
    setState(() => _charging = false);
    if (!ok) {
      final Object? error = ref.read(ordersProvider).error;
      _message(error == null ? 'The sale could not be completed.' : errorMessageOf(error));
      return;
    }
    final OrderModel? order = orders.lastConfirmed;
    ref.read(posCartProvider.notifier).clear();
    setState(() => _showCart = false);
    if (order != null) {
      await _showDone(order, payment, cart.customer);
    }
  }

  Future<void> _showDone(OrderModel order, PosPaymentResult payment, CustomerModel? named) async {
    final ShopInfo shop = await ref.read(shopInfoProvider.future);
    final UserModel? me = ref.read(currentUserProvider).valueOrNull;
    final ReceiptData receipt = ReceiptData.fromParts(
      order,
      payments: <ReceiptPayment>[
        for (final PaymentLine p in payment.lines)
          ReceiptPayment(label: p.method.label, amount: p.amount, reference: p.reference),
      ],
      shopName: shop.name,
      walkInCustomerId: ref.read(businessProvider).walkInCustomerId,
      shopPhone: shop.phone,
      logoUrl: shop.logoUrl,
      cashier: me == null ? '' : (me.displayName.isNotEmpty ? me.displayName : me.email),
      change: payment.change,
    );
    if (!mounted) {
      return;
    }
    await showReceiptDialog(
      context,
      receipt,
      phone: named?.phone ?? '',
      barrierDismissible: false,
      header: Container(
        color: AppColors.tealSoft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.check_circle, color: AppColors.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Sale complete', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  if (payment.change > 0.005)
                    Text('Give change: ${MoneyFormat.prefix}${_fmt(payment.change)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (receipt.due > 0.005) Text('Balance due: ${MoneyFormat.prefix}${_fmt(receipt.due)}'),
                ],
              ),
            ),
          ],
        ),
      ),
      footer: Builder(
        builder: (BuildContext context) => FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.navy, minimumSize: const Size.fromHeight(44)),
          child: const Text('New sale'),
        ),
      ),
    );
    if (mounted) {
      _searchFocus.requestFocus();
    }
  }

  void _clearSale() => ref.read(posCartProvider.notifier).clear();

  /// Parks the sale so the next customer can be served.
  void _holdSale() {
    final PosCart cart = ref.read(posCartProvider);
    if (cart.isEmpty) {
      return;
    }
    ref.read(heldSalesProvider.notifier).hold(cart);
    ref.read(posCartProvider.notifier).clear();
    setState(() => _showCart = false);
    _message('Sale put on hold. Find it under "Held".');
  }

  Future<void> _showHeld() async {
    final HeldSale? chosen = await showHeldSalesDialog(context);
    if (chosen == null || !mounted) {
      return;
    }
    final PosCart current = ref.read(posCartProvider);
    final HeldSalesNotifier held = ref.read(heldSalesProvider.notifier);
    held.remove(chosen.id);
    if (!current.isEmpty) {
      held.hold(current); // The sale in progress is parked, not lost.
    }
    ref.read(posCartProvider.notifier).set(chosen.cart);
    setState(() => _showCart = true);
    _message(current.isEmpty ? 'Held sale resumed.' : 'Held sale resumed. The previous sale is now on hold.');
  }

  void _openOrders() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (BuildContext context) => const OrdersScreen()),
      );

  // ---- layout ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> productsAsync = ref.watch(productsProvider);
    final List<ProductModel> products = productsAsync.valueOrNull ?? <ProductModel>[];
    final PosCart cart = ref.watch(posCartProvider);
    final bool canSell = ref.watch(canCreateOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final bool wide = box.maxWidth >= 900;
            final Widget catalog = _Catalog(
              wide: wide,
              search: _search,
              focus: _searchFocus,
              query: _query,
              categoryId: _categoryId,
              products: products,
              loading: productsAsync.isLoading && products.isEmpty,
              onQuery: (String q) => setState(() => _query = q),
              onCategory: (String id) => setState(() => _categoryId = id),
              onSubmit: () => _submitSearch(products),
              onAdd: _addProduct,
              onRemove: _removeProduct,
            );
            final Widget sale = _SalePanel(
              charging: _charging,
              canSell: canSell,
              method: _method,
              onMethod: (PaymentMethod m) => setState(() => _method = m),
              onCustomer: _chooseCustomer,
              onCharge: _charge,
              onClear: _clearSale,
              onHold: _holdSale,
              onHeld: _showHeld,
              heldCount: ref.watch(heldSalesProvider).length,
            );
            if (wide) {
              return Column(
                children: <Widget>[
                  _TopBar(wide: true, onDashboard: () => Navigator.of(context).maybePop()),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _CategoryRail(selected: _categoryId, onSelect: (String id) => setState(() => _categoryId = id)),
                        Expanded(child: catalog),
                        Container(
                          width: 410,
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: AppColors.border)),
                          ),
                          child: sale,
                        ),
                      ],
                    ),
                  ),
                  _BottomBar(
                    enabled: !cart.isEmpty && canSell && !_charging,
                    hasItems: !cart.isEmpty,
                    onOrders: _openOrders,
                    onVoid: _clearSale,
                    onPayment: _charge,
                    onHold: _holdSale,
                    onHeld: _showHeld,
                    heldCount: ref.watch(heldSalesProvider).length,
                  ),
                ],
              );
            }
            return Column(
              children: <Widget>[
                _TopBar(wide: false, onDashboard: () => Navigator.of(context).maybePop()),
                Expanded(child: _showCart ? sale : catalog),
                NavigationBar(
                  selectedIndex: _showCart ? 1 : 0,
                  onDestinationSelected: (int i) => setState(() => _showCart = i == 1),
                  destinations: <Widget>[
                    const NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Products'),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: cart.units > 0,
                        label: Text('${cart.units}'),
                        child: const Icon(Icons.shopping_bag_outlined),
                      ),
                      label: cart.isEmpty ? 'Sale' : 'Sale · ${MoneyFormat.prefix}${_fmt(cart.total)}',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---- top bar ------------------------------------------------------------------

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.wide, required this.onDashboard});

  final bool wide;
  final VoidCallback onDashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    final ShopInfo shop = ref.watch(shopInfoProvider).valueOrNull ?? const ShopInfo();
    final bool online = ref.watch(dataModeProvider).isOnline;
    final String name = user == null ? '' : (user.displayName.isNotEmpty ? user.displayName : user.email);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          if (!wide) IconButton(onPressed: onDashboard, icon: const Icon(Icons.arrow_back), tooltip: 'Back'),
          Flexible(child: BusinessLockup(markHeight: wide ? 34 : 30, showName: wide)),
          if (wide) ...<Widget>[const SizedBox(width: 20), const _Clock()],
          const Spacer(),
          if (wide) ...<Widget>[
            FilledButton.icon(
              onPressed: onDashboard,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.space_dashboard_outlined, size: 18),
              label: const Text('Dashboard'),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.storefront_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          if (online) const OnlineStatusChip() else const SyncStatusChip(),
          const SizedBox(width: 8),
          if (user != null) PhotoAvatar(url: user.photoUrl, label: name, radius: 18),
        ],
      ),
    );
  }
}

class _Clock extends StatefulWidget {
  const _Clock();

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.schedule, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '${two(_now.hour)}:${two(_now.minute)}:${two(_now.second)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---- bottom action bar -----------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.enabled,
    required this.hasItems,
    required this.onOrders,
    required this.onVoid,
    required this.onPayment,
    required this.onHold,
    required this.onHeld,
    required this.heldCount,
  });

  final bool enabled;
  final bool hasItems;
  final VoidCallback onOrders;
  final VoidCallback onVoid;
  final VoidCallback onPayment;
  final VoidCallback onHold;
  final VoidCallback onHeld;
  final int heldCount;

  Widget _button(String label, IconData icon, Color color, VoidCallback? onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _button('View Orders', Icons.receipt_long_outlined, AppColors.navy, onOrders),
          _button('Hold', Icons.pause_circle_outline, AppColors.amber, hasItems ? onHold : null),
          _button(heldCount > 0 ? 'Held ($heldCount)' : 'Held', Icons.history, AppColors.violet, onHeld),
          _button('Void', Icons.delete_outline, AppColors.danger, hasItems ? onVoid : null),
          _button('Payment', Icons.payments_outlined, AppColors.teal, enabled ? onPayment : null),
        ],
      ),
    );
  }
}

// ---- categories --------------------------------------------------------------------

List<CategoryModel> _activeCategories(WidgetRef ref) =>
    (ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[])
        .where((CategoryModel c) => c.isActive)
        .toList()
      ..sort((CategoryModel a, CategoryModel b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

class _CategoryRail extends ConsumerWidget {
  const _CategoryRail({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CategoryModel> categories = _activeCategories(ref);
    Widget tile(String id, String label, Widget icon) {
      final bool on = selected == id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: on ? AppColors.primary : AppColors.border, width: on ? 1.6 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelect(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: <Widget>[
                  icon,
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                      color: on ? AppColors.primary : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 112,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          tile('', 'All', Icon(Icons.grid_view_rounded, color: selected.isEmpty ? AppColors.primary : AppColors.textMuted)),
          for (final CategoryModel c in categories)
            tile(
              c.id,
              c.name,
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: NetworkPhoto(url: c.photoUrl, size: 34, placeholder: Icons.category_outlined),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---- catalog -----------------------------------------------------------------------

class _Catalog extends ConsumerWidget {
  const _Catalog({
    required this.wide,
    required this.search,
    required this.focus,
    required this.query,
    required this.categoryId,
    required this.products,
    required this.loading,
    required this.onQuery,
    required this.onCategory,
    required this.onSubmit,
    required this.onAdd,
    required this.onRemove,
  });

  final bool wide;
  final TextEditingController search;
  final FocusNode focus;
  final String query;
  final String categoryId;
  final List<ProductModel> products;
  final bool loading;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final VoidCallback onSubmit;
  final ValueChanged<ProductModel> onAdd;
  final ValueChanged<ProductModel> onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CategoryModel> categories = _activeCategories(ref);
    final Map<String, String> categoryName = <String, String>{for (final CategoryModel c in categories) c.id: c.name};
    final Map<String, int> stock = ref.watch(stockOnHandProvider);
    final PosCart cart = ref.watch(posCartProvider);
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    final Set<String> inCategory = categoryId.isEmpty
        ? <String>{}
        : <String>{categoryId, ...CategoryTree.descendantIds(categoryId, categories)};
    final String q = query.trim().toLowerCase();
    final List<ProductModel> shown = products.where((ProductModel p) {
      if (!p.isActive || p.variants.every((VariantModel v) => !v.isActive)) {
        return false;
      }
      if (inCategory.isNotEmpty && !inCategory.contains(p.categoryId)) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.variants.any((VariantModel v) =>
              v.sku.toLowerCase().contains(q) || v.barcode.toLowerCase().contains(q));
    }).toList()
      ..sort((ProductModel a, ProductModel b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final Widget searchField = TextField(
      controller: search,
      focusNode: focus,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search, or scan barcode / SKU and press Enter',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  search.clear();
                  onQuery('');
                },
              ),
      ),
      onChanged: onQuery,
      onSubmitted: (_) => onSubmit(),
    );

    final String who = user == null
        ? ''
        : (user.displayName.isNotEmpty ? user.displayName : user.email.split('@').first);
    final DateTime now = DateTime.now();
    final Widget welcome = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Welcome, $who', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        Text(
          '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: wide
              ? Row(
                  children: <Widget>[
                    Expanded(child: welcome),
                    SizedBox(width: 340, child: searchField),
                  ],
                )
              : searchField,
        ),
        if (!wide)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: const Text('All'), selected: categoryId.isEmpty, onSelected: (_) => onCategory('')),
                ),
                for (final CategoryModel c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(c.name), selected: categoryId == c.id, onSelected: (_) => onCategory(c.id)),
                  ),
              ],
            ),
          ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : shown.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: wide ? 230 : 190,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: wide ? 0.86 : 0.78,
                      ),
                      itemCount: shown.length,
                      itemBuilder: (BuildContext context, int i) {
                        final ProductModel p = shown[i];
                        final List<VariantModel> active = p.variants.where((VariantModel v) => v.isActive).toList();
                        final int onHand = active.fold<int>(0, (int s, VariantModel v) => s + (stock[v.id] ?? 0));
                        final double low = active.map((VariantModel v) => v.salePrice).reduce((double a, double b) => a < b ? a : b);
                        final double high = active.map((VariantModel v) => v.salePrice).reduce((double a, double b) => a > b ? a : b);
                        final int inCart = cart.lines
                            .where((PosLine l) => l.productId == p.id)
                            .fold<int>(0, (int s, PosLine l) => s + l.quantity);
                        return _ProductCard(
                          product: p,
                          category: categoryName[p.categoryId] ?? '',
                          onHand: onHand,
                          priceText: low == high ? '${MoneyFormat.prefix}${_fmt(low)}' : '${MoneyFormat.prefix}${_fmt(low)}+',
                          inCart: inCart,
                          onAdd: () => onAdd(p),
                          onRemove: () => onRemove(p),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.category,
    required this.onHand,
    required this.priceText,
    required this.inCart,
    required this.onAdd,
    required this.onRemove,
  });

  final ProductModel product;
  final String category;
  final int onHand;
  final String priceText;
  final int inCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  Widget _round(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? AppColors.mutedFill : AppColors.border,
          ),
          child: Icon(icon, size: 14, color: onTap == null ? AppColors.textMuted : AppColors.text),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool out = onHand <= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: inCart > 0 ? AppColors.primarySoft.withValues(alpha: 0.5) : AppColors.surface,
      child: InkWell(
        onTap: out ? null : onAdd,
        child: Opacity(
          opacity: out ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColoredBox(
                      color: AppColors.mutedFill,
                      child: NetworkPhoto(
                        url: product.images.isEmpty ? '' : product.images.first.mediumUrl,
                        placeholder: Icons.inventory_2_outlined,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                    Text(
                      out ? 'Out of stock' : '$onHand left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: out ? AppColors.danger : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(priceText, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                    _round(Icons.remove, inCart > 0 ? onRemove : null),
                    SizedBox(
                      width: 26,
                      child: Text('$inCart', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    _round(Icons.add, out ? null : onAdd),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- the order ---------------------------------------------------------------------

class _SalePanel extends ConsumerWidget {
  const _SalePanel({
    required this.charging,
    required this.canSell,
    required this.method,
    required this.onMethod,
    required this.onCustomer,
    required this.onCharge,
    required this.onClear,
    required this.onHold,
    required this.onHeld,
    required this.heldCount,
  });

  final bool charging;
  final bool canSell;
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethod;
  final VoidCallback onCustomer;
  final VoidCallback onCharge;
  final VoidCallback onClear;
  final VoidCallback onHold;
  final VoidCallback onHeld;
  final int heldCount;

  Future<void> _editDiscount(BuildContext context, WidgetRef ref, {PosLine? line}) async {
    final PosCart cart = ref.read(posCartProvider);
    final TextEditingController controller = TextEditingController(
      text: (line?.discount ?? cart.orderDiscount) > 0 ? _fmt(line?.discount ?? cart.orderDiscount) : '',
    );
    final double? value = await showDialog<double>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(line == null ? 'Discount on the whole sale' : 'Discount on ${line.productName}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Amount', prefixText: MoneyFormat.prefix),
          onSubmitted: (String t) => Navigator.of(context).pop(double.tryParse(t.trim()) ?? 0),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(controller.text.trim()) ?? 0),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    disposeControllerLater(controller);
    if (value == null) {
      return;
    }
    final PosCartNotifier notifier = ref.read(posCartProvider.notifier);
    notifier.set(line == null
        ? ref.read(posCartProvider).withOrderDiscount(value)
        : ref.read(posCartProvider).setLineDiscount(line.variantId, value));
  }

  Widget _title(String text, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing],
          ],
        ),
      );

  Widget _summaryRow(String label, String value, {Color? color, Widget? edit}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: <Widget>[
            Text(label, style: TextStyle(color: color ?? AppColors.textMuted, fontSize: 13)),
            if (edit != null) ...<Widget>[const SizedBox(width: 6), edit],
            const Spacer(),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PosCart cart = ref.watch(posCartProvider);
    final PosCartNotifier notifier = ref.read(posCartProvider.notifier);
    final Map<String, int> stock = ref.watch(stockOnHandProvider);

    // Fixed top: title, customer and the "Order Details" heading.
    final Widget top = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text('Order List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            TextButton.icon(
              onPressed: onHeld,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.history, size: 18),
              label: Text(heldCount > 0 ? 'Held ($heldCount)' : 'Held'),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(4)),
              child: const Text('New sale', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            IconButton(
              tooltip: 'Clear sale',
              visualDensity: VisualDensity.compact,
              onPressed: cart.isEmpty ? null : onClear,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            ),
          ],
        ),
        const Divider(height: 20),
        _title('Customer Information'),
        InkWell(
          onTap: onCustomer,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(cart.customer?.name ?? 'Walk-in customer', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        cart.customer == null ? 'Pays in full now' : 'May pay now or later',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const Divider(height: 20),
      ],
    );

    // The products added: scrolls when there are many.
    final Widget itemsBody = cart.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.shopping_cart_outlined, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                const Text('No Products Selected', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          )
        : Column(
            children: <Widget>[
              for (final PosLine l in cart.lines)
                _CartLine(
                  line: l,
                  available: stock[l.variantId] ?? 0,
                  onMinus: () => notifier.set(cart.setQuantity(l.variantId, l.quantity - 1)),
                  onPlus: () => notifier.set(cart.setQuantity(l.variantId, l.quantity + 1)),
                  onDiscount: () => _editDiscount(context, ref, line: l),
                  onRemove: () => notifier.set(cart.remove(l.variantId)),
                ),
            ],
          );

    final Widget items = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _title(
          'Order Details',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Items : ${cart.units}', style: const TextStyle(fontSize: 11)),
          ),
        ),
        itemsBody,
      ],
    );

    // Pinned bottom: totals, payment method and the buttons.
    final Widget bottom = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Divider(height: 24),
        _summaryRow('Sub Total', '${MoneyFormat.prefix}${_fmt(cart.subtotal)}'),
        _summaryRow(
          'Discount',
          cart.effectiveOrderDiscount > 0 ? '-${MoneyFormat.prefix}${_fmt(cart.effectiveOrderDiscount)}' : '${MoneyFormat.prefix}0',
          color: AppColors.danger,
          edit: InkWell(
            onTap: cart.isEmpty ? null : () => _editDiscount(context, ref),
            child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.textMuted),
          ),
        ),
        const Divider(height: 20),
        Row(
          children: <Widget>[
            const Text('Total Payable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(
              '${MoneyFormat.prefix}${_fmt(cart.total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
          ],
        ),
        const Divider(height: 24),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: <Widget>[
            for (final PaymentMethod m in PaymentMethod.values)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onMethod(m),
                child: Container(
                  decoration: BoxDecoration(
                    color: method == m ? AppColors.primarySoft : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: method == m ? AppColors.primary : AppColors.border,
                      width: method == m ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(_methodIcon(m), size: 20, color: method == m ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          m == PaymentMethod.bank ? 'Bank' : m.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: method == m ? AppColors.primary : AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: cart.isEmpty ? null : onHold,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.pause_circle_outline, size: 18),
                label: const Text('Hold'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: (cart.isEmpty || charging || !canSell) ? null : onCharge,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  minimumSize: const Size.fromHeight(46),
                ),
                icon: charging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(cart.isEmpty ? 'Place Order' : 'Place Order · ${MoneyFormat.prefix}${_fmt(cart.total)}'),
              ),
            ),
          ],
        ),
        if (!canSell)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Your login cannot make sales.', textAlign: TextAlign.center),
          ),
      ],
    );

    // The panel takes the whole height: top and bottom stay in place and the
    // product list in between scrolls. On a very short screen everything
    // scrolls together instead.
    return ColoredBox(
      color: AppColors.surface,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          const EdgeInsets padding = EdgeInsets.all(16);
          if (box.maxHeight >= 600) {
            return Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  top,
                  Expanded(child: SingleChildScrollView(child: items)),
                  bottom,
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[top, items, bottom],
            ),
          );
        },
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.line,
    required this.available,
    required this.onMinus,
    required this.onPlus,
    required this.onDiscount,
    required this.onRemove,
  });

  final PosLine line;
  final int available;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onDiscount;
  final VoidCallback onRemove;

  Widget _small(IconData icon, VoidCallback? onTap, {Color? color}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: onTap == null ? AppColors.border : (color ?? AppColors.textMuted)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 46,
              height: 46,
              child: ColoredBox(
                color: AppColors.surface,
                child: NetworkPhoto(url: line.imageUrl, size: 46, placeholder: Icons.inventory_2_outlined, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(line.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(
                  '${line.variantLabel.isEmpty ? '' : '${line.variantLabel} · '}${MoneyFormat.prefix}${_fmt(line.unitPrice)}'
                  '${line.discount > 0 ? ' · −${_fmt(line.discount)}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text('${MoneyFormat.prefix}${_fmt(line.total)}', style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _small(Icons.remove, onMinus),
                  SizedBox(width: 26, child: Text('${line.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
                  _small(Icons.add, line.quantity + 1 > available ? null : onPlus),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _small(Icons.edit_outlined, onDiscount),
                  const SizedBox(width: 4),
                  _small(Icons.delete_outline, onRemove, color: AppColors.danger),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
