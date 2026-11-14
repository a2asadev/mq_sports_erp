import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/erp_module.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/module_registry_provider.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/screens/dashboard/dashboard_panel.dart';
import 'package:mq_sports_erp/widgets/logout_button.dart';
import 'package:mq_sports_erp/widgets/online_status_chip.dart';
import 'package:mq_sports_erp/widgets/sync_status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ErpModule> modules = ref.watch(visibleModulesProvider);
    final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('MQ Sports ERP'),
            if (user != null)
              Text(
                '${user.displayName.isNotEmpty ? user.displayName : user.email}'
                ' · ${user.role.label}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: <Widget>[
          if (ref.watch(dataModeProvider).isOnline)
            const OnlineStatusChip()
          else
            const SyncStatusChip(),
          const LogoutButton(),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // Only admins and managers see anything here.
          const SliverToBoxAdapter(child: DashboardPanel()),
          if (modules.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No modules available for your role yet.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: modules.length,
                itemBuilder: (BuildContext context, int index) {
                  final ErpModule module = modules[index];
                  return Card(
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: module.builder),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(module.icon, size: 40),
                          const SizedBox(height: 8),
                          Text(module.title),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
