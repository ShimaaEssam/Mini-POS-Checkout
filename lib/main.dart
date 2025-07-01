import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mini_pos_checkout/src/catalog/bloc/catalog_bloc.dart';
import 'package:mini_pos_checkout/src/cart/bloc/cart_bloc.dart';
import 'package:mini_pos_checkout/src/receipt/receipt.dart';

Future<void> main() async {
  // 1. Load catalog
  final catalogBloc = CatalogBloc();
  final catalogCompleter = Completer<void>();

  catalogBloc.stream.listen((state) {
    if (state is CatalogLoaded) {
      print('Catalog loaded: ${state.items.length} items');
      catalogCompleter.complete();
    } else if (state is CatalogError) {
      print('Failed to load catalog: ${state.message}');
      catalogCompleter.completeError(state.message);
    }
  });

  catalogBloc.add(LoadCatalog());
  await catalogCompleter.future;
  final items = (catalogBloc.state as CatalogLoaded).items;

  // 2. Create cart
  final cartBloc = CartBloc();
  cartBloc.stream.listen((state) {
    print('Cart updated → Subtotal: ${state.totals.subtotal}, '
        'VAT: ${state.totals.vat}, '
        'Total: ${state.totals.grandTotal}');
  });

  // 3. Simulate cashier actions
  final coffee = items.firstWhere((i) => i.id == 'p01');
  final bagel = items.firstWhere((i) => i.id == 'p02');

  cartBloc.add(AddItem(coffee));
  cartBloc.add(AddItem(bagel));
  cartBloc.add(ChangeQty(coffee, 2));
  cartBloc.add(ChangeQty(bagel, 10));

  // Wait a moment for all events to process
  await Future<void>.delayed(const Duration(milliseconds: 200));

  // 4. Checkout: build receipt
  final receipt = buildReceipt(cartBloc.state, DateTime.now());
  print('\n=== RECEIPT ===');
  print('Timestamp: ${receipt.timestamp}');
  for (var line in receipt.lines) {
    print(
        '${line.item.name} x${line.quantity} '
            '@ ${line.item.price.toStringAsFixed(2)} '
            '- ${line.discountPercent}% → Net ${line.net.toStringAsFixed(2)}'
    );
  }
  print('Subtotal: ${receipt.totals.subtotal.toStringAsFixed(2)}');
  print('VAT (15%): ${receipt.totals.vat.toStringAsFixed(2)}');
  print('Grand Total: ${receipt.totals.grandTotal.toStringAsFixed(2)}');
}