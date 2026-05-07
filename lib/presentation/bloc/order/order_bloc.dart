import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/pos_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final PosRepository repository;
  int _orderCounter = 0;
  final _uuid = const Uuid();

  OrderBloc({required this.repository}) : super(const OrderState()) {
    on<OrderSaveBill>(_onSaveBill);
    on<OrderPayBill>(_onPayBill);
    on<OrderLoadAll>(_onLoadAll);
    on<OrderUpdateExisting>(_onUpdateExisting);
    on<OrderCancel>(_onCancel);
    on<OrderSettle>(_onSettle);
    on<OrderPrint>(_onPrint);
  }

  String _generateOrderNumber() {
    _orderCounter++;
    return 'ORD-${_orderCounter.toString().padLeft(4, '0')}';
  }

  Future<void> _onSaveBill(
      OrderSaveBill event, Emitter<OrderState> emit) async {
    final order = Order(
      id: _uuid.v4(),
      orderNumber: _generateOrderNumber(),
      orderType: event.orderType,
      paymentType: event.paymentType,
      status: OrderStatus.pending,
      items: event.items,
      tableId: event.tableId,
      tableName: event.tableName,
      customerId: event.customerId,
      customerName: event.customerName,
      totalAmount: event.totalAmount,
      createdAt: DateTime.now(),
    );

    await repository.saveOrder(order);
    final pending = await repository.getPendingOrders();
    final settled = await repository.getSettledOrders();

    emit(state.copyWith(
      pendingOrders: pending,
      settledOrders: settled,
      successMessage: 'Bill saved! ${order.orderNumber}',
    ));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> _onPayBill(
      OrderPayBill event, Emitter<OrderState> emit) async {
    final order = Order(
      id: _uuid.v4(),
      orderNumber: _generateOrderNumber(),
      orderType: event.orderType,
      paymentType: event.paymentType,
      status: OrderStatus.settled,
      items: event.items,
      tableId: event.tableId,
      tableName: event.tableName,
      customerId: event.customerId,
      customerName: event.customerName,
      totalAmount: event.totalAmount,
      createdAt: DateTime.now(),
      settledAt: DateTime.now(),
    );

    await repository.saveOrder(order);
    emit(state.copyWith(printOrder: order));

    final pending = await repository.getPendingOrders();
    final settled = await repository.getSettledOrders();
    emit(state.copyWith(
      pendingOrders: pending,
      settledOrders: settled,
      successMessage: 'Bill created! ${order.orderNumber}',
    ));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> _onLoadAll(
      OrderLoadAll event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isLoading: true));
    final pending = await repository.getPendingOrders();
    final settled = await repository.getSettledOrders();
    emit(state.copyWith(
      pendingOrders: pending,
      settledOrders: settled,
      isLoading: false,
    ));
  }

  Future<void> _onUpdateExisting(
      OrderUpdateExisting event, Emitter<OrderState> emit) async {
    final orders = await repository.getOrders();
    final existing = orders.where((o) => o.id == event.orderId);
    if (existing.isNotEmpty) {
      final updated = existing.first.copyWith(
        items: event.items,
        totalAmount: event.totalAmount,
        paymentType: event.paymentType,
      );
      await repository.updateOrder(updated);
      final pending = await repository.getPendingOrders();
      final settled = await repository.getSettledOrders();
      emit(state.copyWith(
        pendingOrders: pending,
        settledOrders: settled,
        successMessage: 'Order updated!',
      ));
      emit(state.copyWith(clearSuccess: true));
    }
  }

  Future<void> _onCancel(
      OrderCancel event, Emitter<OrderState> emit) async {
    await repository.deleteOrder(event.orderId);
    final pending = await repository.getPendingOrders();
    final settled = await repository.getSettledOrders();
    emit(state.copyWith(
      pendingOrders: pending,
      settledOrders: settled,
      successMessage: 'Order cancelled',
    ));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> _onSettle(
      OrderSettle event, Emitter<OrderState> emit) async {
    final orders = await repository.getOrders();
    final existing = orders.where((o) => o.id == event.orderId);
    if (existing.isNotEmpty) {
      final settled = existing.first.copyWith(
        status: OrderStatus.settled,
        settledAt: DateTime.now(),
      );
      await repository.updateOrder(settled);
      final pendingList = await repository.getPendingOrders();
      final settledList = await repository.getSettledOrders();
      emit(state.copyWith(
        pendingOrders: pendingList,
        settledOrders: settledList,
        clearPrint: true,
      ));
    }
  }

  Future<void> _onPrint(
      OrderPrint event, Emitter<OrderState> emit) async {
    final orders = await repository.getOrders();
    final existing = orders.where((o) => o.id == event.orderId);
    if (existing.isNotEmpty) {
      emit(state.copyWith(printOrder: existing.first));
    }
  }
}
