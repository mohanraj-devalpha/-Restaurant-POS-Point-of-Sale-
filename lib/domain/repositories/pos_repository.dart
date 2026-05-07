import '../entities/entities.dart';

abstract class PosRepository {
  // Auth
  Future<Business> loadBusiness();
  Future<bool> authenticate(String businessId, String passcode);

  // Data
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<List<Customer>> getCustomers();
  Future<List<RestaurantTable>> getTables();

  // Orders
  Future<void> saveOrder(Order order);
  Future<void> updateOrder(Order order);
  Future<void> deleteOrder(String orderId);
  Future<List<Order>> getOrders();
  Future<List<Order>> getPendingOrders();
  Future<List<Order>> getSettledOrders();
}
