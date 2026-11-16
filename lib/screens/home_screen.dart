import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mq_sports_erp/core/erp_module.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/providers/dashboard_providers.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/module_registry_provider.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/dashboard/dashboard_page.dart';
import 'package:mq_sports_erp/screens/onboarding/onboarding_screen.dart';
import 'package:mq_sports_erp/widgets/business_brand.dart';
import 'package:mq_sports_erp/widgets/logout_button.dart';
import 'package:mq_sports_erp/widgets/online_status_chip.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';
import 'package:mq_sports_erp/widgets/sync_status_chip.dart';

/// Id of the dashboard entry in the navigation (it is not an [ErpModule]).
const String _dashboardId = 'dashboard';

/// Navigation groups, in the order they appear.
const List<String> _groupOrder = <String>['Main', 'Inventory', 'Sales', 'Purchasing', 'System'];

/// The app shell: a side bar on wide screens (desktop, web, tablets) and a
/// drawer on phones, with the chosen page beside or below the top bar. The POS
/// opens full screen, like a till.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selected = _dashboardId;

  /// The wide side bar shows icons only (remembered on this device).
  bool _collapsed = false;

  static const String _collapsedKey = 'nav_collapsed';

  @override
  void initState() {
    super.initState();
    _loadCollapsed();
  }

  Future<void> _loadCollapsed() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mounted && (prefs.getBool(_collapsedKey) ?? false)) {
        setState(() => _collapsed = true);
      }
    } catch (_) {
      // Without stored settings the side bar simply starts expanded.
    }
  }

  Future<void> _toggleCollapsed() async {
    setState(() => _collapsed = !_collapsed);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_collapsedKey, _collapsed);
    } catch (_) {
      // Not remembering the choice is harmless.
    }
  }

  void _open(ErpModule module, {required bool closeDrawer}) {
    if (closeDrawer) {
      Navigator.of(context).pop();
    }
    if (module.id == 'pos') {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: module.builder));
      return;
    }
    setState(() => _selected = module.id);
  }

  void _openDashboard({required bool closeDrawer}) {
    if (closeDrawer) {
      Navigator.of(context).pop();
    }
    setState(() => _selected = _dashboardId);
  }

  Widget _page(List<ErpModule> modules) {
    final ErpModule? module = modules.where((ErpModule m) => m.id == _selected).firstOrNull;
    if (module == null || module.id == 'pos') {
      return DashboardPage(onOpenModule: (ErpModule m) => _open(m, closeDrawer: false));
    }
    // Module screens bring their own app bar (title and actions); it is shown
    // as the page header under the shell's top bar.
    final ThemeData theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: AppColors.background,
          shape: const Border(),
          titleTextStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: KeyedSubtree(key: ValueKey<String>(module.id), child: module.builder(context)),
    );
  }

  String _title(List<ErpModule> modules) =>
      modules.where((ErpModule m) => m.id == _selected).firstOrNull?.title ?? 'Dashboard';

  @override
  Widget build(BuildContext context) {
    final List<ErpModule> modules = ref.watch(visibleModulesProvider);
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    final bool online = ref.watch(dataModeProvider).isOnline;
    final bool showDashboard = ref.watch(canViewDashboardProvider);

    return OnboardingGate(
      user: user,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final bool wide = box.maxWidth >= 1000;
          final Widget nav = _NavPanel(
            modules: modules,
            selected: _selected,
            showDashboard: showDashboard,
            onDashboard: () => _openDashboard(closeDrawer: !wide),
            onModule: (ErpModule m) => _open(m, closeDrawer: !wide),
            collapsed: wide && _collapsed,
            onToggle: wide ? _toggleCollapsed : null,
          );
          return Scaffold(
            key: _scaffoldKey,
            drawer: wide ? null : Drawer(width: 280, child: SafeArea(child: nav)),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (wide)
                  Container(
                    width: _collapsed ? 72 : 248,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(right: BorderSide(color: AppColors.border)),
                    ),
                    child: SafeArea(child: nav),
                  ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _TopBar(
                        title: _title(modules),
                        showMenu: !wide,
                        online: online,
                        user: user,
                        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                        onPos: modules.where((ErpModule m) => m.id == 'pos').firstOrNull == null
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: modules.firstWhere((ErpModule m) => m.id == 'pos').builder,
                                  ),
                                ),
                      ),
                      Expanded(child: _page(modules)),
                      const PoweredByFooter(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showMenu,
    required this.online,
    required this.user,
    required this.onMenu,
    required this.onPos,
  });

  final String title;
  final bool showMenu;
  final bool online;
  final UserModel? user;
  final VoidCallback onMenu;
  final VoidCallback? onPos;

  @override
  Widget build(BuildContext context) {
    final String name = user == null
        ? ''
        : (user!.displayName.isNotEmpty ? user!.displayName : user!.email);
    final bool narrow = MediaQuery.sizeOf(context).width < 600;
    return Material(
      color: AppColors.surface,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: <Widget>[
              if (showMenu) ...<Widget>[
                IconButton(onPressed: onMenu, icon: const Icon(Icons.menu), tooltip: 'Menu'),
                const SizedBox(width: 4),
                const Flexible(child: BusinessLockup(markHeight: 30)),
              ] else
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (online) const OnlineStatusChip() else const SyncStatusChip(),
              const SizedBox(width: 8),
              if (onPos != null)
                FilledButton.icon(
                  onPressed: onPos,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.point_of_sale, size: 18),
                  label: const Text('POS'),
                ),
              const SizedBox(width: 8),
              if (user != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PhotoAvatar(url: user!.photoUrl, label: name, radius: 18),
                    if (!narrow) ...<Widget>[
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            user!.role.label,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              const LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPanel extends StatelessWidget {
  const _NavPanel({
    required this.modules,
    required this.selected,
    required this.showDashboard,
    required this.onDashboard,
    required this.onModule,
    this.collapsed = false,
    this.onToggle,
  });

  final List<ErpModule> modules;
  final String selected;
  final bool showDashboard;
  final VoidCallback onDashboard;
  final ValueChanged<ErpModule> onModule;

  /// Icons only (the wide side bar, when the user collapsed it).
  final bool collapsed;

  /// Collapses or expands the side bar; null in the drawer.
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<ErpModule>> groups = <String, List<ErpModule>>{};
    for (final ErpModule m in modules) {
      groups.putIfAbsent(m.group, () => <ErpModule>[]).add(m);
    }
    final List<String> order = <String>[
      ..._groupOrder.where(groups.containsKey),
      ...groups.keys.where((String g) => !_groupOrder.contains(g)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _NavHeader(collapsed: collapsed, onToggle: onToggle),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(collapsed ? 10 : 12, 4, collapsed ? 10 : 12, 16),
            children: <Widget>[
              for (final String group in order) ...<Widget>[
                _GroupLabel(group, collapsed: collapsed),
                if (group == 'Main')
                  _NavItem(
                    icon: showDashboard ? Icons.space_dashboard_outlined : Icons.home_outlined,
                    label: showDashboard ? 'Dashboard' : 'Home',
                    selected: selected == _dashboardId,
                    collapsed: collapsed,
                    onTap: onDashboard,
                  ),
                for (final ErpModule m in groups[group]!)
                  _NavItem(
                    icon: m.icon,
                    label: m.title,
                    selected: selected == m.id,
                    collapsed: collapsed,
                    onTap: () => onModule(m),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NavHeader extends StatelessWidget {
  const _NavHeader({required this.collapsed, required this.onToggle});

  final bool collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final Widget toggle = onToggle == null
        ? const SizedBox.shrink()
        : IconButton(
            tooltip: collapsed ? 'Expand menu' : 'Collapse menu',
            visualDensity: VisualDensity.compact,
            onPressed: onToggle,
            icon: Icon(
              collapsed ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left,
              size: 20,
              color: AppColors.textMuted,
            ),
          );
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Column(
          children: <Widget>[
            const BusinessLogo(height: 34),
            const SizedBox(height: 6),
            toggle,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 8),
      child: Row(
        children: <Widget>[
          const Expanded(child: Align(alignment: Alignment.centerLeft, child: BusinessLockup(markHeight: 38))),
          toggle,
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {required this.collapsed});

  final String text;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Divider(height: 1),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.collapsed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.primary : AppColors.text;
    final Widget iconWidget =
        Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textMuted);
    final Widget item = Material(
      color: selected ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12, vertical: 10),
          child: collapsed
              ? Center(child: iconWidget)
              : Row(
                  children: <Widget>[
                    iconWidget,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: collapsed ? Tooltip(message: label, preferBelow: false, child: item) : item,
    );
  }
}
