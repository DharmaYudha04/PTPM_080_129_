import 'package:flutter/cupertino.dart';

class CategoryModel {
  const CategoryModel({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
