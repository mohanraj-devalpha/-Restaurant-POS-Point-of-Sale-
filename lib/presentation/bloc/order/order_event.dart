import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderSaveBill extends OrderEvent {
  final OrderType orderType;
  final PaymentType paymentType;
  final List<CartItem> items;
  final String? tableId;
  final String? tableName;
  final String? customerId;
  final String? customerName;
  final double totalAmount;

  const OrderSaveBill({
    required this.orderType,
    required this.paymentType,
    required this.items,
    this.tableId,
    this.tableName,
    this.customerId,
    this.customerName,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        orderType,
        paymentType,
        items,
        tableId,
        tableName,
        customerId,
        customerName,
        totalAmount,
      ];
}

class OrderPayBill extends OrderEvent {
  final OrderType orderType;
  final PaymentType paymentType;
  final List<CartItem> items;
  final String? tableId;
  final String? tableName;
  final String? customerId;
  final String? customerName;
  final double totalAmount;

  const OrderPayBill({
    required this.orderType,
    required this.paymentType,
    required this.items,
    this.tableId,
    this.tableName,
    this.customerId,
    this.customerName,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        orderType,
        paymentType,
        items,
        tableId,
        tableName,
        customerId,
        customerName,
        totalAmount,
      ];
}

class OrderLoadAll extends OrderEvent {
  const OrderLoadAll();
}

class OrderUpdateExisting extends OrderEvent {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final PaymentType paymentType;

  const OrderUpdateExisting({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.paymentType,
  });

  @override
  List<Object?> get props => [orderId, items, totalAmount, paymentType];
}

class OrderCancel extends OrderEvent {
  final String orderId;
  const OrderCancel(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderSettle extends OrderEvent {
  final String orderId;
  const OrderSettle(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderPrint extends OrderEvent {
  final String orderId;
  const OrderPrint(this.orderId);
  @override
  List<Object?> get props => [orderId];
}
