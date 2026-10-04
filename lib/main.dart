import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'models/cart_model.dart';
import 'screens/main_scaffold.dart';
import 'repositories/item_repository.dart';
import 'repositories/item_repository_api.dart';
import 'repositories/favorites_repository_drift.dart';
import 'repositories/listing_draft_repository_drift.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: MainScaffold(
        itemRepository: repository ?? ItemRepositoryApi(),
        favoritesRepository: FavoritesRepositoryDrift(database),
        draftRepository: ListingDraftRepositoryDrift(database),
      ),
    );
  }
}
