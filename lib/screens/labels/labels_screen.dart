import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/label_pdf.dart';
import 'package:a2_stocks/core/utils/label_sheet.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';

class _Row {
  const _Row(this.product, this.variant);

  final ProductModel product;
  final VariantModel variant;
}

String _sizeLabel(AppLocalizations l10n, LabelSpec s) {
  String mm(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  return s.isSheet
      ? l10n.labelsSizeSheet(s.perPage, '${s.columns} × ${s.rows}')
      : l10n.labelsSizeRoll('${mm(s.pageWidthMm)} × ${mm(s.pageHeightMm)}');
}

/// Price labels with a bar code: pick how many labels each item needs, a size (a label roll, or a sheet of sticky
/// labels on A4) and what to show, then print or share the PDF. An item without a barcode can use its SKU as the bar
/// code, so barcodes stay optional. Works offline.
class LabelsScreen extends ConsumerStatefulWidget {
  const LabelsScreen({super.key});

  @override
  ConsumerState<LabelsScreen> createState() => _LabelsScreenState();
}

class _LabelsScreenState extends ConsumerState<LabelsScreen> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _skip = TextEditingController();
  final Map<String, TextEditingController> _copies = <String, TextEditingController>{};
  LabelSpec _spec = LabelSpec.roll50x30;
  bool _name = true;
  bool _price = true;
  bool _sku = false;
  bool _useSku = true;
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    _skip.dispose();
    for (final TextEditingController c in _copies.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String variantId) => _copies.putIfAbsent(variantId, () => TextEditingController());

  int _count(String variantId) => int.tryParse(_copies[variantId]?.text.trim() ?? '') ?? 0;

  List<_Row> _rows(List<ProductModel> products) {
    final String q = _search.text.trim().toLowerCase();
    return <_Row>[
      for (final ProductModel p in products)
        if (p.isActive)
          for (final VariantModel v in p.variants)
            if (v.isActive && (q.isEmpty || p.name.toLowerCase().contains(q) || v.sku.toLowerCase().contains(q) || v.barcode.toLowerCase().contains(q)))
              _Row(p, v),
    ];
  }

  List<LabelItem> _items(List<ProductModel> products) => <LabelItem>[
        for (final ProductModel p in products)
          for (final VariantModel v in p.variants)
            if (_count(v.id) > 0)
              LabelItem(
                name: p.name,
                variantLabel: v.label,
                sku: v.sku,
                price: v.salePrice,
                code: v.barcode.trim().isNotEmpty ? v.barcode.trim() : (_useSku ? v.sku : ''),
                copies: _count(v.id),
              ),
      ];

  int get _skipCount => int.tryParse(_skip.text.trim()) ?? 0;

  Future<void> _run(Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptActionsThatDidNotWork)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = ref.watch(productsProvider).valueOrNull ?? <ProductModel>[];
    final List<_Row> rows = _rows(products);
    final List<LabelItem> items = _items(products);
    final int labels = items.fold<int>(0, (int s, LabelItem i) => s + i.copies);
    final int pages = _spec.isSheet ? _spec.pagesFor(labels, skip: _skipCount % _spec.perPage) : labels;
    final LabelOptions options = LabelOptions(showName: _name, showPrice: _price, showSku: _sku);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moduleLabels),
        actions: <Widget>[
          TextButton(
            onPressed: () => setState(() {
              for (final _Row r in rows) {
                _controller(r.variant.id).text = '1';
              }
            }),
            child: Text(context.l10n.labelsOneEach),
          ),
          TextButton(
            onPressed: () => setState(() {
              for (final TextEditingController c in _copies.values) {
                c.clear();
              }
            }),
            child: Text(context.l10n.labelsClear),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _search,
                  onChanged: (String _) => setState(() {}),
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l10n.labelsSearch, border: const OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _spec.id,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: context.l10n.labelsSize, border: const OutlineInputBorder(), isDense: true),
                        items: <DropdownMenuItem<String>>[
                          for (final LabelSpec s in LabelSpec.presets) DropdownMenuItem<String>(value: s.id, child: Text(_sizeLabel(context.l10n, s), overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (String? id) => setState(() => _spec = LabelSpec.byId(id)),
                      ),
                    ),
                    if (_spec.isSheet) ...<Widget>[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _skip,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          onChanged: (String _) => setState(() {}),
                          decoration: InputDecoration(labelText: context.l10n.labelsSkip, border: const OutlineInputBorder(), isDense: true),
                        ),
                      ),
                    ],
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilterChip(label: Text(context.l10n.labelsShowName), selected: _name, onSelected: (bool v) => setState(() => _name = v)),
                    FilterChip(label: Text(context.l10n.labelsShowPrice), selected: _price, onSelected: (bool v) => setState(() => _price = v)),
                    FilterChip(label: Text(context.l10n.labelsShowSku), selected: _sku, onSelected: (bool v) => setState(() => _sku = v)),
                    FilterChip(label: Text(context.l10n.labelsUseSku), selected: _useSku, onSelected: (bool v) => setState(() => _useSku = v)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? Center(child: Text(context.l10n.labelsNoItems))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: rows.length,
                    itemBuilder: (BuildContext context, int i) {
                      final _Row r = rows[i];
                      final bool hasCode = r.variant.barcode.trim().isNotEmpty;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${r.product.name} · ${r.variant.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      '${formatMoney(r.variant.salePrice)} · ${hasCode ? r.variant.barcode : (_useSku ? context.l10n.labelsSkuCode : context.l10n.labelsNoCode)}',
                                      style: TextStyle(color: hasCode || _useSku ? AppColors.textMuted : AppColors.amber, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 78,
                                child: TextField(
                                  controller: _controller(r.variant.id),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (String _) => setState(() {}),
                                  decoration: InputDecoration(labelText: context.l10n.labelsCopies, border: const OutlineInputBorder(), isDense: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Material(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(labels == 0 ? context.l10n.labelsNothing : context.l10n.labelsSummary(labels, pages), style: theme.textTheme.titleSmall)),
                  OutlinedButton.icon(
                    onPressed: _busy || labels == 0
                        ? null
                        : () => _run(() async => Printing.sharePdf(bytes: await buildLabelsPdf(items, _spec, options: options, skip: _skipCount), filename: 'labels.pdf')),
                    icon: const Icon(Icons.ios_share),
                    label: Text(context.l10n.labelsShare),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _busy || labels == 0
                        ? null
                        : () => _run(() async {
                              await Printing.layoutPdf(name: context.l10n.moduleLabels, onLayout: (_) => buildLabelsPdf(items, _spec, options: options, skip: _skipCount));
                            }),
                    icon: const Icon(Icons.print_outlined),
                    label: Text(context.l10n.labelsPrint),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
