import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/order/order_event.dart';
import '../bloc/menu/menu_bloc.dart';
import '../bloc/menu/menu_state.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.isEmpty) {
              return Column(
                children: [
                  _buildCartAppBar(context),
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.textHint.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('Your cart is empty', style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textHint)),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildCartAppBar(context),
                // Total Item count + Clear All
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Total Item : ${state.totalItems}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.read<CartBloc>().add(const CartClear()),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    return Dismissible(
                      key: ValueKey(item.product.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => context.read<CartBloc>().add(CartRemoveProduct(item.product.id)),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0E0),
                          borderRadius: AppTheme.radiusMd,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete, color: AppTheme.error, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Delete',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.radiusMd,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: const Color(0xFF393939),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '£ ${item.product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: const Color(0xFF393939),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: AppTheme.radiusXl,
                              ),
                              child: Row(
                                children: [
                                  _qtyButton(Icons.remove, () => context.read<CartBloc>().add(CartDecrementQuantity(item.product.id))),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 32),
                                    alignment: Alignment.center,
                                    child: Text('${item.quantity}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                  _qtyButton(Icons.add, () => context.read<CartBloc>().add(CartIncrementQuantity(item.product.id))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Billing summary
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sub Total
                    _billRow('Sub Total', '£ ${state.totalAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    // TAX
                    _billRow('TAX', '£ ${state.totalAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    // Service charges
                    _billRow('Service charges', '£ 50'),
                    const SizedBox(height: 12),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '£ ${(state.totalAmount + state.totalAmount + 50).toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Payment type radio buttons
                    Row(
                      children: [
                        _paymentRadio(context, PaymentType.card, 'Card', state.paymentType),
                        const SizedBox(width: 24),
                        _paymentRadio(context, PaymentType.cash, 'Cash', state.paymentType),
                        const SizedBox(width: 24),
                        _paymentRadio(context, PaymentType.upi, 'UPI', state.paymentType),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        // Save Bill
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () => _handleSaveBill(context, state),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Save Bill', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Pay & Print Bill
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: () => _handlePayBill(context, state),
                            icon: const Icon(Icons.print_outlined, size: 20),
                            label: Text('Pay & Print Bill', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
          },
        ),
      ),
    );
  }

  void _handleSaveBill(BuildContext context, CartState cartState) {
    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty'), backgroundColor: AppTheme.warning),
      );
      return;
    }
    final menuState = context.read<MenuBloc>().state;

    if (cartState.isEditing) {
      context.read<OrderBloc>().add(
        OrderUpdateExisting(
          orderId: cartState.editingOrderId!,
          items: cartState.items,
          totalAmount: cartState.totalAmount,
          paymentType: cartState.paymentType,
        ),
      );
    } else {
      context.read<OrderBloc>().add(
        OrderSaveBill(
          orderType: menuState.orderType,
          paymentType: cartState.paymentType,
          items: cartState.items,
          tableId: menuState.selectedTable?.id,
          tableName: menuState.selectedTable?.name,
          customerId: menuState.selectedCustomer?.id,
          customerName: menuState.selectedCustomer?.name,
          totalAmount: cartState.totalAmount,
        ),
      );
    }
    context.read<CartBloc>().add(const CartClear());
    // Pop cart screen, then push Orders screen on Pending tab
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrdersScreen(initialTab: 0)),
    );
  }

  void _handlePayBill(BuildContext context, CartState cartState) {
    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty'), backgroundColor: AppTheme.warning),
      );
      return;
    }
    final menuState = context.read<MenuBloc>().state;

    context.read<OrderBloc>().add(
      OrderPayBill(
        orderType: menuState.orderType,
        paymentType: cartState.paymentType,
        items: cartState.items,
        tableId: menuState.selectedTable?.id,
        tableName: menuState.selectedTable?.name,
        customerId: menuState.selectedCustomer?.id,
        customerName: menuState.selectedCustomer?.name,
        totalAmount: cartState.totalAmount,
      ),
    );
    context.read<CartBloc>().add(const CartClear());
    // Pop cart screen, then push Orders screen on Settled tab
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrdersScreen(initialTab: 1)),
    );
  }

  Widget _buildCartAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24, color: AppTheme.textPrimary),
            ),
          ),
          const Expanded(
            child: SizedBox.shrink(),
          ),
          Text(
            'View Cart',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Expanded(
            child: SizedBox.shrink(),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _billRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _paymentRadio(BuildContext context, PaymentType type, String label, PaymentType selected) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => context.read<CartBloc>().add(CartPaymentTypeChanged(type)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              border: isSelected
                  ? Border.all(color: AppTheme.primary, width: 2)
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
