// status_categories = OrderStatus { pending, paid, cancelled, completed }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Order {
  final String id;
  final String userId;
  final String cartId;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      cartId: map['cartId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cartId': cartId,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Order copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id,
      userId: userId,
      cartId: cartId,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// Order Model
enum OrderStatus { pending, cancelled, paid }

extension OrderStatusName on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.paid:
        return 'paid';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.paid:
        return 'Paid';
    }
  }
}

class ShippingAddress extends Equatable {
  final String name;
  final String location;
  final String phone;

  const ShippingAddress({
    required this.name,
    required this.location,
    required this.phone,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [name, location, phone];
}

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String cartId;
  final double totalAmount;
  final OrderStatus status;
  final String? paymentMethod;
  final ShippingAddress shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      cartId: data['cartId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: _parseOrderStatus(data['status']),
      paymentMethod: data['paymentMethod'],
      shippingAddress: ShippingAddress.fromMap(
          data['shippingAddress'] ?? {'name': '', 'location': '', 'phone': ''}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cartId': cartId,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static OrderStatus _parseOrderStatus(String? value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'paid':
        return OrderStatus.paid;
      default:
        return OrderStatus.pending;
    }
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      cartId: cartId,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        cartId,
        totalAmount,
        status,
        paymentMethod,
        shippingAddress,
        createdAt,
        updatedAt,
      ];
}
