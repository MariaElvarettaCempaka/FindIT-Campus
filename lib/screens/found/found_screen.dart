import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/location_command_palette.dart';
import '../../widgets/notification_command_palette.dart';
import '../../widgets/app_toast_stack.dart';
import '../../widgets/status_chip.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_report_screen.dart';
import '../../models/report_item_model.dart';
import '../../services/report_service.dart';

/// Halaman Barang Ditemukan (Found Screen) — FindIT Campus
///
/// Modul resmi Orang 2 (Beranda & Feed - Kelompok 2 PAB SI UNESA 2026).
/// Mengadopsi prinsip Apple Fluid Interfaces (WWDC 2018) & Anti-UI-Slop:
/// 1. Tactile compression feedback (scale: 0.98 pada kartu temuan, scale: 0.92 pada pill filter).
/// 2. Titik Pengamanan Aman (Safe Handover Spot): Pos Satpam, Dipegang Mahasiswa, atau Loket Resmi.
/// 3. Filter multi-dimensi instan (kategori barang & filter titik penyimpanan).
/// 4. Apple-style Action BottomSheet untuk panduan klaim & kontak langsung WhatsApp.
/// 5. Apple-standard Empty State dengan empati dan aksi solutif.
class FoundScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialStorageFilter;

  const FoundScreen({
    super.key,
    this.initialCategory,
    this.initialStorageFilter,
  });

  @override
  State<FoundScreen> createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  // State Navigasi
  final int _currentNavIndex = 2; // Tab Ditemukan aktif

  // State Search & Filter
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  int _selectedCategoryIndex = 0;
  int? _pressedCategoryIndex;

  String _selectedStorageFilter = 'semua'; // 'semua', 'satpam', 'student', 'official'
  bool _isSortLatest = true;
  bool _isSortPressed = false;
  bool _isLocationPressed = false;

  // Lokasi Kampus Aktif
  String _currentCampusLocation = 'UNESA Kampus Ketintang, Surabaya';

  // State Notifikasi & Interaksi Header
  bool _isBellPressed = false;
  int _unreadNotifCount = 3;

  // Kategori Barang
  final List<String> _categories = [
    'Semua',
    'Kunci',
    'Dompet',
    'Elektronik',
    'KTM & Dokumen',
    'Aksesoris',
  ];

  // Kampus terpilih dari Location Command Palette
  String get _selectedCampus =>
      _currentCampusLocation.toLowerCase().contains('lidah') ? 'Lidah Wetan' : 'Ketintang';

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      final index = _categories.indexOf(widget.initialCategory!);
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
    if (widget.initialStorageFilter != null) {
      _selectedStorageFilter = widget.initialStorageFilter!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // FILTER & SORT LOGIC UNTUK REPORT FIRESTORE
  // ===========================================================================
  List<ReportItemModel> _filterReports(List<ReportItemModel> items) {
    final query = _searchQuery.trim().toLowerCase();
    final selectedCategory = _categories[_selectedCategoryIndex];

    return items.where((item) {
      // Filter Kategori
      if (selectedCategory != 'Semua') {
        final cat = item.category.toLowerCase();
        final sel = selectedCategory.toLowerCase();
        if (sel == 'elektronik') {
          if (cat != 'elektronik' && cat != 'hp') return false;
        } else if (sel.contains('ktm') || sel.contains('dokumen')) {
          if (!cat.contains('ktm') && !cat.contains('dokumen')) return false;
        } else if (cat != sel) {
          return false;
        }
      }

      // Filter Titik Penyimpanan (Storage Type)
      if (_selectedStorageFilter != 'semua' &&
          (item.storageType ?? 'satpam') != _selectedStorageFilter) {
        return false;
      }

      // Filter Query Pencarian
      if (query.isNotEmpty) {
        final title = item.title.toLowerCase();
        final loc = item.location.toLowerCase();
        final desc = item.description.toLowerCase();
        final storage = (item.storageLabel ?? '').toLowerCase();
        final matches = title.contains(query) ||
            loc.contains(query) ||
            desc.contains(query) ||
            storage.contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (!_isSortLatest) {
          if (a.createdAt != null && b.createdAt != null) {
            return a.createdAt!.compareTo(b.createdAt!);
          }
          return a.id.compareTo(b.id);
        }
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return b.id.compareTo(a.id);
      });
  }

  // ===========================================================================
  // MODAL COMMAND PALETTE LOKASI KAMPUS
  // ===========================================================================
  Future<void> _openLocationPalette() async {
    final selected = await showLocationCommandPalette(
      context,
      currentLocation: _currentCampusLocation,
    );
    if (selected != null && mounted) {
      setState(() {
        _currentCampusLocation = selected;
      });
      AppToast.info(
        context,
        title: 'Lokasi Kampus Diubah',
        message: 'Menampilkan barang temuan di area $selected.',
      );
    }
  }



  // ===========================================================================
  // ACTION SHEET DETAIL PENGAMBILAN & PROTEKSI ANTI-LEAKAGE BARANG TEMUAN
  // ===========================================================================
  void _showClaimDetailsModal(Map<String, dynamic> item) {
    final reportId = item['id']?.toString() ?? '';
    if (reportId.isNotEmpty) {
      ReportService.incrementViewCount(reportId);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final storageType = item['storageType'] as String;
        final images = (item['images'] as List<String>?) ?? <String>[];
        int activePhotoIndex = 0;

        Color badgeColor;
        Color badgeTextColor;
        String badgeTitle;

        if (storageType == 'satpam') {
          badgeColor = const Color(0xFF17695D).withValues(alpha: 0.12);
          badgeTextColor = const Color(0xFF0D4F44);
          badgeTitle = 'Diamankan di Pos Satpam';
        } else if (storageType == 'official') {
          badgeColor = const Color(0xFFFFE8A3).withValues(alpha: 0.35);
          badgeTextColor = const Color(0xFF7A5400);
          badgeTitle = 'Dititipkan di Loket Resmi Kampus';
        } else {
          badgeColor = const Color(0xFFCFEFE3).withValues(alpha: 0.50);
          badgeTextColor = const Color(0xFF0D4F44);
          badgeTitle = 'Masih Dipegang Penemu (Mahasiswa)';
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgCanvas,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.88,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Apple Grab Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12312E)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Header Modal: Status Chip & Judul
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        StatusChip.found(),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: badgeColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            badgeTitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: badgeTextColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['title'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(modalContext),
                                icon: const Icon(Icons.close_rounded),
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ===================================================
                          // 1. GALERI GAMBAR APPLE (MULTI-PHOTO PREVIEW)
                          // ===================================================
                          if (images.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 185,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF17695D)
                                      .withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: const Color(0xFF12312E)
                                        .withValues(alpha: 0.10),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: images.length,
                                      onPageChanged: (idx) {
                                        setModalState(() {
                                          activePhotoIndex = idx;
                                        });
                                      },
                                      itemBuilder: (context, idx) {
                                        return Image.asset(
                                          images[idx],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Center(
                                            child: Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Color(0xFF17695D),
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Watermark Tag Perlindungan Anti-Leakage
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.60),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Ciri Rahasia Disamarkan',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Counter Foto Pill (Bottom Right)
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '📷 ${activePhotoIndex + 1} / ${images.length} Foto',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Dot Indicators jika lebih dari 1 foto
                                    if (images.length > 1)
                                      Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            images.length,
                                            (dotIdx) => Container(
                                              width: activePhotoIndex == dotIdx
                                                  ? 16
                                                  : 6,
                                              height: 6,
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 3),
                                              decoration: BoxDecoration(
                                                color: activePhotoIndex ==
                                                        dotIdx
                                                    ? Colors.white
                                                    : Colors.white.withValues(
                                                        alpha: 0.45),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Placeholder saat foto sengaja disembunyikan
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF17695D)
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF17695D)
                                          .withValues(alpha: 0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData? ??
                                          Icons.privacy_tip_outlined,
                                      color: const Color(0xFF17695D),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dokumentasi Blind-Protection',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Foto tidak dipublikasikan ke publik demi mencegah pemalsuan identitas.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // ===================================================
                          // 2. KOTAK PROTEKSI ANTI-LEAKAGE (FITUR KEAMANAN UTAMA)
                          // ===================================================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17695D)
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF17695D)
                                    .withValues(alpha: 0.22),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF17695D)
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.verified_user_rounded,
                                        size: 16,
                                        color: Color(0xFF17695D),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Verifikasi Anti-Klaim Palsu',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0D4F44),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF17695D),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Zero Leakage',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ciri spesifik barang ini sengaja dirahasiakan dari publik. Penemu / petugas akan menanyakan detail khusus secara langsung via chat pribadi:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Card Edukasi Verifikasi Chat Pribadi
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF17695D)
                                          .withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 16,
                                        color: Color(0xFF17695D),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Verifikasi via Chat Pribadi (WhatsApp)',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0D4F44),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Siapkan penjelasan ciri khusus (stiker, goresan, isi, atau tanda pengenal) saat menghubungi penemu.',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSecondary,
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Bukti Sah yang Wajib Ditunjukkan
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      size: 15,
                                      color: Color(0xFF17695D),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: AppColors.textPrimary,
                                            height: 1.35,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Bukti Wajib: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0D4F44),
                                              ),
                                            ),
                                            TextSpan(
                                              text: item['requiredProof']
                                                      as String? ??
                                                  'Tunjukkan KTM / Kartu Identitas Resmi.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ===================================================
                          // 3. INFO LOKASI POSKO & PETUGAS JAGA
                          // ===================================================
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF12312E)
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF17695D)
                                            .withValues(alpha: 0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item['storageIcon'] as IconData? ??
                                            Icons.shield_outlined,
                                        color: const Color(0xFF17695D),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['storageLabel'] as String,
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Pihak Penyimpan: ${item['holderName']}',
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                      height: 1, color: Color(0xFFEEEEEE)),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 15,
                                      color: Color(0xFF17695D),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Jam Pengambilan: ${item['operatingHours'] ?? 'Jam Kerja Kampus (08.00 - 16.00 WIB)'}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item['timeSession'] != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 15,
                                        color: Color(0xFF17695D),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Waktu Penemuan: ${item['timeSession']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (storageType != 'student') ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_search_outlined,
                                        size: 15,
                                        color: Color(0xFF17695D),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Penemu Awal: ${item['finderName'] ?? 'Mahasiswa Civitas UNESA'}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ===================================================
                          // 4. TOMBOL AKSI ADAPTIF (WHATSAPP & POSKO)
                          // ===================================================
                          // Tombol Aksi Hubungi via WhatsApp (Full Width)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final contactTarget =
                                    storageType == 'satpam'
                                        ? '${item['finderName']} (Penemu Awal)'
                                        : item['holderName'] as String;
                                final rawPhone = (item['holderPhone'] ??
                                    item['finderPhone'] ??
                                    item['finderWhatsapp'] ??
                                    '081234567890')
                                    .toString()
                                    .replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedPhone = rawPhone.startsWith('0')
                                    ? '62${rawPhone.substring(1)}'
                                    : rawPhone;

                                Navigator.pop(modalContext);
                                final waUri = Uri.parse(
                                    'https://wa.me/$formattedPhone?text=Halo%20saya%20ingin%20mengonfirmasi%20laporan%20barang%20temuan:%20${Uri.encodeComponent(item['title'] ?? '')}');
                                if (await canLaunchUrl(waUri)) {
                                  await launchUrl(waUri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    AppToast.success(
                                      context,
                                      title: 'Membuka WhatsApp',
                                      message:
                                          'Menghubungkan ke $contactTarget ($formattedPhone) untuk konfirmasi klaim.',
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.chat_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                storageType == 'satpam'
                                    ? 'Tanya Penemu Awal via WA'
                                    : 'Klaim ke Penemu via WA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.whatsapp700,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          if (storageType != 'student' ||
                              (item['mapsUrl'] != null &&
                                  (item['mapsUrl'] as String).isNotEmpty)) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(modalContext);
                                  final mapsUrl = item['mapsUrl'] as String?;
                                  if (mapsUrl != null && mapsUrl.isNotEmpty) {
                                    final uri = Uri.parse(mapsUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                      return;
                                    }
                                  }
                                  if (context.mounted) {
                                    AppToast.info(
                                      context,
                                      title: storageType == 'satpam'
                                          ? 'Lokasi Pos Satpam'
                                          : 'Lokasi Penitipan',
                                      message:
                                          '${item['storageLabel']} (${item['operatingHours']}). Bawa bukti atau kartu identitas sah.',
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.near_me_outlined,
                                  size: 16,
                                  color: Color(0xFF17695D),
                                ),
                                label: Text(
                                  storageType == 'satpam'
                                      ? 'Petunjuk Rute ke Pos Satpam'
                                      : 'Petunjuk Rute Lokasi Penitipan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF17695D),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF17695D),
                                    width: 1.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // BUILD METHOD UTAMA
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Stack(
        fit: StackFit.expand, // Memastikan Stack selalu memenuhi seluruh layar (navbar tetap fixed di bawah)
        children: [
          // Area Konten Scrollable dengan Pull-to-Refresh
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.actionPrimary,
              backgroundColor: AppColors.bgCanvas,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  setState(() {});
                  AppToast.success(
                    this.context,
                    title: 'Katalog Diperbarui',
                    message: 'Feed barang temuan kampus telah disinkronkan.',
                  );
                }
              },
              child: RepaintBoundary(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // 1. Header & Pemilih Kampus Aktif
                      _buildHeader(context),
                      const SizedBox(height: 16),

                      // 2. Search Bar Cepat
                      _buildSearchBar(),
                      const SizedBox(height: 14),

                      // 3. Banner Edukasi & Aksi Safe Handover
                      _buildSafeHandoverBanner(),
                      const SizedBox(height: 20),

                      // 4. Gliding Category Chips
                      _buildCategoryPills(),
                      const SizedBox(height: 14),

                      // 5. Storage Spot Quick Filter (Pos Satpam / Mahasiswa / Loket)
                      _buildStorageFilterBar(),
                      const SizedBox(height: 20),

                      // 6 & 7. Section Title & Stream Feed Cards
                      StreamBuilder<List<ReportItemModel>>(
                        stream: ReportService.getReportsStream(
                          isLost: false,
                          campus: _selectedCampus,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF17695D),
                                ),
                              ),
                            );
                          }

                          final rawReports = snapshot.data ?? [];
                          final filtered = _filterReports(rawReports);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeedSectionHeader(filtered.length),
                              const SizedBox(height: 14),
                              if (filtered.isEmpty)
                                _buildEmptyState()
                              else
                                ...filtered.map((item) => _buildFoundItemCard(item.toFoundItemMap())),
                            ],
                          );
                        },
                      ),

                      // Spacer bawah agar konten tidak tertutup bottom navbar
                      const SizedBox(height: 118),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Capsule Bottom Navigation Bar (Tab Ditemukan Aktif)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentNavIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  // Kembali ke Home
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 1) {
                  // Buka Pencarian / Hilang
                  Navigator.pushReplacement(
                    context,
                    SmoothPageRoute(child: const SearchScreen()),
                  );
                } else if (index == 2) {
                  // Sudah di halaman Ditemukan, scroll to top
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    SmoothPageRoute(child: const ProfileScreen()),
                  );
                }
              },
              onPostTap: () {
                final activeCampus = _currentCampusLocation.toLowerCase().contains('lidah')
                    ? 'Lidah Wetan'
                    : 'Ketintang';
                Navigator.push<Map<String, dynamic>>(
                  context,
                  SmoothPageRoute(
                    child: PostReportScreen(
                      initialType: ReportType.found,
                      initialCampus: activeCampus,
                    ),
                  ),
                ).then((newReport) {
                  if (mounted && newReport != null) {
                    setState(() {});
                    if (context.mounted) {
                      AppToast.success(
                        context,
                        title: 'Laporan Dibuat 🎉',
                        message: 'Barang temuan berhasil dicatat dalam katalog.',
                      );
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: HEADER & LOKASI KAMPUS
  // ===========================================================================
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Katalog Temuan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Barang Ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            // Notifikasi Bell Circle (49x49) dengan Tactile Bounce & Badge Dot (Presisi 1:1 dengan Home)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _isBellPressed = true),
              onTapCancel: () => setState(() => _isBellPressed = false),
              onTap: () async {
                setState(() => _isBellPressed = false);
                final remainingUnread = await showNotificationCommandPalette(
                  context,
                  initialUnreadCount: _unreadNotifCount,
                  isAlreadyOnFoundScreen: true,
                );
                if (mounted && remainingUnread != null) {
                  setState(() {
                    _unreadNotifCount = remainingUnread;
                  });
                }
              },
              child: AnimatedScale(
                scale: _isBellPressed ? 0.90 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDEE8E2).withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF12302E).withValues(
                          alpha: _isBellPressed ? 0.03 : 0.08,
                        ),
                        offset: _isBellPressed ? const Offset(0, 2) : const Offset(0, 4),
                        blurRadius: _isBellPressed ? 4 : 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF12312E),
                        size: 24,
                      ),
                      // Active notification indicator dot (Hanya muncul jika ada unread)
                      if (_unreadNotifCount > 0)
                        Positioned(
                          top: 13,
                          right: 14,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.coral500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Pemilih Lokasi Kampus Tactile Pill
        GestureDetector(
          onTapDown: (_) => setState(() => _isLocationPressed = true),
          onTapUp: (_) {
            setState(() => _isLocationPressed = false);
            _openLocationPalette();
          },
          onTapCancel: () => setState(() => _isLocationPressed = false),
          child: AnimatedScale(
            scale: _isLocationPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.actionPrimary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _currentCampusLocation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.actionPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.actionPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-WIDGET: SEARCH BAR TACTILE
  // ===========================================================================
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF12312E).withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama barang, posko simpan, atau penemu...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPlaceholder,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF17695D),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: BANNER SAFE HANDOVER
  // ===========================================================================
  Widget _buildSafeHandoverBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBFE9DA).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF17695D).withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17695D).withValues(alpha: 0.08),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF17695D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amankan Barang Temuan di Kampus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D4F44),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Titipkan ke Pos Satpam terdekat atau hubungi penemu dengan bukti kepemilikan yang sah.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF12312E).withValues(alpha: 0.75),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: CATEGORY GLIDING PILLS
  // ===========================================================================
  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          final isPressed = _pressedCategoryIndex == index;

          return Padding(
            padding: EdgeInsets.only(
              right: index == _categories.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTapDown: (_) =>
                  setState(() => _pressedCategoryIndex = index),
              onTapUp: (_) {
                setState(() {
                  _pressedCategoryIndex = null;
                  _selectedCategoryIndex = index;
                });
              },
              onTapCancel: () =>
                  setState(() => _pressedCategoryIndex = null),
              child: AnimatedScale(
                scale: isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF17695D)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF17695D)
                          : const Color(0xFF12312E).withValues(alpha: 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF17695D).withValues(alpha: 0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                    ],
                  ),
                  child: Text(
                    _categories[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: STORAGE FILTER BAR
  // ===========================================================================
  Widget _buildStorageFilterBar() {
    final filters = [
      {'key': 'semua', 'label': 'Semua Titik Simpan'},
      {'key': 'satpam', 'label': '🛡️ Di Pos Satpam'},
      {'key': 'student', 'label': '🎒 Dipegang Penemu'},
      {'key': 'official', 'label': '🏛️ Di Loket / Perpus'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStorageFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStorageFilter = f['key']!;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF17695D).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF17695D)
                        : const Color(0xFF12312E).withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0D4F44)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: FEED SECTION HEADER & SORT
  // ===========================================================================
  Widget _buildFeedSectionHeader(int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Daftar Temuan Aktif',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF17695D).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalCount Barang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF17695D),
                ),
              ),
            ),
          ],
        ),
        // Sort Toggle (Terbaru vs Terlama)
        GestureDetector(
          onTapDown: (_) => setState(() => _isSortPressed = true),
          onTapUp: (_) {
            setState(() {
              _isSortPressed = false;
              _isSortLatest = !_isSortLatest;
            });
          },
          onTapCancel: () => setState(() => _isSortPressed = false),
          child: AnimatedScale(
            scale: _isSortPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF17695D).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF17695D).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _isSortLatest ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.sort_rounded,
                      size: 15,
                      color: Color(0xFF17695D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSortLatest ? 'Terbaru' : 'Terlama',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF17695D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-WIDGET: FOUND ITEM CARD (APPLE TACTILE CARD)
  // ===========================================================================
  Widget _buildFoundItemCard(Map<String, dynamic> item) {
    final storageType = item['storageType'] as String;

    Color badgeBg;
    Color badgeText;
    if (storageType == 'satpam') {
      badgeBg = const Color(0xFF17695D).withValues(alpha: 0.10);
      badgeText = const Color(0xFF0D4F44);
    } else if (storageType == 'official') {
      badgeBg = const Color(0xFFFFE8A3).withValues(alpha: 0.35);
      badgeText = const Color(0xFF7A5400);
    } else {
      badgeBg = const Color(0xFFCFEFE3).withValues(alpha: 0.45);
      badgeText = const Color(0xFF0D4F44);
    }

    return _TactileCardWrapper(
      onTap: () => _showClaimDetailsModal(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF12312E).withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12312E).withValues(alpha: 0.03),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Foto Thumbnail + Konten Singkat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Gambar / Ikon Kategori
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: const Color(0xFFBFE9DA).withValues(alpha: 0.30),
                    child: (item['imageUrl'] != null && (item['imageUrl'] as String).isNotEmpty)
                        ? Image.network(
                            item['imageUrl'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFF17695D),
                                size: 28,
                              ),
                            ),
                          )
                        : (item['imageAsset'] != null
                            ? Image.asset(
                                item['imageAsset'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFF17695D),
                                    size: 28,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  item['icon'] as IconData? ??
                                      Icons.inventory_2_outlined,
                                  color: const Color(0xFF17695D),
                                  size: 32,
                                ),
                              )),
                  ),
                ),
                const SizedBox(width: 14),

                // Informasi Utama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Chip & Titik Simpan Badge
                      Row(
                        children: [
                          StatusChip.found(),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['storageLabel'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: badgeText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Judul Barang
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Lokasi & Waktu
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.slate600,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${item['location']} • ${item['timeAgo']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Snippet Catatan Penemu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.paper50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '📝 "${item['snippet']}"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Baris Aksi Bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item['isVerified'] == true
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 14,
                      color: item['isVerified'] == true
                          ? const Color(0xFF17695D)
                          : const Color(0xFFF2603F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['isVerified'] == true
                          ? 'Diverifikasi Pihak Kampus'
                          : 'Perlu Konfirmasi Penemu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item['isVerified'] == true
                            ? const Color(0xFF17695D)
                            : const Color(0xFFF2603F),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Detail & Klaim',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17695D),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Color(0xFF17695D),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUB-WIDGET: EMPTY STATE DENGAN EMPATI APPLE
  // ===========================================================================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF12312E).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF17695D).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: Color(0xFF17695D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Laporan Temuan Terkait',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian atau ganti filter kategori/posko pengamanan di atas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategoryIndex = 0;
                _selectedStorageFilter = 'semua';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Reset Semua Filter',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17695D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper Kartu Tactile dengan Efek Spring Kompresi Apple (WWDC Fluid Motion)
class _TactileCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TactileCardWrapper({
    required this.child,
    required this.onTap,
  });

  @override
  State<_TactileCardWrapper> createState() => _TactileCardWrapperState();
}

class _TactileCardWrapperState extends State<_TactileCardWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
