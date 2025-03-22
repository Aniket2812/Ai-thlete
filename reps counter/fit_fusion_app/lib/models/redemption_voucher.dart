import 'package:flutter/material.dart';

class RedemptionVoucher {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final String category;
  
  RedemptionVoucher({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class VoucherCategory {
  final String id;
  final String name;
  final IconData icon;
  
  VoucherCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}
