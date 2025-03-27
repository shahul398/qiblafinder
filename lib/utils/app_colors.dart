import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const primary = Color(0xFF3A7D44);       // Green
  static const secondary = Color(0xFF2B5F75);     // Blue
  static const accent = Color(0xFFFFB81C);        // Gold/Yellow
  
  // UI colors
  static const background = Color(0xFFF8F8F8);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  
  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFE53935);
  
  // Gradients
  static final primaryGradient = LinearGradient(
    colors: [primary, primary.withGreen(primary.green + 30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static final accentGradient = LinearGradient(
    colors: [accent, accent.withRed(accent.red - 20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 