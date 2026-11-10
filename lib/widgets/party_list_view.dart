import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/party_list_item.dart';

/// Searchable, filterable list of vendors or customers. Used by the vendor
/// and customer screens and by the pickers.
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

  Widget _chipPadding(Widget chip) =>
      Padding(padding: const EdgeInsets.only(right: 8), child: chip);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<PartyListItem> visible = _filtered();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            autofocus: widget.autofocusSearch,
            decoration: const InputDecoration(
              hintText: 'Search name, phone, city…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (String value) => setState(() => _query = value),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  onSelected: (bool selected) =>
                      setState(() => _typeKey = selected ? option.key : null),
                )),
              _chipPadding(FilterChip(
                label: const Text('With balance'),
                selected: _onlyWithBalance,
                onSelected: (bool value) =>
                    setState(() => _onlyWithBalance = value),
              )),
              if (widget.showCreditFilter)
                _chipPadding(FilterChip(
                  label: const Text('Over credit limit'),
                  selected: _onlyOverLimit,
                  onSelected: (bool value) =>
                      setState(() => _onlyOverLimit = value),
                )),
              _chipPadding(FilterChip(
                label: const Text('Show inactive'),
                selected: _showInactive,
                onSelected: (bool value) =>
                    setState(() => _showInactive = value),
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
              : ListView.separated(
                  controller: widget.scrollController,
                  itemCount: visible.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final PartyListItem item = visible[index];
                    return ListTile(
                      selected: item.id == widget.selectedId,
                      leading: CircleAvatar(
                        child: Text(item.title.isEmpty
                            ? '?'
                            : item.title.substring(0, 1).toUpperCase()),
                      ),
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
                                    color: item.isOverLimit
                                        ? theme.colorScheme.error
                                        : null,
                                  ),
                                ),
                                Text(
                                  item.isOverLimit
                                      ? 'Over limit'
                                      : widget.partyType
                                          .balanceCaption(item.balance),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            )
                          : Text('Settled', style: theme.textTheme.bodySmall),
                      onTap: () => widget.onSelected(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
