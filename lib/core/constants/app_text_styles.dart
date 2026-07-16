import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Color(0xFF212121),
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Color(0xFF757575),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: Color(0xFF757575),
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2196F3),
  );
}
