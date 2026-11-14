import 'package:flutter/material.dart';

/// Dimensi, jarak (spacing), radius, dan elevasi resmi FindIT Campus.
/// Diekstraksi langsung dari dokumentasi Figma Fondasi & Katalog Komponen.
class AppDimens {
  AppDimens._();

  // ===========================================================================
  // 1. SPACING / JARAK (PX)
  // ===========================================================================
  static const double space0 = 0.0;
  static const double space5 = 5.0;
  static const double space9 = 9.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space26 = 26.0;
  static const double space32 = 32.0;
  static const double space99 = 99.0;

  // Jarak Layar
  static const double screenInset = 22.0; // Inset layar horizontal
  static const double screenTop = 28.0; // Jarak awal layar atas

  // ===========================================================================
  // 2. CORNER RADIUS (PX)
  // ===========================================================================
  static const double radius0 = 0.0;
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0; // Button Hilang kecil
  static const double radius14 = 14.0; // Input Text Field
  static const double radius16 = 16.0; // Tile thumbnail gambar
  static const double radius18 = 18.0; // Primary, Secondary, WhatsApp buttons
  static const double radius20 = 20.0; // Kartu barang & Aksi cepat
  static const double radius26 = 26.0; // Floating Bottom Navigation Dock
  static const double radius99 = 99.0; // Search bar & Tag chips (Pill)

  // ===========================================================================
  // 3. UKURAN KOMPONEN SPESIFIK
  // ===========================================================================
  // Tombol
  static const double buttonPrimaryHeight = 54.0;
  static const double buttonSecondaryHeight = 40.0;
  static const double buttonLostHeight = 44.0;
  static const double buttonWhatsappHeight = 54.0;

  // Input & Search
  static const double inputFieldHeight = 48.0;
  static const double searchBarHeight = 52.0;

  // Kartu & Aksi
  static const double quickActionHeight = 92.0;
  static const double itemCardHeight = 84.0;
  static const double itemTileSize = 60.0;

  // Navigasi & Progres
  static const double navBarHeight = 68.0;
  static const double navBarWidth = 358.0;
  static const double fabSize = 56.0;
  static const double progressBarHeight = 6.0;

  // Border Strokes
  static const double borderDefaultStroke = 1.5;
  static const double borderFocusStroke = 2.0;
  static const double borderUploadStroke = 2.0;

  // ===========================================================================
  // 4. BAYANGAN (ELEVATION & SHADOWS)
  // ===========================================================================
  // Bayangan Kartu: y 4, blur 14, 7% opacity
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x1212312E), // ~7% opacity of #12312E
          offset: Offset(0, 4),
          blurRadius: 14,
          spreadRadius: 0,
        ),
      ];

  // Bayangan Navigasi: y 10, blur 30, 14% opacity
  static List<BoxShadow> get navShadow => [
        const BoxShadow(
          color: Color(0x2412312E), // ~14% opacity of #12312E
          offset: Offset(0, 10),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ];

  // Bayangan FAB: y 8, blur 18, 30% opacity
  static List<BoxShadow> get fabShadow => [
        const BoxShadow(
          color: Color(0x4D12312E), // ~30% opacity of #12312E
          offset: Offset(0, 8),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];
}

