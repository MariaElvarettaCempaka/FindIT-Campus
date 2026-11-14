import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item model lokasi kampus
class CampusLocationItem {
  final String id;
  final String name;
  final String zone;
  final String category; // 'gps', 'hotspot', 'kampus'
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int activeReportsCount;

  const CampusLocationItem({
    required this.id,
    required this.name,
    required this.zone,
    required this.category,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.activeReportsCount,
  });
}

/// Tampilkan Command Palette Modal (Mobile-First Apple Spotlight Style)
Future<String?> showLocationCommandPalette(
  BuildContext context, {
  required String currentLocation,
}) {
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup Command Palette',
    barrierColor: Colors.black.withValues(alpha: 0.54),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, anim1, anim2) {
      return LocationCommandPalette(currentLocation: currentLocation);
    },
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curvedAnim = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnim),
          child: child,
        ),
      );
    },
  );
}

/// Command Palette Dialog Widget (Dioptimalkan untuk Mobile / HP)
class LocationCommandPalette extends StatefulWidget {
  final String currentLocation;

  const LocationCommandPalette({
    super.key,
    required this.currentLocation,
  });

  @override
  State<LocationCommandPalette> createState() => _LocationCommandPaletteState();
}

class _LocationCommandPaletteState extends State<LocationCommandPalette> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  int? _hoveredIndex;
  bool _isLocatingGps = false;

  // Database Lokasi & Hotspot Kampus
  final List<CampusLocationItem> _allLocations = const [
    CampusLocationItem(
      id: 'gps',
      name: 'Gunakan Lokasi Saat Ini (GPS)',
      zone: 'Deteksi otomatis gedung & area terdekatmu',
      category: 'gps',
      icon: Icons.my_location_rounded,
      iconBg: Color(0xFFE8F5F1),
      iconColor: Color(0xFF17695D),
      activeReportsCount: 0,
    ),
    // Hotspot Populer
    CampusLocationItem(
      id: 'perpus_pusat',
      name: 'Perpustakaan Pusat UNESA',
      zone: 'Gedung Perpustakaan, Lt. 1 & 2 • Ketintang',
      category: 'hotspot',
      icon: Icons.menu_book_rounded,
      iconBg: Color(0xFFEBF3FF),
      iconColor: Color(0xFF2563EB),
      activeReportsCount: 8,
    ),
    CampusLocationItem(
      id: 'kantin_pusat',
      name: 'Kantin Pusat & Food Court',
      zone: 'Area Pujasera & Kasir Utama • Ketintang',
      category: 'hotspot',
      icon: Icons.restaurant_rounded,
      iconBg: Color(0xFFFFF1EB),
      iconColor: Color(0xFFE0533C),
      activeReportsCount: 12,
    ),
    CampusLocationItem(
      id: 'gkb',
      name: 'Gedung Kuliah Bersama (GKB)',
      zone: 'Lantai 1-5 • Ruang Perkuliahan Mahasiswa',
      category: 'hotspot',
      icon: Icons.school_rounded,
      iconBg: Color(0xFFF0EBF8),
      iconColor: Color(0xFF7C3AED),
      activeReportsCount: 15,
    ),
    CampusLocationItem(
      id: 'gor_bima',
      name: 'GOR Bima & Lapangan Olahraga',
      zone: 'Tribun Penonton, Loker, & Lapangan',
      category: 'hotspot',
      icon: Icons.fitness_center_rounded,
      iconBg: Color(0xFFFEF9C3),
      iconColor: Color(0xFFCA8A04),
      activeReportsCount: 4,
    ),
    CampusLocationItem(
      id: 'masjid_kampus',
      name: 'Masjid Kampus Baitul Makmur',
      zone: 'Selasar Utama & Area Tempat Wudhu',
      category: 'hotspot',
      icon: Icons.mosque_rounded,
      iconBg: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      activeReportsCount: 3,
    ),
    CampusLocationItem(
      id: 'parkir_utama',
      name: 'Area Parkir Motor Mahasiswa',
      zone: 'Pos Satpam Barat & Parkir Terpadu',
      category: 'hotspot',
      icon: Icons.local_parking_rounded,
      iconBg: Color(0xFFF1F5F9),
      iconColor: Color(0xFF475569),
      activeReportsCount: 6,
    ),
    // Pilihan Kampus Utama
    CampusLocationItem(
      id: 'unesa_ketintang',
      name: 'UNESA Kampus Ketintang',
      zone: 'Surabaya Selatan • Kampus Utama 1',
      category: 'kampus',
      icon: Icons.apartment_rounded,
      iconBg: Color(0xFFE8F5F1),
      iconColor: Color(0xFF17695D),
      activeReportsCount: 28,
    ),
    CampusLocationItem(
      id: 'unesa_lidah_wetan',
      name: 'UNESA Kampus Lidah Wetan',
      zone: 'Surabaya Barat • Kampus Utama 2',
      category: 'kampus',
      icon: Icons.apartment_rounded,
      iconBg: Color(0xFFE8F5F1),
      iconColor: Color(0xFF17695D),
      activeReportsCount: 19,
    ),
    CampusLocationItem(
      id: 'unesa_magetan',
      name: 'UNESA Kampus Magetan',
      zone: 'Magetan, Jawa Timur • Kampus Luar Kota',
      category: 'kampus',
      icon: Icons.apartment_rounded,
      iconBg: Color(0xFFE8F5F1),
      iconColor: Color(0xFF17695D),
      activeReportsCount: 5,
    ),
    CampusLocationItem(
      id: 'ui_depok',
      name: 'Sekitar Depok, Jawa Barat',
      zone: 'Universitas Indonesia & Sekitarnya',
      category: 'kampus',
      icon: Icons.location_on_rounded,
      iconBg: Color(0xFFFFECE5),
      iconColor: Color(0xFFE0533C),
      activeReportsCount: 14,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<CampusLocationItem> get _filteredLocations {
    if (_query.isEmpty) return _allLocations;
    return _allLocations.where((loc) {
      return loc.name.toLowerCase().contains(_query) ||
          loc.zone.toLowerCase().contains(_query);
    }).toList();
  }

  void _selectLocation(CampusLocationItem item) async {
    if (item.category == 'gps') {
      if (_isLocatingGps) return;
      setState(() => _isLocatingGps = true);
      // shortcut: simulated GPS resolution, upgrade to geolocator when Android/iOS manifests and device testing are ready
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, 'UNESA Ketintang (GPS Terdekat)');
    } else {
      Navigator.pop(context, item.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLocations;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        top: topPadding + 16,
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
        left: 16,
        right: 16,
      ),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth > 500 ? 440 : double.infinity,
            constraints: BoxConstraints(
              maxHeight: bottomInset > 0
                  ? screenHeight * 0.48
                  : screenHeight * 0.62,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF12312E).withValues(alpha: 0.22),
                  offset: const Offset(0, 16),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Mobile Apple Search Header dengan tombol "Batal"
                    _buildMobileSearchHeader(),

                    // Divider Halus
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: const Color(0xFFDEE8E2).withValues(alpha: 0.7),
                    ),

                    // 2. Body List (Scrollable Hasil / Kategori)
                    Flexible(
                      child: filtered.isEmpty
                          ? _buildEmptySearchState()
                          : _buildLocationList(filtered),
                    ),

                    // Divider Halus
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: const Color(0xFFDEE8E2).withValues(alpha: 0.7),
                    ),

                    // 3. Apple Mobile Footer Strip
                    _buildFooterHint(filtered.length),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. MOBILE APPLE SEARCH HEADER
  // Desain kapsul pencarian iOS yang menyatu, tanpa tombol desktop (ESC)
  // ===========================================================================
  Widget _buildMobileSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Apple Unified Search Input Pill
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2EBE6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: Color(0xFF17695D),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      autofocus: false, // Tidak langsung menutupi layar saat dibuka
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF12312E),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        hintText: 'Cari gedung, kampus, atau area...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8B9D98),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B9D98).withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tombol "Batal" Khas iOS Mobile
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF17695D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. LIST HASIL & KATEGORI LOKASI
  // ===========================================================================
  Widget _buildLocationList(List<CampusLocationItem> items) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = widget.currentLocation.contains(item.name) ||
              item.name.contains(widget.currentLocation);
          final isHovered = _hoveredIndex == index;

          // Header Kategori jika query kosong
          Widget? sectionHeader;
          if (_query.isEmpty) {
            if (index == 0) {
              sectionHeader = _buildSectionTitle('LOKASI SAAT INI');
            } else if (index == 1) {
              sectionHeader = _buildSectionTitle('HOTSPOT POPULER KAMPUS');
            } else if (index == 7) {
              sectionHeader = _buildSectionTitle('PILIHAN KAMPUS UTAMA');
            }
          } else if (index == 0) {
            sectionHeader =
                _buildSectionTitle('HASIL PENCARIAN (${items.length})');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?sectionHeader,
              GestureDetector(
                onTapDown: (_) => setState(() => _hoveredIndex = index),
                onTapUp: (_) {
                  setState(() => _hoveredIndex = null);
                  _selectLocation(item);
                },
                onTapCancel: () => setState(() => _hoveredIndex = null),
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: isHovered ? 0.985 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF17695D).withValues(alpha: 0.08)
                          : (isHovered
                              ? const Color(0xFF12312E).withValues(alpha: 0.04)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF17695D)
                                  .withValues(alpha: 0.20),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Ikon Kategori
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              color: item.iconColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nama & Zona
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: const Color(0xFF12312E),
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category == 'gps' && _isLocatingGps
                                    ? 'Mendeteksi koordinat terdekat...'
                                    : item.zone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: item.category == 'gps' && _isLocatingGps
                                      ? const Color(0xFF17695D)
                                      : const Color(0xFF5E6E6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Badge Indikator Aktif / Loading GPS / Checkmark
                        if (item.category == 'gps' && _isLocatingGps)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF17695D),
                              ),
                            ),
                          )
                        else if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF17695D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          )
                        else if (item.activeReportsCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17695D)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.activeReportsCount} laporan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF17695D),
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFFB0BFBA),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: const Color(0xFF8B9D98),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF64748B),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lokasi tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF12312E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ketik nama gedung, fakultas, atau area kampus lainnya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5E6E6A),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. MOBILE APPLE FOOTER STRIP
  // ===========================================================================
  Widget _buildFooterHint(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFBF8F3).withValues(alpha: 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.touch_app_outlined,
                size: 13,
                color: Color(0xFF7A8E88),
              ),
              const SizedBox(width: 5),
              Text(
                'Pilih lokasi untuk memfilter laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7A8E88),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF12312E).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count area',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5E6E6A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
