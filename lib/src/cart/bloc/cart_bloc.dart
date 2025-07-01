import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../catalog/models/item.dart';
import '../models/cart_line.dart';
import '../models/cart_totals.dart';

part 'cart_event.dart';
part 'cart_state.dart';

const double _vatRate = 0.15;

/// Bloc managing cart operations.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState(lines: [], totals: CartTotals(subtotal: 0, vat: 0, grandTotal: 0))) {
    on(_onAddItem);
    on(_onRemoveItem);
    on(_onChangeQty);
    on(_onChangeDiscount);
    on(_onClearCart);
  }

  void _recalculate(Emitter emit, List lines) {
    final subtotal = lines.fold<double>(0, (sum, l) => sum + l.net);
    final vat = double.parse((subtotal * _vatRate).toStringAsFixed(2));
    final grand = double.parse((subtotal + vat).toStringAsFixed(2));
    emit(CartState(lines: lines, totals: CartTotals(subtotal: subtotal, vat: vat, grandTotal: grand)));
  }
  CartTotals calculateTotals(List<CartLine> lines) {
    final subtotal = lines.fold<double>(0, (sum, l) => sum + l.lineNet);
    final vat = double.parse((subtotal * _vatRate).toStringAsFixed(2));
    final grandTotal = double.parse((subtotal + vat).toStringAsFixed(2));
    return CartTotals(
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      vat: vat,
      grandTotal: grandTotal,
    );
  }
  void _onAddItem(AddItem event, Emitter emit) {
    final existing = state.lines.where((l) => l.item.id == event.item.id);
    List updated;
    if (existing.isEmpty) {
      updated = List.from(state.lines)..add(CartLine(item: event.item));
    } else {
      updated = state.lines.map((l) {
        if (l.item.id == event.item.id) {
          return l.copyWith(qty: l.qty + 1);
        }
        return l;
      }).toList();
    }
    _recalculate(emit, updated);
  }

  void _onRemoveItem(RemoveItem event, Emitter emit) {
    final updated = state.lines.where((l) => l.item.id != event.item.id).toList();
    _recalculate(emit, updated);
  }

  void _onChangeQty(ChangeQty event, Emitter emit) {
    final updated = state.lines.map((l) {
      if (l.item.id == event.item.id) {
        return l.copyWith(qty: event.qty);
      }
      return l;
    }).toList();
    _recalculate(emit, updated);
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter emit) {
    final updated = state.lines.map((l) {
      if (l.item.id == event.item.id) {
        return l.copyWith(discountPercent: event.discountPercent);
      }
      return l;
    }).toList();
    _recalculate(emit, updated);
  }

  void _onClearCart(ClearCart event, Emitter emit) {
    _recalculate(emit, []);
  }
}
