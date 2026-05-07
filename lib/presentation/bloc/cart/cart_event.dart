import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartAddProduct extends CartEvent {
  final Product product;
  const CartAddProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class CartRemoveProduct extends CartEvent {
  final String productId;
  const CartRemoveProduct(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartIncrementQuantity extends CartEvent {
  final String productId;
  const CartIncrementQuantity(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartDecrementQuantity extends CartEvent {
  final String productId;
  const CartDecrementQuantity(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartPaymentTypeChanged extends CartEvent {
  final PaymentType paymentType;
  const CartPaymentTypeChanged(this.paymentType);
  @override
  List<Object?> get props => [paymentType];
}

class CartClear extends CartEvent {
  const CartClear();
}

class CartLoadFromOrder extends CartEvent {
  final Order order;
  const CartLoadFromOrder(this.order);
  @override
  List<Object?> get props => [order];
}
