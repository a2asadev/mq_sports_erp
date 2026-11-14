import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/core/utils/category_tree.dart';
import 'package:mq_sports_erp/core/utils/error_text.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/pos/pos_payment_dialog.dart';
import 'package:mq_sports_erp/widgets/party_picker.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';
import 'package:mq_sports_erp/widgets/receipt_actions.dart';

String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// The counter: find a product, tap it, take payment, give the receipt.
///
/// On a wide screen the products are on the left and the sale on the right; on
/// a phone they are two tabs. Barcodes are optional: the search box also finds
/// a product by barcode or SKU, so a scanner that types (most of them do) and
/// the Enter key add the item at once.
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
                trailing: Text('Rs ${_fmt(v.salePrice)}', style: Theme.of(context).textTheme.titleMedium),
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
    return customers.where((CustomerModel c) => c.id == walkInCustomerId).firstOrNull;
  }

  Future<void> _chooseCustomer() async {
    final List<PartyListItem> items = ref.read(customerItemsProvider);
    final PartyPickResult? picked = await showPartyPickerSheet(
      context,
      title: 'Customer',
      partyType: PartyType.customer,
      items: items.where((PartyListItem i) => i.id != walkInCustomerId && i.isActive).toList(),
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
    final CustomerModel? customer = cart.customer ?? _walkIn();
    if (customer == null) {
      _message('The walk-in customer is not on this device yet. Sync once, then try again.');
      return;
    }
    final PosPaymentResult? payment =
        await showPosPaymentDialog(context, total: cart.total, allowCredit: cart.customer != null);
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
      shopPhone: shop.phone,
      cashier: me == null ? '' : (me.displayName.isNotEmpty ? me.displayName : me.email),
      change: payment.change,
    );
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Sale complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${order.orderNo}  ·  Rs ${_fmt(order.totalAmount)}', style: Theme.of(context).textTheme.titleMedium),
            if (payment.change > 0.005)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Give change: Rs ${_fmt(payment.change)}', style: Theme.of(context).textTheme.headlineSmall),
              ),
            if (receipt.due > 0.005)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Balance due: Rs ${_fmt(receipt.due)}'),
              ),
            const SizedBox(height: 16),
            ReceiptActions(receipt: receipt, phone: named?.phone ?? ''),
          ],
        ),
        actions: <Widget>[
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('New sale')),
        ],
      ),
    );
    if (mounted) {
      _searchFocus.requestFocus();
    }
  }

  // ---- layout ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> productsAsync = ref.watch(productsProvider);
    final List<ProductModel> products = productsAsync.valueOrNull ?? <ProductModel>[];
    final PosCart cart = ref.watch(posCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: <Widget>[
          if (!cart.isEmpty)
            TextButton.icon(
              onPressed: () => ref.read(posCartProvider.notifier).clear(),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear sale'),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final bool wide = box.maxWidth >= 840;
          final Widget catalog = _Catalog(
            search: _search,
            focus: _searchFocus,
            query: _query,
            categoryId: _categoryId,
            products: products,
            loading: productsAsync.isLoading && products.isEmpty,
            onQuery: (String q) => setState(() => _query = q),
            onCategory: (String id) => setState(() => _categoryId = id),
            onSubmit: () => _submitSearch(products),
            onTap: _addProduct,
          );
          final Widget sale = _SalePanel(
            charging: _charging,
            onCustomer: _chooseCustomer,
            onCharge: _charge,
          );
          if (wide) {
            return Row(
              children: <Widget>[
                Expanded(flex: 3, child: catalog),
                const VerticalDivider(width: 1),
                SizedBox(width: 400, child: sale),
              ],
            );
          }
          return Column(
            children: <Widget>[
              Expanded(child: _showCart ? sale : catalog),
              NavigationBar(
                selectedIndex: _showCart ? 1 : 0,
                onDestinationSelected: (int i) => setState(() => _showCart = i == 1),
                destinations: <Widget>[
                  const NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Products'),
                  NavigationDestination(
                    icon: Badge(isLabelVisible: cart.units > 0, label: Text('${cart.units}'), child: const Icon(Icons.shopping_bag_outlined)),
                    label: cart.isEmpty ? 'Sale' : 'Sale · Rs ${_fmt(cart.total)}',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Catalog extends ConsumerWidget {
  const _Catalog({
    required this.search,
    required this.focus,
    required this.query,
    required this.categoryId,
    required this.products,
    required this.loading,
    required this.onQuery,
    required this.onCategory,
    required this.onSubmit,
    required this.onTap,
  });

  final TextEditingController search;
  final FocusNode focus;
  final String query;
  final String categoryId;
  final List<ProductModel> products;
  final bool loading;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final VoidCallback onSubmit;
  final ValueChanged<ProductModel> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CategoryModel> categories = (ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[])
        .where((CategoryModel c) => c.isActive)
        .toList()
      ..sort((CategoryModel a, CategoryModel b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final Map<String, int> stock = ref.watch(stockOnHandProvider);
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

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: search,
            focusNode: focus,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search, or scan barcode / SKU and press Enter',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        search.clear();
                        onQuery('');
                      },
                    ),
            ),
            onChanged: onQuery,
            onSubmitted: (_) => onSubmit(),
          ),
        ),
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
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 170,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: shown.length,
                      itemBuilder: (BuildContext context, int i) {
                        final ProductModel p = shown[i];
                        final List<VariantModel> active = p.variants.where((VariantModel v) => v.isActive).toList();
                        final int onHand = active.fold<int>(0, (int s, VariantModel v) => s + (stock[v.id] ?? 0));
                        final double low = active.map((VariantModel v) => v.salePrice).reduce((double a, double b) => a < b ? a : b);
                        final double high = active.map((VariantModel v) => v.salePrice).reduce((double a, double b) => a > b ? a : b);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onHand > 0 ? () => onTap(p) : null,
                            child: Opacity(
                              opacity: onHand > 0 ? 1 : 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Expanded(
                                    child: NetworkPhoto(
                                      url: p.images.isEmpty ? '' : p.images.first.mediumUrl,
                                      placeholder: Icons.inventory_2_outlined,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                                        Text(
                                          low == high ? 'Rs ${_fmt(low)}' : 'Rs ${_fmt(low)} - ${_fmt(high)}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          onHand > 0 ? '$onHand in stock' : 'Out of stock',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: onHand > 0 ? null : Theme.of(context).colorScheme.error,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _SalePanel extends ConsumerWidget {
  const _SalePanel({required this.charging, required this.onCustomer, required this.onCharge});

  final bool charging;
  final VoidCallback onCustomer;
  final VoidCallback onCharge;

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
          decoration: const InputDecoration(labelText: 'Amount', prefixText: 'Rs ', border: OutlineInputBorder()),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PosCart cart = ref.watch(posCartProvider);
    final PosCartNotifier notifier = ref.read(posCartProvider.notifier);
    final Map<String, int> stock = ref.watch(stockOnHandProvider);
    final ThemeData theme = Theme.of(context);
    final bool canSell = ref.watch(canCreateOrdersProvider);

    return Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(cart.customer?.name ?? 'Walk-in customer'),
          subtitle: Text(cart.customer == null ? 'Pays in full now' : 'May pay now or later'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onCustomer,
        ),
        const Divider(height: 1),
        Expanded(
          child: cart.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Tap a product to add it to the sale.', textAlign: TextAlign.center),
                  ),
                )
              : ListView.separated(
                  itemCount: cart.lines.length,
                  separatorBuilder: (BuildContext c, int i) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int i) {
                    final PosLine l = cart.lines[i];
                    final int available = stock[l.variantId] ?? 0;
                    return ListTile(
                      dense: true,
                      title: Text(l.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${l.variantLabel} · Rs ${_fmt(l.unitPrice)}${l.discount > 0 ? ' · discount ${_fmt(l.discount)}' : ''}',
                      ),
                      onTap: () => _editDiscount(context, ref, line: l),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => notifier.set(cart.setQuantity(l.variantId, l.quantity - 1)),
                          ),
                          Text('${l.quantity}', style: theme.textTheme.titleMedium),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: l.quantity + 1 > available
                                ? null
                                : () => notifier.set(cart.setQuantity(l.variantId, l.quantity + 1)),
                          ),
                          SizedBox(width: 72, child: Text('Rs ${_fmt(l.total)}', textAlign: TextAlign.end)),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _row('Items (${cart.units})', 'Rs ${_fmt(cart.subtotal)}'),
              InkWell(
                onTap: cart.isEmpty ? null : () => _editDiscount(context, ref),
                child: _row(
                  'Discount on sale',
                  cart.effectiveOrderDiscount > 0 ? '- Rs ${_fmt(cart.effectiveOrderDiscount)}' : 'Add',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total', style: theme.textTheme.titleLarge),
                  Text('Rs ${_fmt(cart.total)}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: (cart.isEmpty || charging || !canSell) ? null : onCharge,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                icon: charging
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.payments_outlined),
                label: Text(cart.isEmpty ? 'Charge' : 'Charge Rs ${_fmt(cart.total)}'),
              ),
              if (!canSell)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Your login cannot make sales.', textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text(label), Text(value)]),
      );
}
