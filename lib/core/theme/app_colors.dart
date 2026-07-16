import 'package:flutter/material.dart';

/// Centralized color palette for PulseIQ.
/// Nothing outside this file should ever write Color(0x...) or Colors.xyz
/// directly — every color in the app traces back to here. This is what
/// let the whole app support Light/Dark mode from Day 1 without ever
/// touching a screen file again.
class AppColors {
  AppColors._(); // static-only class, never instantiated

  // ---- BRAND -----------------------------------------------------------
  // Deliberately not a default Material color (Colors.blue etc.) — picked
  // an original palette so the app doesn't look like every other Flutter
  // tutorial project.
  static const Color primary = Color(
    0xFF5B5FEF,
  ); // Electric Indigo — trust, intelligence
  static const Color secondary = Color(
    0xFF00D9A3,
  ); // Pulse Mint — energy, vitality

  // ---- SEMANTIC ----------------------------------------------------------
  // Each color has ONE fixed meaning everywhere in the app — e.g. workout
  // orange is always workout-related, never reused for something else.
  // This is what makes a screen readable at a glance without labels.

  static const Color health = Color(
    0xFF22C55E,
  ); // water, nutrition, "good" states
  static const Color recovery = Color(
    0xFF3B82F6,
  ); // reserved for future sleep/rest features
  static const Color workout = Color(0xFFFF7A45); // exercise, calories burned
  static const Color ai = Color(
    0xFFA855F7,
  ); // reserved for the Version 2 AI Coach
  static const Color warning = Color(0xFFEF4444); // errors, delete actions

  // ---- LIGHT THEME SURFACES ----------------------------------------------
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1C1E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);

  // ---- DARK THEME SURFACES -------------------------------------------------
  // Not just an inverted light theme — background is a near-black navy
  // (not pure #000000), which is easier on the eyes on OLED screens and
  // still lets card borders (below) stay visible against it.
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF1B1E24);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFA0A4AB);
  static const Color borderDark = Color(0xFF2A2D34);
}
