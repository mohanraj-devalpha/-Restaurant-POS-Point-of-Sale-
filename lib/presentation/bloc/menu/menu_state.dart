import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class MenuState extends Equatable {
  final List<Category> categories;
  final List<Product> allProducts;
  final List<Product> displayedProducts;
  final List<RestaurantTable> tables;
  final List<Customer> customers;
  final String? selectedCategoryId;
  final OrderType orderType;
  final RestaurantTable? selectedTable;
  final Customer? selectedCustomer;
  final bool isGridView;
  final bool isSearching;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const MenuState({
    this.categories = const [],
    this.allProducts = const [],
    this.displayedProducts = const [],
    this.tables = const [],
    this.customers = const [],
    this.selectedCategoryId,
    this.orderType = OrderType.dineIn,
    this.selectedTable,
    this.selectedCustomer,
    this.isGridView = true,
    this.isSearching = false,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<Category>? categories,
    List<Product>? allProducts,
    List<Product>? displayedProducts,
    List<RestaurantTable>? tables,
    List<Customer>? customers,
    String? selectedCategoryId,
    bool clearCategory = false,
    OrderType? orderType,
    RestaurantTable? selectedTable,
    bool clearTable = false,
    Customer? selectedCustomer,
    bool clearCustomer = false,
    bool? isGridView,
    bool? isSearching,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      tables: tables ?? this.tables,
      customers: customers ?? this.customers,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      orderType: orderType ?? this.orderType,
      selectedTable:
          clearTable ? null : (selectedTable ?? this.selectedTable),
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      isGridView: isGridView ?? this.isGridView,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get selectedCategoryName {
    if (selectedCategoryId == null) return 'All Items';
    final cat = categories.where((c) => c.id == selectedCategoryId);
    return cat.isNotEmpty ? cat.first.name : 'All Items';
  }

  @override
  List<Object?> get props => [
        categories,
        allProducts,
        displayedProducts,
        tables,
        customers,
        selectedCategoryId,
        orderType,
        selectedTable,
        selectedCustomer,
        isGridView,
        isSearching,
        searchQuery,
        isLoading,
        error,
      ];
}
