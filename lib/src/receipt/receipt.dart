import '../cart/bloc/cart_bloc.dart';
import '../cart/models/cart_totals.dart';

class Receipt {
  final DateTime timestamp;
  final List lines;
  final CartTotals totals;

  const Receipt({required this.timestamp, required this.lines, required this.totals});
}
Receipt buildReceipt(CartState state, DateTime timestamp) {
  return Receipt(
    timestamp: timestamp,
    lines: List.unmodifiable(state.lines),
    totals: state.totals,
  );
}
