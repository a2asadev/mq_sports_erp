import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mq_sports_erp/app.dart';
import 'package:mq_sports_erp/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Hive is the single local cache, so Firestore's own cache is disabled.
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);
  runApp(const ProviderScope(child: MqSportsApp()));
}
