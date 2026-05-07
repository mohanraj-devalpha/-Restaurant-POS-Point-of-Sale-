import '../../domain/entities/entities.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/local_data_source.dart';

class PosRepositoryImpl implements PosRepository {
  final LocalDataSource localDataSource;

  // In-memory order store (simulates local DB)
  final List<Order> _orders = [];
  Business? _cachedBusiness;
  List<Product>? _cachedProducts;

  PosRepositoryImpl({required this.localDataSource});

  @override
  Future<Business> loadBusiness() async {
    _cachedBusiness ??= await localDataSource.loadBusiness();
    return _cachedBusiness!;
  }

  @override
  Future<bool> authenticate(String businessId, String passcode) async {
    final business = await loadBusiness();
    return business.businessId.toLowerCase() == businessId.toLowerCase() &&
        business.passcode == passcode;
  }

  @override
  Future<List<Category>> getCategories() async {
    return localDataSource.loadCategories();
  }

  @override
  Future<List<Product>> getProducts() async {
    _cachedProducts ??= await localDataSource.loadProducts();
    return _cachedProducts!;
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final products = await getProducts();
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    final lower = query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Customer>> getCustomers() async {
    return localDataSource.loadCustomers();
  }

  @override
  Future<List<RestaurantTable>> getTables() async {
    return localDataSource.loadTables();
  }

  @override
  Future<void> saveOrder(Order order) async {
    _orders.add(order);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    _orders.removeWhere((o) => o.id == orderId);
  }

  @override
  Future<List<Order>> getOrders() async {
    return List.unmodifiable(_orders);
  }

  @override
  Future<List<Order>> getPendingOrders() async {
    return _orders.where((o) => o.status == OrderStatus.pending).toList();
  }

  @override
  Future<List<Order>> getSettledOrders() async {
    return _orders.where((o) => o.status == OrderStatus.settled).toList();
  }
}
