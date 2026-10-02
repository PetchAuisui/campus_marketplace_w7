import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'screens/home_page.dart';
import 'repositories/item_repository.dart';
import 'repositories/item_repository_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ItemRepository? repository;

  const MyApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MaterialApp(
        title: 'Campus Marketplace',
        debugShowCheckedModeBanner: false,
        home: HomePage(repository: repository ?? ItemRepositoryApi()),
      ),
    );
  }
}
