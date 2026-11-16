import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No database or cloud service is opened here. The device's database is opened
  // for the person who signs in (lib/providers/local_data_providers.dart), and
  // the web build has none at all.
  runApp(const ProviderScope(child: MqSportsApp()));
}
