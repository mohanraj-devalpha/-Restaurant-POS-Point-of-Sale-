import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final PaymentType paymentType;
  final String? editingOrderId;

  const CartState({
    this.items = const [],
    this.paymentType = PaymentType.card,
    this.editingOrderId,
  });

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int getQuantity(String productId) {
    final item = items.where((i) => i.product.id == productId);
    return item.isNotEmpty ? item.first.quantity : 0;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get isEditing => editingOrderId != null;

  CartState copyWith({
    List<CartItem>? items,
    PaymentType? paymentType,
    String? editingOrderId,
    bool clearEditingId = false,
  }) {
    return CartState(
      items: items ?? this.items,
      paymentType: paymentType ?? this.paymentType,
      editingOrderId:
          clearEditingId ? null : (editingOrderId ?? this.editingOrderId),
    );
  }

  @override
  List<Object?> get props => [items, paymentType, editingOrderId];
}
