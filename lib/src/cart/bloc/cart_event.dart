part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override List<Object?> get props => [];
}

class AddItem extends CartEvent {
  final Item item;
  const AddItem(this.item);
  @override List<Object?> get props => [item];
}

class RemoveItem extends CartEvent {
  final Item item;
  const RemoveItem(this.item);
  @override List<Object?> get props => [item];
}

class ChangeQty extends CartEvent {
  final Item item;
  final int qty;
  const ChangeQty(this.item, this.qty);
  @override List<Object?> get props => [item, qty];
}

class ChangeDiscount extends CartEvent {
  final Item item;
  final double discountPercent;
  const ChangeDiscount(this.item, this.discountPercent);
  @override List<Object?> get props => [item, discountPercent];
}

class ClearCart extends CartEvent {}
