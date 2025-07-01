import 'package:equatable/equatable.dart';

class CartTotals extends Equatable {
  final double subtotal;
  final double vat;
  final double grandTotal;

  const CartTotals({required this.subtotal, required this.vat, required this.grandTotal});

  @override
  List<Object?> get props => [subtotal, vat, grandTotal];
}