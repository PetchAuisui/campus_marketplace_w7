import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_marketplace_w7/main.dart';
import 'package:campus_marketplace_w7/models/cart_model.dart';
import 'package:campus_marketplace_w7/models/item.dart';
import 'package:campus_marketplace_w7/models/listing_draft.dart';
import 'package:campus_marketplace_w7/repositories/item_repository.dart';

class FakeItemRepository implements ItemRepository {
  final List<Item> items;
  FakeItemRepository([this.items = const []]);

  @override
  Future<List<Item>> getItems() async => items;
}

void main() {
  const testItem = Item(
    id: 1,
    title: 'Test Product',
    price: 99.0,
    description: 'A test description',
    category: 'test',
    imageUrl: 'https://example.com/test.png',
  );

  group('CartModel unit tests', () {
    test('initial state is empty', () {
      final cart = CartModel();
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
      expect(cart.items, isEmpty);
    });

    test('add item updates count and totalPrice', () {
      final cart = CartModel();
      cart.add(testItem);
      expect(cart.itemCount, 1);
      expect(cart.totalPrice, 99.0);
      expect(cart.items.first.title, 'Test Product');
    });

    test('remove item updates count and totalPrice', () {
      final cart = CartModel();
      cart.add(testItem);
      cart.remove(testItem);
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('clear removes all items', () {
      final cart = CartModel();
      cart.add(testItem);
      cart.clear();
      expect(cart.itemCount, 0);
      expect(cart.items, isEmpty);
    });
  });

  group('Campus Marketplace widget tests', () {
    testWidgets('displays title, cart badge starts at 0, and shows item', (
      WidgetTester tester,
    ) async {
      final fakeRepo = FakeItemRepository([testItem]);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CartModel(),
          child: MyApp(repository: fakeRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campus Marketplace'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('99.0 บาท'), findsOneWidget);
    });

    testWidgets('tapping add to cart increments badge count', (
      WidgetTester tester,
    ) async {
      final fakeRepo = FakeItemRepository([testItem]);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CartModel(),
          child: MyApp(repository: fakeRepo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('เพิ่ม "Test Product" ลงตะกร้าแล้ว'), findsOneWidget);
    });
  });

  group('ListingDraft unit tests', () {
    test('fromJson parses correctly', () {
      final json = {
        'title': 'กระติกน้ำสแตนเลส',
        'category': 'ของใช้ทั่วไป',
        'description': 'กระติกน้ำเก็บความเย็น 500ml สภาพดี',
      };
      final draft = ListingDraft.fromJson(json);
      expect(draft.title, 'กระติกน้ำสแตนเลส');
      expect(draft.category, 'ของใช้ทั่วไป');
      expect(draft.description, 'กระติกน้ำเก็บความเย็น 500ml สภาพดี');
    });
  });
}

