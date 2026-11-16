import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A sale parked at the counter so the next customer can be served; it is
/// picked up again later exactly as it was (lines, discounts, customer).
class HeldSale {
  HeldSale({
    String? id,
    DateTime? heldAt,
    required this.cart,
  })  : id = id ?? const Uuid().v4(),
        heldAt = heldAt ?? DateTime.now();

  final String id;
  final DateTime heldAt;
  final PosCart cart;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'heldAt': heldAt.toIso8601String(),
        'orderDiscount': cart.orderDiscount,
        'customer': cart.customer?.toMap(),
        'lines': <Map<String, dynamic>>[for (final PosLine l in cart.lines) l.toMap()],
      };

  /// Null when the stored entry is unreadable (it is then dropped).
  static HeldSale? fromMap(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    try {
      final Object? customer = raw['customer'];
      final Object? lines = raw['lines'];
      return HeldSale(
        id: raw['id'] as String?,
        heldAt: DateTime.tryParse(raw['heldAt'] as String? ?? ''),
        cart: PosCart(
          lines: <PosLine>[
            if (lines is List<Object?>)
              for (final Object? l in lines)
                if (l is Map<String, dynamic>) PosLine.fromMap(l),
          ],
          orderDiscount: (raw['orderDiscount'] as num?)?.toDouble() ?? 0,
          customer: customer is Map<String, dynamic> ? CustomerModel.fromMap(customer) : null,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

/// The sales on hold on this device, newest first. They are kept in the
/// device's preferences so a restart does not lose them; they are never sent
/// to the server (nothing has been sold yet).
class HeldSalesNotifier extends Notifier<List<HeldSale>> {
  static const String storageKey = 'pos_held_sales';

  @override
  List<HeldSale> build() {
    _load();
    return const <HeldSale>[];
  }

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? text = prefs.getString(storageKey);
      if (text == null || text.isEmpty) {
        return;
      }
      final Object? decoded = jsonDecode(text);
      if (decoded is! List<Object?>) {
        return;
      }
      final List<HeldSale> stored = <HeldSale>[
        for (final Object? e in decoded)
          if (HeldSale.fromMap(e) != null) HeldSale.fromMap(e)!,
      ];
      // Sales held before the load finished stay on top.
      state = <HeldSale>[...state, ...stored.where((HeldSale s) => !state.any((HeldSale t) => t.id == s.id))];
    } catch (_) {
      // Unreadable storage: start with none.
    }
  }

  Future<void> _save() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode(<Map<String, dynamic>>[for (final HeldSale s in state) s.toMap()]),
      );
    } catch (_) {
      // The held sales still work for this session.
    }
  }

  /// Parks [cart] (ignored when it is empty).
  HeldSale? hold(PosCart cart) {
    if (cart.isEmpty) {
      return null;
    }
    final HeldSale held = HeldSale(cart: cart);
    state = <HeldSale>[held, ...state];
    _save();
    return held;
  }

  void remove(String id) {
    state = state.where((HeldSale s) => s.id != id).toList();
    _save();
  }
}

final NotifierProvider<HeldSalesNotifier, List<HeldSale>> heldSalesProvider =
    NotifierProvider<HeldSalesNotifier, List<HeldSale>>(HeldSalesNotifier.new);
