import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pos_repository.dart';
import '../../../domain/entities/entities.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final PosRepository repository;

  MenuBloc({required this.repository}) : super(const MenuState()) {
    on<MenuLoadData>(_onLoadData);
    on<MenuCategorySelected>(_onCategorySelected);
    on<MenuOrderTypeChanged>(_onOrderTypeChanged);
    on<MenuTableSelected>(_onTableSelected);
    on<MenuCustomerSelected>(_onCustomerSelected);
    on<MenuViewToggled>(_onViewToggled);
    on<MenuSearchQueryChanged>(_onSearchQueryChanged);
    on<MenuSearchToggled>(_onSearchToggled);
  }

  Future<void> _onLoadData(MenuLoadData event, Emitter<MenuState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final categories = await repository.getCategories();
      final products = await repository.getProducts();
      final tables = await repository.getTables();
      final customers = await repository.getCustomers();

      // Default: show first category
      final firstCategoryId =
          categories.isNotEmpty ? categories.first.id : null;
      final filtered = firstCategoryId != null
          ? products.where((p) => p.categoryId == firstCategoryId).toList()
          : products;

      emit(state.copyWith(
        categories: categories,
        allProducts: products,
        displayedProducts: filtered,
        tables: tables,
        customers: customers,
        selectedCategoryId: firstCategoryId,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load menu data',
      ));
    }
  }

  void _onCategorySelected(
      MenuCategorySelected event, Emitter<MenuState> emit) {
    List<Product> filtered;
    if (event.categoryId == null) {
      filtered = state.allProducts;
    } else {
      filtered = state.allProducts
          .where((p) => p.categoryId == event.categoryId)
          .toList();
    }
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
      displayedProducts: filtered,
      isSearching: false,
      searchQuery: '',
    ));
  }

  void _onOrderTypeChanged(
      MenuOrderTypeChanged event, Emitter<MenuState> emit) {
    emit(state.copyWith(
      orderType: event.orderType,
      clearTable: event.orderType != OrderType.dineIn,
    ));
  }

  void _onTableSelected(MenuTableSelected event, Emitter<MenuState> emit) {
    if (event.table == null) {
      emit(state.copyWith(clearTable: true));
    } else {
      emit(state.copyWith(selectedTable: event.table));
    }
  }

  void _onCustomerSelected(
      MenuCustomerSelected event, Emitter<MenuState> emit) {
    if (event.customer == null) {
      emit(state.copyWith(clearCustomer: true));
    } else {
      emit(state.copyWith(selectedCustomer: event.customer));
    }
  }

  void _onViewToggled(MenuViewToggled event, Emitter<MenuState> emit) {
    emit(state.copyWith(isGridView: !state.isGridView));
  }

  void _onSearchQueryChanged(
      MenuSearchQueryChanged event, Emitter<MenuState> emit) {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      // Reset to current category
      List<Product> filtered;
      if (state.selectedCategoryId == null) {
        filtered = state.allProducts;
      } else {
        filtered = state.allProducts
            .where((p) => p.categoryId == state.selectedCategoryId)
            .toList();
      }
      emit(state.copyWith(
        displayedProducts: filtered,
        searchQuery: '',
      ));
    } else {
      // Search across ALL products
      final results = state.allProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
      emit(state.copyWith(
        displayedProducts: results,
        searchQuery: event.query,
      ));
    }
  }

  void _onSearchToggled(MenuSearchToggled event, Emitter<MenuState> emit) {
    if (state.isSearching) {
      // Closing search — revert to category view
      List<Product> filtered;
      if (state.selectedCategoryId == null) {
        filtered = state.allProducts;
      } else {
        filtered = state.allProducts
            .where((p) => p.categoryId == state.selectedCategoryId)
            .toList();
      }
      emit(state.copyWith(
        isSearching: false,
        searchQuery: '',
        displayedProducts: filtered,
      ));
    } else {
      emit(state.copyWith(isSearching: true));
    }
  }
}
