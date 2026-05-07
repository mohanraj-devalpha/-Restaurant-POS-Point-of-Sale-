import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/entities.dart';

class LocalDataSource {
  Future<Business> loadBusiness() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/business.json');
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return Business.fromJson(json);
  }

  Future<List<Category>> loadCategories() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/categories.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> loadProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Customer>> loadCustomers() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/customers.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RestaurantTable>> loadTables() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/tables.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => RestaurantTable.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
