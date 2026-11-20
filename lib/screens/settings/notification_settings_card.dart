import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/notify/notification_alerts.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/notification_alert_providers.dart';

/// Settings > Notifications: the sound, the desktop notifications, and a test of both.
/// These are choices of this device (they are kept here, not on the server).
class NotificationSettingsCard extends ConsumerStatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  ConsumerState<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends ConsumerState<NotificationSettingsCard> {
  /// The platform's answer when the person last turned desktop notifications on.
  bool _blocked = false;
  String _testMessage = '';

  Future<void> _setSystem(bool on) async {
    final NotificationAlerts alerts = ref.read(notificationAlertsProvider);
    await ref.read(alertPrefsProvider.notifier).setSystem(on);
    if (!on) {
      setState(() => _blocked = false);
      return;
    }
    // The browser asks the person now, because they just tapped.
    final bool allowed = await alerts.requestSystemPermission();
    if (mounted) {
      setState(() => _blocked = !allowed && alerts.systemSupported);
    }
  }

  Future<void> _test() async {
    final AppLocalizations l10n = context.l10n;
    final AlertTestResult result = await ref.read(notificationAlertsProvider).sendTest();
    if (!mounted) {
      return;
    }
    setState(() {
      switch (result) {
        case AlertTestResult.sent:
          _testMessage = l10n.notifSettingsTestSent;
        case AlertTestResult.systemOff:
          _testMessage = l10n.notifSettingsTestSoundOnly;
        case AlertTestResult.notAllowed:
          _testMessage = l10n.notifSettingsTestNotAllowed;
        case AlertTestResult.unsupported:
          _testMessage = l10n.notifSettingsUnsupported;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AlertPrefs prefs = ref.watch(alertPrefsProvider);
    final NotificationAlerts alerts = ref.watch(notificationAlertsProvider);
    final AppLocalizations l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SwitchListTile(
              value: prefs.sound,
              onChanged: (bool on) => ref.read(alertPrefsProvider.notifier).setSound(on),
              title: Text(l10n.notifSettingsSound),
              subtitle: Text(l10n.notifSettingsSoundHint),
              secondary: const Icon(Icons.volume_up_outlined),
            ),
            if (alerts.systemSupported)
              SwitchListTile(
                value: prefs.system,
                onChanged: _setSystem,
                title: Text(l10n.notifSettingsSystem),
                subtitle: Text(l10n.notifSettingsSystemHint),
                secondary: const Icon(Icons.desktop_windows_outlined),
              )
            else
              ListTile(
                leading: const Icon(Icons.desktop_access_disabled_outlined),
                title: Text(l10n.notifSettingsUnsupported),
              ),
            if (_blocked)
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                child: Text(l10n.notifSettingsBlocked, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _test,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(l10n.notifSettingsTest),
                  ),
                  if (_testMessage.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 12),
                    Expanded(child: Text(_testMessage, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
