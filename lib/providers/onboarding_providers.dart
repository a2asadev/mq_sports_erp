import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, per person and device, that the welcome guide was shown.
class OnboardingStore {
  const OnboardingStore();

  /// Bump the number to show a changed guide to everybody again.
  static const int version = 1;

  static String _key(String userId) => 'onboarding_seen_v${version}_$userId';

  Future<bool> hasSeen(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key(userId)) ?? false;
    } catch (_) {
      // If the flag cannot be read, do not nag: treat it as seen.
      return true;
    }
  }

  Future<void> markSeen(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key(userId), true);
    } catch (_) {
      // Worst case the guide shows once more.
    }
  }
}

final Provider<OnboardingStore> onboardingStoreProvider =
    Provider<OnboardingStore>((Ref ref) => const OnboardingStore());
