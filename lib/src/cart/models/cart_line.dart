import 'package:equatable/equatable.dart';

import '../../catalog/models/item.dart';

class CartLine extends Equatable {
  final Item item;
  final int qty;
  final double discountPercent;

  const CartLine({required this.item, this.qty = 1, this.discountPercent = 0});

  CartLine copyWith({int? qty, double? discountPercent}) {
    return CartLine(
      item: item,
      qty: qty ?? this.qty,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  double get lineNet {
    final net = item.price * qty * (1 - discountPercent / 100);
    return double.parse(net.toStringAsFixed(2));
  }

  @override
  List<Object?> get props => [item, qty, discountPercent];
}

