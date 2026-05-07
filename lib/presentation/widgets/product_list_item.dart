import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final int quantity;

  const ProductListItem({super.key, required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMd,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppTheme.radiusSm,
            child: Image.asset(
              'assets/images/food_item_real.jpg',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('£ ${product.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(width: 8),
                    Text('£ ${product.originalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint, decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ],
            ),
          ),
          // Action
          if (quantity > 0)
            Container(
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: AppTheme.radiusXl),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => context.read<CartBloc>().add(CartDecrementQuantity(product.id)),
                    child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.remove, color: Colors.white, size: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$quantity', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  GestureDetector(
                    onTap: () => context.read<CartBloc>().add(CartIncrementQuantity(product.id)),
                    child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add, color: Colors.white, size: 16)),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => context.read<CartBloc>().add(CartAddProduct(product)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: AppTheme.radiusXl),
                child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
