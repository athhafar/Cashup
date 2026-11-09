import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final Color color;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.color = const Color(0xFF1F4DFF),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'Umum',
        price: json['price'] as int,
        icon: Icons.fastfood_rounded,
      );
}
