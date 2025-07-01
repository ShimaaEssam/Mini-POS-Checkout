import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mini_pos_checkout/src/cart/bloc/cart_bloc.dart';
import 'package:mini_pos_checkout/src/cart/models/cart_line.dart';
import 'package:mini_pos_checkout/src/catalog/models/item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Item> catalogItems;
  setUpAll(() async {
    final jsonStr = await rootBundle.loadString('assets/catalog.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    catalogItems = jsonList
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  group('CartBloc with real catalog items', () {
    late CartBloc bloc;
    late Item coffee;
    late Item bagel;

    setUp(() {
      bloc = CartBloc();
      // Assume first two items correspond to p01 and p02
      coffee = catalogItems.firstWhere((i) => i.id == 'p01');
      bagel = catalogItems.firstWhere((i) => i.id == 'p02');
    });

    test('initial state has empty lines and zero totals', () {
      expect(bloc.state.lines, isEmpty);
      expect(bloc.state.totals.subtotal, 0);
      expect(bloc.state.totals.vat, 0);
      expect(bloc.state.totals.grandTotal, 0);
    });

    blocTest<CartBloc, CartState>(
      'adds two items and updates totals correctly',
      build: () => bloc,
      act: (b) {
        b.add(AddItem(coffee));
        b.add(AddItem(bagel));
      },
      expect: () => [
        predicate<CartState>((s) => s.totals.subtotal == coffee.price),
        predicate<CartState>((s) => s.totals.subtotal == (coffee.price + bagel.price)),
      ],
    );

    blocTest<CartBloc, CartState>(
      'quantity and discount adjustments reflect in totals',
      build: () => bloc,
      seed: () => CartState(
        lines: [CartLine(item: coffee, qty: 1)],
        totals: bloc.calculateTotals([CartLine(item: coffee, qty: 1)]),
      ),
      act: (b) {
        b.add(ChangeQty(coffee, 2));
        b.add(ChangeQty(coffee, 50));
      },
      expect: () => [
        predicate<CartState>((s) => s.totals.subtotal == coffee.price * 2),
        predicate<CartState>((s) => s.totals.subtotal == coffee.price),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clearing cart resets to initial state',
      build: () => bloc,
      seed: () => CartState(
        lines: [CartLine(item: coffee, qty: 1)],
        totals: bloc.calculateTotals([CartLine(item: coffee, qty: 1)]),
      ),
      act: (b) => b.add(ClearCart()),
      expect: () => [
        predicate<CartState>((s) => s.lines.isEmpty && s.totals.subtotal == 0),
      ],
    );
  });
}