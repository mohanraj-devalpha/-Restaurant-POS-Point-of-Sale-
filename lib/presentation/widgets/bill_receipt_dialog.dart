import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';

class BillReceiptDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onClose;

  const BillReceiptDialog({super.key, required this.order, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    final orderTypeLabel = order.orderType == OrderType.dineIn ? 'Dine-In' : order.orderType == OrderType.takeaway ? 'Takeaway' : 'Delivery';
    final paymentLabel = order.paymentType == PaymentType.card ? 'Card' : order.paymentType == PaymentType.cash ? 'Cash' : 'UPI';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('e', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(height: 12),
            Text('Emzo POS', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            Text('Bill Receipt', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            _dottedDivider(),
            const SizedBox(height: 12),
            // Order info
            _infoRow('Order #', order.orderNumber),
            _infoRow('Date', dateStr),
            _infoRow('Type', orderTypeLabel),
            _infoRow('Payment', paymentLabel),
            if (order.tableName != null) _infoRow('Table', order.tableName!),
            if (order.customerName != null) _infoRow('Customer', order.customerName!),
            const SizedBox(height: 12),
            _dottedDivider(),
            const SizedBox(height: 12),
            // Items header
            Row(
              children: [
                Expanded(flex: 3, child: Text('Item', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                Expanded(child: Text('Qty', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary), textAlign: TextAlign.center)),
                Expanded(child: Text('Price', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary), textAlign: TextAlign.right)),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item.product.name, style: GoogleFonts.inter(fontSize: 13))),
                  Expanded(child: Text('${item.quantity}', style: GoogleFonts.inter(fontSize: 13), textAlign: TextAlign.center)),
                  Expanded(child: Text('£${item.totalPrice.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                ],
              ),
            )),
            const SizedBox(height: 12),
            _dottedDivider(),
            const SizedBox(height: 12),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('£ ${order.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Thank you for your visit!', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                ),
                child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dottedDivider() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) => Container(width: 4, height: 1, color: AppTheme.divider)),
        );
      },
    );
  }
}
