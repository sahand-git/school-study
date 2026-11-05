import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surface
  static const Color background = Color(0xFF0F172A);      // Deep Slate 900
  static const Color surface = Color(0xFF1E293B);         // Slate 800
  static const Color surfaceLight = Color(0xFF334155);    // Slate 700
  static const Color cardBorder = Color(0xFF334155);

  // Kurdish Theme & Accents
  static const Color emerald = Color(0xFF10B981);         // Kurdish Spring Green
  static const Color amber = Color(0xFFF59E0B);           // Kurdish Sun Gold
  static const Color crimson = Color(0xFFEF4444);         // Exam Alert Red
  static const Color indigo = Color(0xFF6366F1);          // Vibrant Royal Indigo
  static const Color cyan = Color(0xFF06B6D4);            // Sky Blue
  static const Color purple = Color(0xFF8B5CF6);          // Deep Violet
  static const Color pink = Color(0xFFEC4899);            // Biology Pink

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient sunGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
