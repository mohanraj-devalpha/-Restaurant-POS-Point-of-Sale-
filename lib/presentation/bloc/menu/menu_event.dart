import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object?> get props => [];
}

class MenuLoadData extends MenuEvent {
  const MenuLoadData();
}

class MenuCategorySelected extends MenuEvent {
  final String? categoryId;
  const MenuCategorySelected(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class MenuOrderTypeChanged extends MenuEvent {
  final OrderType orderType;
  const MenuOrderTypeChanged(this.orderType);
  @override
  List<Object?> get props => [orderType];
}

class MenuTableSelected extends MenuEvent {
  final RestaurantTable? table;
  const MenuTableSelected(this.table);
  @override
  List<Object?> get props => [table];
}

class MenuCustomerSelected extends MenuEvent {
  final Customer? customer;
  const MenuCustomerSelected(this.customer);
  @override
  List<Object?> get props => [customer];
}

class MenuViewToggled extends MenuEvent {
  const MenuViewToggled();
}

class MenuSearchQueryChanged extends MenuEvent {
  final String query;
  const MenuSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class MenuSearchToggled extends MenuEvent {
  const MenuSearchToggled();
}
