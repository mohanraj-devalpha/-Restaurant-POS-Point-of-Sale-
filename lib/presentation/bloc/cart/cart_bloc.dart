import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAddProduct>(_onAddProduct);
    on<CartRemoveProduct>(_onRemoveProduct);
    on<CartIncrementQuantity>(_onIncrementQuantity);
    on<CartDecrementQuantity>(_onDecrementQuantity);
    on<CartPaymentTypeChanged>(_onPaymentTypeChanged);
    on<CartClear>(_onClear);
    on<CartLoadFromOrder>(_onLoadFromOrder);
  }

  void _onAddProduct(CartAddProduct event, Emitter<CartState> emit) {
    final existingIndex =
        state.items.indexWhere((i) => i.product.id == event.product.id);
    if (existingIndex != -1) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex]
          .copyWith(quantity: updatedItems[existingIndex].quantity + 1);
      emit(state.copyWith(items: updatedItems));
    } else {
      emit(state.copyWith(
        items: [...state.items, CartItem(product: event.product, quantity: 1)],
      ));
    }
  }

  void _onRemoveProduct(CartRemoveProduct event, Emitter<CartState> emit) {
    final updatedItems =
        state.items.where((i) => i.product.id != event.productId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onIncrementQuantity(
      CartIncrementQuantity event, Emitter<CartState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == event.productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onDecrementQuantity(
      CartDecrementQuantity event, Emitter<CartState> emit) {
    final updatedItems = <CartItem>[];
    for (final item in state.items) {
      if (item.product.id == event.productId) {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
        // If quantity becomes 0, the item is removed
      } else {
        updatedItems.add(item);
      }
    }
    emit(state.copyWith(items: updatedItems));
  }

  void _onPaymentTypeChanged(
      CartPaymentTypeChanged event, Emitter<CartState> emit) {
    emit(state.copyWith(paymentType: event.paymentType));
  }

  void _onClear(CartClear event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onLoadFromOrder(CartLoadFromOrder event, Emitter<CartState> emit) {
    emit(CartState(
      items: List.from(event.order.items),
      paymentType: event.order.paymentType ?? PaymentType.card,
      editingOrderId: event.order.id,
    ));
  }
}
