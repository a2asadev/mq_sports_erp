import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/utils/currency.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/core/utils/page_stats.dart';
import 'package:mq_sports_erp/widgets/stat_strip.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';

/// Searchable, filterable list of vendors or customers. Used by the vendor
/// and customer screens (as cards) and by the pickers (as a compact list).
class PartyListView extends StatefulWidget {
  const PartyListView({
    super.key,
    required this.items,
    required this.partyType,
    required this.typeOptions,
    required this.onSelected,
    this.selectedId,
    this.hideInactiveByDefault = false,
    this.showCreditFilter = false,
    this.scrollController,
    this.autofocusSearch = false,
    this.emptyText = 'Nothing here yet.',
    this.asCards = false,
  });

  final List<PartyListItem> items;
  final PartyType partyType;

  /// Type filter chips as (typeKey, label).
  final List<MapEntry<String, String>> typeOptions;
  final ValueChanged<PartyListItem> onSelected;
  final String? selectedId;
  final bool hideInactiveByDefault;
  final bool showCreditFilter;
  final ScrollController? scrollController;
  final bool autofocusSearch;
  final String emptyText;

  /// Show a grid of cards (the screens) instead of a compact list (the pickers).
  final bool asCards;

  @override
  State<PartyListView> createState() => _PartyListViewState();
}

class _PartyListViewState extends State<PartyListView> {
  String _query = '';
  String? _typeKey;
  bool _onlyWithBalance = false;
  bool _onlyOverLimit = false;
  late bool _showInactive;

  @override
  void initState() {
    super.initState();
    _showInactive = !widget.hideInactiveByDefault;
  }

  List<PartyListItem> _filtered() {
    final String query = _query.trim().toLowerCase();
    final List<PartyListItem> result = widget.items.where((PartyListItem item) {
      if (!_showInactive && !item.isActive) {
        return false;
      }
      if (_typeKey != null && item.typeKey != _typeKey) {
        return false;
      }
      if (_onlyWithBalance && !item.hasBalance) {
        return false;
      }
      if (_onlyOverLimit && !item.isOverLimit) {
        return false;
      }
      return query.isEmpty || item.searchText.contains(query);
    }).toList()
      ..sort((PartyListItem a, PartyListItem b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return result;
  }

  List<StatItem> _stats() {
    final PartyStats stats = computePartyStats(widget.items);
    final bool customers = widget.partyType == PartyType.customer;
    final String noun = customers ? 'Customers' : 'Vendors';
    return <StatItem>[
      StatItem(
        icon: customers ? Icons.groups_outlined : Icons.local_shipping_outlined,
        color: AppColors.primary,
        label: 'Total ${noun.toLowerCase()}',
        value: '${stats.total}',
      ),
      StatItem(
        icon: Icons.check_circle_outline,
        color: AppColors.teal,
        label: 'Active',
        value: '${stats.active}',
        caption: stats.total > stats.active ? '${stats.total - stats.active} inactive' : '',
      ),
      StatItem(
        icon: Icons.account_balance_wallet_outlined,
        color: stats.outstanding > 0.005 ? AppColors.amber : AppColors.textMuted,
        label: customers ? 'To collect' : 'To pay',
        value: formatMoney(stats.outstanding),
        caption: '${stats.withBalance} with a balance',
      ),
      if (customers)
        StatItem(
          icon: Icons.warning_amber_rounded,
          color: stats.overLimit > 0 ? AppColors.danger : AppColors.textMuted,
          label: 'Over credit limit',
          value: '${stats.overLimit}',
        )
      else
        StatItem(
          icon: Icons.paid_outlined,
          color: AppColors.sky,
          label: 'With a balance',
          value: '${stats.withBalance}',
        ),
    ];
  }

  Widget _chipPadding(Widget chip) =>
      Padding(padding: const EdgeInsets.only(right: 8), child: chip);

  Widget _list(List<PartyListItem> visible, ThemeData theme) {
    return ListView.separated(
      controller: widget.scrollController,
      itemCount: visible.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final PartyListItem item = visible[index];
        return ListTile(
          selected: item.id == widget.selectedId,
          leading: PhotoAvatar(url: item.photoUrl, label: item.title),
          title: Text(item.title),
          subtitle: Text(
            <String>[
              item.typeLabel,
              if (item.subtitle.isNotEmpty) item.subtitle,
              if (item.phone.isNotEmpty) item.phone,
              if (!item.isActive) 'Inactive',
            ].join(' · '),
          ),
          trailing: item.hasBalance
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      formatAmount(item.balance.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: item.isOverLimit ? theme.colorScheme.error : null,
                      ),
                    ),
                    Text(
                      item.isOverLimit ? 'Over limit' : widget.partyType.balanceCaption(item.balance),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                )
              : Text('Settled', style: theme.textTheme.bodySmall),
          onTap: () => widget.onSelected(item),
        );
      },
    );
  }

  Widget _cards(List<PartyListItem> visible) {
    return GridView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 216,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: visible.length,
      itemBuilder: (BuildContext context, int index) => PartyCard(
        item: visible[index],
        partyType: widget.partyType,
        onTap: () => widget.onSelected(visible[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<PartyListItem> visible = _filtered();

    return Column(
      children: <Widget>[
        if (widget.asCards) StatStrip(items: _stats()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.asCards ? 420 : double.infinity),
              child: TextField(
                autofocus: widget.autofocusSearch,
                decoration: const InputDecoration(
                  hintText: 'Search name, phone, city…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              _chipPadding(ChoiceChip(
                label: const Text('All'),
                selected: _typeKey == null,
                onSelected: (bool _) => setState(() => _typeKey = null),
              )),
              for (final MapEntry<String, String> option in widget.typeOptions)
                _chipPadding(ChoiceChip(
                  label: Text(option.value),
                  selected: _typeKey == option.key,
                  onSelected: (bool selected) => setState(() => _typeKey = selected ? option.key : null),
                )),
              _chipPadding(FilterChip(
                label: const Text('With balance'),
                selected: _onlyWithBalance,
                onSelected: (bool value) => setState(() => _onlyWithBalance = value),
              )),
              if (widget.showCreditFilter)
                _chipPadding(FilterChip(
                  label: const Text('Over credit limit'),
                  selected: _onlyOverLimit,
                  onSelected: (bool value) => setState(() => _onlyOverLimit = value),
                )),
              _chipPadding(FilterChip(
                label: const Text('Show inactive'),
                selected: _showInactive,
                onSelected: (bool value) => setState(() => _showInactive = value),
              )),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(widget.items.isEmpty
                      ? widget.emptyText
                      : 'No matches. Try changing the search or filters.'),
                )
              : (widget.asCards ? _cards(visible) : _list(visible, theme)),
        ),
      ],
    );
  }
}

/// One vendor or customer as a card: photo, name, type, contact, and how much
/// is owed either way (with a credit-limit bar for customers that have one).
class PartyCard extends StatelessWidget {
  const PartyCard({super.key, required this.item, required this.partyType, required this.onTap});

  final PartyListItem item;
  final PartyType partyType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool over = item.isOverLimit;
    // Money owed to us (customer) or by us (vendor) is highlighted; a
    // settled party is calm.
    final Color balanceColor = over
        ? AppColors.danger
        : (item.hasBalance ? AppColors.navy : AppColors.textMuted);
    final double usedShare = item.creditLimit > 0
        ? (item.balance / item.creditLimit).clamp(0.0, 1.0).toDouble()
        : 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: item.isActive ? 1 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    PhotoAvatar(url: item.photoUrl, label: item.title, radius: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: <Widget>[
                              _Pill(text: item.typeLabel, color: AppColors.sky),
                              if (!item.isActive) ...<Widget>[
                                const SizedBox(width: 6),
                                const _Pill(text: 'Inactive', color: AppColors.textMuted),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Detail(icon: Icons.phone_outlined, text: item.phone.isEmpty ? 'No phone' : item.phone),
                const SizedBox(height: 4),
                _Detail(
                  icon: Icons.place_outlined,
                  text: item.subtitle.isEmpty ? 'No city' : item.subtitle,
                ),
                const Spacer(),
                const Divider(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        over ? 'Over credit limit' : partyType.balanceCaption(item.balance),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: over ? AppColors.danger : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      item.hasBalance ? formatMoney(item.balance.abs()) : MoneyFormat.withSymbol('0'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: balanceColor),
                    ),
                  ],
                ),
                if (item.creditLimit > 0) ...<Widget>[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: usedShare,
                      minHeight: 4,
                      backgroundColor: AppColors.mutedFill,
                      color: over ? AppColors.danger : AppColors.teal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      );
}
