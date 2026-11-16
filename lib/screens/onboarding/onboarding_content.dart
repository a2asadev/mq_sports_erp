import 'package:flutter/material.dart';
import 'package:a2_stocks/models/user_role.dart';

/// One page of the welcome guide.
class OnboardingStep {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
    this.points = const <String>[],
  });

  final IconData icon;
  final String title;
  final String body;

  /// Short bullet lines under the text.
  final List<String> points;
}

const OnboardingStep _offline = OnboardingStep(
  icon: Icons.cloud_sync_outlined,
  title: 'Works with or without internet',
  body: 'On phones and computers the app keeps working when the internet is down '
      'and sends your work to the shop\'s server when the connection returns. '
      'On the web version a connection is needed all the time.',
  points: <String>[
    'The chip at the top shows what is waiting to be sent.',
    'If the server refuses something, it appears on the Sync screen with the reason; you can retry or discard it.',
    'Sales made offline are always recorded, even if the shelf turns out to be empty.',
  ],
);

const OnboardingStep _profile = OnboardingStep(
  icon: Icons.account_circle_outlined,
  title: 'Your profile',
  body: 'Open Settings to add your own photo and to see this guide again whenever you like.',
);

List<OnboardingStep> _staff() => const <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: 'Welcome to A2 Stocks',
        body: 'You are signed in as Staff. This quick tour shows what you can do. It takes a minute.',
      ),
      OnboardingStep(
        icon: Icons.point_of_sale_outlined,
        title: 'Selling',
        body: 'Open Sales & Orders to make a sale.',
        points: <String>[
          'Choose the customer, add the products and quantities, and give a discount if allowed.',
          'Record the payment now or later from the order.',
          'Move an order along: Pending, Processing, Shipped, Delivered.',
        ],
      ),
      OnboardingStep(
        icon: Icons.inventory_2_outlined,
        title: 'Products and stock',
        body: 'Look up products, prices and photos under Products, and what is on the shelf under Stock.',
        points: <String>[
          'Red numbers in Stock mean the system thinks there is less than zero: tell your manager.',
          'You can add photos to products you can open.',
        ],
      ),
      OnboardingStep(
        icon: Icons.groups_outlined,
        title: 'Customers',
        body: 'Add a customer when someone new buys. Their balance shows what they owe and the payments they made.',
      ),
      _offline,
      _profile,
    ];

List<OnboardingStep> _manager() => const <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: 'Welcome to A2 Stocks',
        body: 'You are signed in as Manager: you run the shop day to day. This tour shows where things are.',
      ),
      OnboardingStep(
        icon: Icons.dashboard_outlined,
        title: 'Your dashboard',
        body: 'The home screen shows today\'s and this month\'s sales, what customers owe, low stock and the best sellers.',
      ),
      OnboardingStep(
        icon: Icons.point_of_sale_outlined,
        title: 'Sales and online orders',
        body: 'Sales & Orders holds every order: from the counter and from the online store.',
        points: <String>[
          'Online orders are marked "Online store" and already took their stock out.',
          'Only you and admins can cancel an order; do it for fake or refused online orders so the stock comes back.',
        ],
      ),
      OnboardingStep(
        icon: Icons.shopping_cart_checkout_outlined,
        title: 'Buying stock',
        body: 'Vendors and Purchases record what you buy and what you owe. Confirming a purchase adds the stock.',
      ),
      OnboardingStep(
        icon: Icons.fact_check_outlined,
        title: 'Stock and audits',
        body: 'Count the shelf in Stock Audit; confirming it corrects the system to what you counted.',
        points: <String>['Set an alert level on a variant to be warned before it runs out.'],
      ),
      OnboardingStep(
        icon: Icons.add_a_photo_outlined,
        title: 'Photos',
        body: 'Add photos to products, categories, customers and vendors. Product photos appear in the online store.',
      ),
      _offline,
      _profile,
    ];

List<OnboardingStep> _admin() => const <OnboardingStep>[
      OnboardingStep(
        icon: Icons.waving_hand_outlined,
        title: 'Welcome to A2 Stocks',
        body: 'You are signed in as Admin: you can see and change everything. Here is how to get the shop ready.',
      ),
      OnboardingStep(
        icon: Icons.checklist_outlined,
        title: 'First setup checklist',
        body: 'Do these once, in this order:',
        points: <String>[
          '1. Settings > Online store: store name, phone, delivery fee, free-delivery amount.',
          '2. Settings > Online store > "Send test e-mail" to check that e-mail works.',
          '3. Categories (start from a ready-made Starter pack for your kind of business), then Products with their variants, prices and photos.',
          '4. Vendors and Customers; record opening balances if people already owe or are owed.',
          '5. Purchases to put the first stock on the shelf (or a Stock Audit to count what you have).',
          '6. Users: a login for each person, with the right role.',
        ],
      ),
      OnboardingStep(
        icon: Icons.people_outline,
        title: 'Your team',
        body: 'Create a login for everyone under Users. Nobody should share one.',
        points: <String>[
          'Staff: sell, record payments, look up stock and products.',
          'Manager: everything staff do, plus vendors, purchases, stock audits, the dashboard, and cancelling orders.',
          'Admin: everything, plus users, activity logs and the store settings.',
          'A person who leaves is switched off, never deleted, so history stays correct.',
        ],
      ),
      OnboardingStep(
        icon: Icons.storefront_outlined,
        title: 'The online store',
        body: 'Customers order on your website and pay cash on delivery.',
        points: <String>[
          'Only active products with a price and a category that is active are shown.',
          'Orders arrive here as "Online store" with the delivery address; the stock is taken out at once.',
          'Switch the store off in Settings to stop taking orders.',
          'With e-mail set up, shoppers get a confirmation and you get an alert for each new order.',
        ],
      ),
      OnboardingStep(
        icon: Icons.history_outlined,
        title: 'Activity logs',
        body: 'Every change is recorded with who did it and when. Open Activity Logs to see sales, price changes, logins and more.',
      ),
      OnboardingStep(
        icon: Icons.add_a_photo_outlined,
        title: 'Photos',
        body: 'Add photos to products (several each), categories, customers, vendors and users. Your own photo is in Settings.',
      ),
      _offline,
      _profile,
    ];

/// The welcome guide for a role. Everyone sees the pages that matter to them.
List<OnboardingStep> onboardingStepsFor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return _admin();
    case UserRole.manager:
      return _manager();
    case UserRole.staff:
      return _staff();
  }
}
