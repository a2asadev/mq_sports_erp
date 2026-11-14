import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';

/// The web app's counterpart of the sync chip: there is nothing to upload or
/// download (every action goes straight to the server), so it only says
/// whether the browser is connected.
class OnlineStatusChip extends ConsumerWidget {
  const OnlineStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
        size: 18,
      ),
      label: Text(isOnline ? 'Online' : 'No connection'),
      backgroundColor: isOnline ? null : colors.errorContainer,
      visualDensity: VisualDensity.compact,
    );
  }
}
