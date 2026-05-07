import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class OrderState extends Equatable {
  final List<Order> pendingOrders;
  final List<Order> settledOrders;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final Order? printOrder;

  const OrderState({
    this.pendingOrders = const [],
    this.settledOrders = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.printOrder,
  });

  OrderState copyWith({
    List<Order>? pendingOrders,
    List<Order>? settledOrders,
    bool? isLoading,
    String? error,
    String? successMessage,
    Order? printOrder,
    bool clearPrint = false,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return OrderState(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      settledOrders: settledOrders ?? this.settledOrders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      printOrder: clearPrint ? null : (printOrder ?? this.printOrder),
    );
  }

  @override
  List<Object?> get props =>
      [pendingOrders, settledOrders, isLoading, error, successMessage, printOrder];
}
