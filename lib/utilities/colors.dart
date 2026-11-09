import 'package:flutter/material.dart';

/// Design tokens mapping directly from AGENT_BRIEF.md Section 4
class AppColors {
  // Brand & Neutrals (Light Mode)
  static const ink = Color(0xFF0B1220); // Teks utama, header gelap, layar Tap, kartu saldo
  static const ground = Color(0xFFF4F5F7); // Latar layar
  static const surface = Color(0xFFFFFFFF); // Kartu, input, bottom bar
  static const line = Color(0xFFE4E7EC); // Border dan pemisah
  static const muted = Color(0xFF5B6577); // Teks sekunder
  static const accent = Color(0xFF1F4DFF); // Tombol utama, tab aktif, link
  static const accentSoft = Color(0xFF8FA8FF); // Huruf "U", garis grafik, aksen terang
  static const onDarkMuted = Color(0xFFA9B4CC); // Teks sekunder di atas latar ink

  // Status colors
  static const success = Color(0xFF00875A);
  static const successBg = Color(0xFFE3F6EE);
  static const successText = Color(0xFF006B47);

  static const danger = Color(0xFFB4132B);
  static const dangerBg = Color(0xFFFDE8EC);

  static const warning = Color(0xFF8A5200);
  static const warningBg = Color(0xFFFFF0D4);

  // Card Brand Colors
  static const cardVisa = Color(0xFF1A3FC4);
  static const cardMastercard = Color(0xFFC2410C);
  static const cardGpn = Color(0xFF9F1239);
  static const cardJcb = Color(0xFF0E509F);
  static const cardOther = ink;

  // Dark Mode tokens
  static const groundDark = Color(0xFF070F1F);
  static const surfaceDark = Color(0xFF0F1A30);
  static const lineDark = Color(0xFF1F2D49);
  static const textDark = Color(0xFFE9EEFB);
  static const mutedDark = Color(0xFF8E9BB5);
  static const accentDark = Color(0xFF4B8BFF);
  static const chipBgDark = Color(0xFF16284D);

  // Aliases for compatibility with existing widgets
  static const primary = accent;
  static const primaryDark = ink;
  static const primarySoft = accentSoft;
  static const textPrimary = ink;
  static const textSecondary = muted;
  static const textHint = muted;
  static const background = ground;
  static const border = line;
  static const disabled = Color(0xFFD1D5DB);
  static const error = danger;
}
