import 'package:flutter/material.dart';

/// Palet warna resmi FindIT Campus berdasarkan Design System Figma (Kelompok 2 SI 2024A).
/// Berisi nilai primitif sumber serta pemetaan token semantik untuk mode Terang & Gelap.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. WARNA PRIMITIF (NILAI SUMBER FIGMA)
  // ===========================================================================
  static const Color teal600 = Color(0xFF1F7A6D); // Primary - aksi utama
  static const Color teal700 = Color(0xFF17695D); // Primary - aktif / pressed / focus
  static const Color green950 = Color(0xFF12312E); // Teks utama / Ink (kontras tinggi)
  static const Color green900 = Color(0xFF0D4F44); // Label ditemukan / Surface mode gelap
  static const Color slate700 = Color(0xFF4F625E); // Teks sekunder
  static const Color slate600 = Color(0xFF5E6E6A); // Placeholder & navigasi inaktif
  static const Color paper50 = Color(0xFFFBF8F3); // Latar hangat (warm canvas)
  static const Color white = Color(0xFFFFFFFF); // Permukaan (surface neutral)
  static const Color sand100 = Color(0xFFEEE9E0); // Secondary netral
  static const Color coral500 = Color(0xFFF2603F); // Accent laporan hilang
  static const Color peach200 = Color(0xFFFFD9CC); // Aksi cepat hilang
  static const Color peach100 = Color(0xFFFFE0D6); // Chip hilang
  static const Color rust900 = Color(0xFF6B210F); // Label aksi hilang
  static const Color rust800 = Color(0xFF8A2E15); // Label chip hilang & border error
  static const Color mint300 = Color(0xFFBFE9DA); // Aksi cepat temuan & Primary mode gelap
  static const Color mint200 = Color(0xFFCFEFE3); // Chip ditemukan & Teks sekunder gelap
  static const Color yellow200 = Color(0xFFFFE8A3); // Tile barang
  static const Color sage100 = Color(0xFFD9E3DF); // Garis input (border default)
  static const Color sage400 = Color(0xFF9FC9BE); // Garis unggah (upload border)
  static const Color sage50 = Color(0xFFE4ECE8); // Track progres bar
  static const Color whatsapp700 = Color(0xFF12723B); // Tombol WhatsApp resmi

  // ===========================================================================
  // 2. TOKEN SEMANTIK - MODE TERANG (LIGHT THEME)
  // ===========================================================================
  static const Color bgCanvas = paper50;
  static const Color bgSurface = white;
  static const Color textPrimary = green950;
  static const Color textSecondary = slate700;
  static const Color textPlaceholder = slate600;

  static const Color actionPrimary = teal600;
  static const Color actionPressed = teal700;
  static const Color actionOnPrimary = white;

  static const Color actionSecondary = sand100;
  static const Color actionOnSecondary = green950;

  static const Color borderDefault = sage100;
  static const Color borderFocus = teal700;
  static const Color borderError = rust800;

  static const Color progressTrack = sage50;
  static const Color progressValue = teal600;

  // ===========================================================================
  // 3. TOKEN SEMANTIK - MODE GELAP (DARK THEME USULAN)
  // ===========================================================================
  static const Color darkBgCanvas = green950;
  static const Color darkBgSurface = green900;
  static const Color darkTextPrimary = paper50;
  static const Color darkTextSecondary = mint200;
  static const Color darkTextPlaceholder = mint200;

  static const Color darkActionPrimary = mint300;
  static const Color darkActionPressed = mint200;
  static const Color darkActionOnPrimary = green950;

  static const Color darkActionSecondary = green900;
  static const Color darkActionOnSecondary = paper50;

  static const Color darkBorderDefault = sage400;
  static const Color darkBorderFocus = mint300;
  static const Color darkBorderError = peach200;

  static const Color darkProgressTrack = green900;
  static const Color darkProgressValue = mint300;

  // ===========================================================================
  // 4. STATUS & AKSI KHUSUS (BERLAKU DI SEMUA MODE)
  // ===========================================================================
  // Laporan Hilang
  static const Color actionLost = coral500;
  static const Color actionOnLost = green950; // Ink label di atas coral untuk rasio kontras 4.33:1
  static const Color chipLostBg = peach100;
  static const Color chipLostText = rust800;

  // Laporan Ditemukan
  static const Color chipFoundBg = mint200;
  static const Color chipFoundText = green900;

  // WhatsApp
  static const Color actionWhatsapp = whatsapp700;
  static const Color actionOnWhatsapp = white;
}

