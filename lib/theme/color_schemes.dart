import 'package:flutter/material.dart';

// Cor semente do app (baseada na identidade visual)
const Color _seedColor = Color(0xFFDF9E1C); // Dourado/Âmbar do app

// Gera ColorScheme claro automaticamente
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.light,
);

// Gera ColorScheme escuro automaticamente
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.dark,
);
