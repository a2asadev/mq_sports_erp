import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/model_labels.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/providers/onboarding_providers.dart';
import 'package:a2_stocks/screens/onboarding/onboarding_content.dart';

/// The welcome guide: a few pages for the person's role, shown the first time
/// they sign in on this device and again from Settings.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  List<OnboardingStep> get _steps => onboardingStepsFor(widget.role, context.l10n);

  bool get _last => _page == _steps.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_last) {
      Navigator.of(context).pop(true);
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.l10n.onboardingWelcome(widget.role.label)),
        actions: <Widget>[
          if (!_last)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.onboardingSkip),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (int page) => setState(() => _page = page),
                itemBuilder: (BuildContext context, int index) {
                  final OnboardingStep step = _steps[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(step.icon, size: 36, color: theme.colorScheme.onPrimaryContainer),
                            ),
                            const SizedBox(height: 24),
                            Text(step.title, style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 12),
                            Text(step.body, style: theme.textTheme.bodyLarge),
                            if (step.points.isNotEmpty) const SizedBox(height: 12),
                            for (final String point in step.points)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4, right: 8),
                                      child: Icon(Icons.check_circle_outline, size: 18),
                                    ),
                                    Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < _steps.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _page ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_last ? context.l10n.onboardingGetStarted : context.l10n.onboardingNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the guide once per person on this device, right after they reach the
/// home screen. It marks the guide as seen when it is finished or skipped.
class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key, required this.user, required this.child});

  final UserModel? user;
  final Widget child;

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  String _checkedFor = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShow();
  }

  @override
  void didUpdateWidget(OnboardingGate old) {
    super.didUpdateWidget(old);
    _maybeShow();
  }

  void _maybeShow() {
    final UserModel? user = widget.user;
    if (user == null || !user.isActive || _checkedFor == user.id) {
      return;
    }
    _checkedFor = user.id;
    final OnboardingStore store = ref.read(onboardingStoreProvider);
    store.hasSeen(user.id).then((bool seen) async {
      if (seen || !mounted) {
        return;
      }
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (BuildContext context) => OnboardingScreen(role: user.role),
        ),
      );
      await store.markSeen(user.id);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
