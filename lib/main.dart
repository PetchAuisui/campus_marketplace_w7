import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'models/cart_model.dart';
import 'repositories/item_repository.dart';
import 'repositories/item_repository_api.dart';
import 'repositories/favorites_repository_drift.dart';
import 'repositories/listing_draft_repository_drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = AppDatabase();
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MyApp(db: db),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase? db;
  final ItemRepository? repository;

  const MyApp({super.key, this.db, this.repository});

  @override
  Widget build(BuildContext context) {
    final database = db ?? AppDatabase();
    return MaterialApp(
      title: 'Campus Marketplace',
      debugShowCheckedModeBanner: false,
      home: AuthGate(
        itemRepositories: [repository ?? ItemRepositoryApi()],
        favoritesRepository: FavoritesRepositoryDrift(database),
        draftRepository: ListingDraftRepositoryDrift(database),
      ),
    );
  }
}
