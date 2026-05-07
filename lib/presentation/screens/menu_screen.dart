import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/menu/menu_bloc.dart';
import '../bloc/menu/menu_event.dart';
import '../bloc/menu/menu_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/order/order_event.dart';
import '../bloc/order/order_state.dart';
import '../widgets/product_tile.dart';
import '../widgets/product_list_item.dart';
import '../widgets/category_drawer.dart';
import '../widgets/bill_receipt_dialog.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'welcome_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchController = TextEditingController();
  final _tableKey = GlobalKey();
  final _customerKey = GlobalKey();
  bool _showCategories = false;

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(const MenuLoadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCategoryList() {
    setState(() {
      _showCategories = !_showCategories;
    });
  }

  void _showTableDropdown(MenuState menuState) {
    final RenderBox renderBox = _tableKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      constraints: BoxConstraints(
        maxHeight: 350,
        minWidth: size.width,
        maxWidth: size.width,
      ),
      items: menuState.tables.map((t) {
        return PopupMenuItem<String>(
          value: t.id,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
            ),
            child: Text(
              t.name,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    ).then((selectedId) {
      if (selectedId != null) {
        final table = menuState.tables.firstWhere((t) => t.id == selectedId);
        context.read<MenuBloc>().add(MenuTableSelected(table));
      }
    });
  }

  void _showCustomerDropdown(MenuState menuState) {
    final RenderBox renderBox = _customerKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return _CustomerDropdownOverlay(
          customers: menuState.customers,
          offset: offset,
          width: size.width,
          topOffset: size.height + 4,
          onSelected: (customer) {
            context.read<MenuBloc>().add(MenuCustomerSelected(customer));
            Navigator.pop(dialogContext);
          },
          onAddCustomer: () {
            Navigator.pop(dialogContext);
            _showAddCustomerDialog();
          },
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Customer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: GoogleFonts.inter(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.inter(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final newCustomer = Customer(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  context.read<MenuBloc>().add(MenuCustomerSelected(newCustomer));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _handleSaveBill() {
    final cart = context.read<CartBloc>().state;
    final menu = context.read<MenuBloc>().state;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    if (cart.isEditing) {
      context.read<OrderBloc>().add(
        OrderUpdateExisting(
          orderId: cart.editingOrderId!,
          items: cart.items,
          totalAmount: cart.totalAmount,
          paymentType: cart.paymentType,
        ),
      );
    } else {
      context.read<OrderBloc>().add(
        OrderSaveBill(
          orderType: menu.orderType,
          paymentType: cart.paymentType,
          items: cart.items,
          tableId: menu.selectedTable?.id,
          tableName: menu.selectedTable?.name,
          customerId: menu.selectedCustomer?.id,
          customerName: menu.selectedCustomer?.name,
          totalAmount: cart.totalAmount,
        ),
      );
    }
    context.read<CartBloc>().add(const CartClear());
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrdersScreen(initialTab: 0)),
    );
  }

  void _handlePayBill() {
    final cart = context.read<CartBloc>().state;
    final menu = context.read<MenuBloc>().state;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    context.read<OrderBloc>().add(
      OrderPayBill(
        orderType: menu.orderType,
        paymentType: cart.paymentType,
        items: cart.items,
        tableId: menu.selectedTable?.id,
        tableName: menu.selectedTable?.name,
        customerId: menu.selectedCustomer?.id,
        customerName: menu.selectedCustomer?.name,
        totalAmount: cart.totalAmount,
      ),
    );
    context.read<CartBloc>().add(const CartClear());
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrdersScreen(initialTab: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) => p.page != c.page,
          listener: (ctx, state) {
            if (state.page == AuthPage.welcome) {
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<OrderBloc, OrderState>(
          listener: (ctx, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state.printOrder != null) {
              showDialog(
                context: ctx,
                builder:
                    (_) => BillReceiptDialog(
                      order: state.printOrder!,
                      onClose: () {
                        ctx.read<OrderBloc>().add(
                          OrderSettle(state.printOrder!.id),
                        );
                        Navigator.of(ctx).pop();
                      },
                    ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildOrderTypeSelector(),
              _buildSelectionRow(),
              if (!_showCategories) _buildCategoryHeader(),
              Expanded(child: _showCategories ? _buildCategoryList() : _buildProductGrid()),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleCategoryList,
          backgroundColor: _showCategories ? Colors.white : AppTheme.primary,
          elevation: _showCategories ? 4 : 6,
          child: Icon(
            _showCategories ? Icons.close : Icons.apps_rounded,
            color: _showCategories ? AppTheme.primary : Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.room_service_outlined,
                  color: AppTheme.textPrimary,
                ),
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    ),
              ),
              if (!state.isSearching)
                Expanded(
                  child: Text(
                    'Select Menu',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              if (state.isSearching)
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
                    ),
                    onChanged:
                        (q) => context.read<MenuBloc>().add(
                          MenuSearchQueryChanged(q),
                        ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  state.isSearching ? Icons.close : Icons.search,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  if (state.isSearching) _searchController.clear();
                  context.read<MenuBloc>().add(const MenuSearchToggled());
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.textPrimary,
                ),
                onPressed:
                    () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTypeSelector() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _orderTypeChip(
                  'Dine In',
                  Icons.restaurant,
                  OrderType.dineIn,
                  state.orderType,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _orderTypeChip(
                  'Takeaway',
                  Icons.takeout_dining,
                  OrderType.takeaway,
                  state.orderType,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _orderTypeChip(
                  'Delivery',
                  Icons.delivery_dining,
                  OrderType.delivery,
                  state.orderType,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderTypeChip(
    String label,
    IconData icon,
    OrderType type,
    OrderType selected,
  ) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => context.read<MenuBloc>().add(MenuOrderTypeChanged(type)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: AppTheme.radiusXl,
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionRow() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              if (state.orderType == OrderType.dineIn)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showTableDropdown(state),
                    child: Container(
                      key: _tableKey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.divider),
                        borderRadius: AppTheme.radiusMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.table_restaurant,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.selectedTable?.name ?? 'Select table',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color:
                                    state.selectedTable != null
                                        ? AppTheme.textPrimary
                                        : AppTheme.textHint,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppTheme.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.orderType == OrderType.dineIn)
                const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomerDropdown(state),
                  child: Container(
                    key: _customerKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: AppTheme.radiusMd,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.selectedCustomer?.name ?? 'Select customer',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color:
                                  state.selectedCustomer != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textHint,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppTheme.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryHeader() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.isSearching
                      ? 'Search Results'
                      : state.selectedCategoryName,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w500, // Medium
                    height: 1.0, // 100%
                    letterSpacing: 0,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusSm,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!state.isGridView) return;
                        context.read<MenuBloc>().add(const MenuViewToggled());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              !state.isGridView
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                          borderRadius: AppTheme.radiusSm,
                        ),
                        child: Icon(
                          Icons.view_list_rounded,
                          size: 20,
                          color:
                              !state.isGridView
                                  ? AppTheme.primary
                                  : AppTheme.textHint,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (state.isGridView) return;
                        context.read<MenuBloc>().add(const MenuViewToggled());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              state.isGridView
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                          borderRadius: AppTheme.radiusSm,
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 20,
                          color:
                              state.isGridView
                                  ? AppTheme.primary
                                  : AppTheme.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (_, i) {
              final category = state.categories[i];
              return InkWell(
                onTap: () {
                  context.read<MenuBloc>().add(MenuCategorySelected(category.id));
                  setState(() {
                    _showCategories = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, menuState) {
        if (menuState.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        if (menuState.displayedProducts.isEmpty) {
          return Center(
            child: Text(
              'No products found',
              style: GoogleFonts.inter(color: AppTheme.textHint),
            ),
          );
        }
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (menuState.isGridView) {
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 113 / 149,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: menuState.displayedProducts.length,
                itemBuilder: (_, i) {
                  final product = menuState.displayedProducts[i];
                  final qty = cartState.getQuantity(product.id);
                  return ProductTile(product: product, quantity: qty);
                },
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: menuState.displayedProducts.length,
                itemBuilder: (_, i) {
                  final product = menuState.displayedProducts[i];
                  final qty = cartState.getQuantity(product.id);
                  return ProductListItem(product: product, quantity: qty);
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View cart + payment type
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    child: Text(
                      'View Cart',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _paymentChip(PaymentType.card, 'Card', cartState.paymentType),
                  const SizedBox(width: 8),
                  _paymentChip(PaymentType.cash, 'Cash', cartState.paymentType),
                  const SizedBox(width: 8),
                  _paymentChip(PaymentType.upi, 'UPI', cartState.paymentType),
                ],
              ),
              const SizedBox(height: 10),
              // Total + buttons
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '£ ${cartState.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _handleSaveBill,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(cartState.isEditing ? 'Update' : 'Save Bill'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMd,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handlePayBill,
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Print Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMd,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentChip(PaymentType type, String label, PaymentType selected) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => context.read<CartBloc>().add(CartPaymentTypeChanged(type)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.textHint,
                width: 2,
              ),
            ),
            child:
                isSelected
                    ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerDropdownOverlay extends StatefulWidget {
  final List<Customer> customers;
  final Offset offset;
  final double width;
  final double topOffset;
  final ValueChanged<Customer> onSelected;
  final VoidCallback onAddCustomer;

  const _CustomerDropdownOverlay({
    required this.customers,
    required this.offset,
    required this.width,
    required this.topOffset,
    required this.onSelected,
    required this.onAddCustomer,
  });

  @override
  State<_CustomerDropdownOverlay> createState() => _CustomerDropdownOverlayState();
}

class _CustomerDropdownOverlayState extends State<_CustomerDropdownOverlay> {
  final _searchController = TextEditingController();
  List<Customer> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.customers
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.phone.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible barrier to close on tap outside
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: widget.offset.dx,
          top: widget.offset.dy + widget.topOffset,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: SizedBox(
              width: widget.width,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search Customer',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textHint,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textHint),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    // Add Customer button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onAddCustomer,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: Text(
                            'Add Customer',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Customer list
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return InkWell(
                            onTap: () => widget.onSelected(c),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (c.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      c.phone,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
