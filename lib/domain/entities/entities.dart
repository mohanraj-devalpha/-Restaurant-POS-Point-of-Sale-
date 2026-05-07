// Domain Entities
import 'package:equatable/equatable.dart';

// ─── Category ─────────────────────────────────────────
class Category extends Equatable {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, icon];
}

// ─── Product ──────────────────────────────────────────
class Product extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final double originalPrice;
  final String image;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, categoryId, price, originalPrice, image, description];
}

// ─── Customer ─────────────────────────────────────────
class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, phone];
}

// ─── Table ────────────────────────────────────────────
class RestaurantTable extends Equatable {
  final String id;
  final String name;
  final int capacity;

  const RestaurantTable({
    required this.id,
    required this.name,
    required this.capacity,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, capacity];
}

// ─── Business ─────────────────────────────────────────
class Business extends Equatable {
  final String id;
  final String name;
  final String businessId;
  final String passcode;
  final String address;
  final String phone;
  final String email;
  final String currency;
  final double taxRate;

  const Business({
    required this.id,
    required this.name,
    required this.businessId,
    required this.passcode,
    required this.address,
    required this.phone,
    required this.email,
    required this.currency,
    required this.taxRate,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      businessId: json['businessId'] as String,
      passcode: json['passcode'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      currency: json['currency'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, businessId, passcode, address, phone, email, currency, taxRate];
}

// ─── Order Type ───────────────────────────────────────
enum OrderType { dineIn, takeaway, delivery }

// ─── Payment Type ─────────────────────────────────────
enum PaymentType { card, cash, upi }

// ─── Order Status ─────────────────────────────────────
enum OrderStatus { pending, settled, cancelled }

// ─── Cart Item ────────────────────────────────────────
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

// ─── Order ────────────────────────────────────────────
class Order extends Equatable {
  final String id;
  final String orderNumber;
  final OrderType orderType;
  final PaymentType? paymentType;
  final OrderStatus status;
  final List<CartItem> items;
  final String? tableId;
  final String? tableName;
  final String? customerId;
  final String? customerName;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? settledAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    this.paymentType,
    required this.status,
    required this.items,
    this.tableId,
    this.tableName,
    this.customerId,
    this.customerName,
    required this.totalAmount,
    required this.createdAt,
    this.settledAt,
  });

  Order copyWith({
    String? id,
    String? orderNumber,
    OrderType? orderType,
    PaymentType? paymentType,
    OrderStatus? status,
    List<CartItem>? items,
    String? tableId,
    String? tableName,
    String? customerId,
    String? customerName,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? settledAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      items: items ?? this.items,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        orderType,
        paymentType,
        status,
        items,
        tableId,
        tableName,
        customerId,
        customerName,
        totalAmount,
        createdAt,
        settledAt,
      ];
}
