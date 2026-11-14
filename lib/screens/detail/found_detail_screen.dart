import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../core/campus_locations.dart';
import '../../widgets/app_toast_stack.dart';
import '../../widgets/apple_confirm_dialog.dart';
import '../../widgets/status_chip.dart';

/// Halaman Detail Laporan Barang Temuan Pribadi (FindIT Campus - Full Page & Apple Design).
///
/// Fitur Utama:
/// 1. Tampilan Halaman Penuh (Bukan Modal Sheet) dengan AppBar konsisten, tanpa tombol bagi.
/// 2. Margin top lega (22px) selaras dengan seluruh halaman FindIT Campus.
/// 3. Galeri Multi-Foto Apple dengan indikator counter foto dan watermark anti-leakage.
/// 4. Kartu Proteksi Anti-Leakage dan Informasi Posko Penitipan Fisik.
/// 5. Tombol Aksi Pemilik (Owner Mode):
///    - Tandai Telah Diambil (Selesai)
///    - Edit Laporan (Membuka Form Komprehensif terintegrasi Hotspot Lokasi UNESA Orang 2 & Orang 3)
///    - Hapus Laporan Temuan
/// 6. Charles UX Animation: Feedback taktil pegas (AnimatedScale 0.96, 100ms) pada seluruh tombol.
class FoundDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isOwner;

  const FoundDetailScreen({
    super.key,
    required this.item,
    this.isOwner = true,
  });

  @override
  State<FoundDetailScreen> createState() => _FoundDetailScreenState();
}

class _FoundDetailScreenState extends State<FoundDetailScreen> {
  late Map<String, dynamic> _itemData;
  int _activePhotoIndex = 0;

  // State animasi taktil (/charles-ux-animation)
  bool _isBackPressed = false;
  bool _isCompletePressed = false;
  bool _isReopenPressed = false;
  bool _isEditPressed = false;
  bool _isDeletePressed = false;

  @override
  void initState() {
    super.initState();
    _itemData = Map<String, dynamic>.from(widget.item);
  }

  bool get _isCompleted =>
      _itemData['statusLabel'] == 'Selesai' ||
      _itemData['isCompleted'] == true ||
      _itemData['status']?.toString().toLowerCase() == 'selesai';

  Future<void> _markAsCompleted() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Tandai Telah Dikembalikan?',
      message: 'Apakah barang temuan "${_itemData['title']}" sudah berhasil diserahkan kepada pemilik yang sah?\n\nStatus laporan temuan kamu akan diubah menjadi Selesai.',
      confirmText: 'Ya, Selesai',
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.teal700,
      iconBgColor: AppColors.mint200,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _itemData['statusLabel'] = 'Selesai';
        _itemData['isCompleted'] = true;
        _itemData['resolvedDate'] = 'Hari ini';
      });
      AppToast.success(
        context,
        title: 'Laporan Selesai 🎉',
        message: 'Barang temuan "${_itemData['title']}" telah ditandai selesai.',
      );
    }
  }

  Future<void> _reopenReport() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Buka Kembali Laporan?',
      message: 'Apakah kamu ingin mengaktifkan kembali laporan temuan "${_itemData['title']}"?\n\nStatus laporan temuan kamu akan dikembalikan menjadi Dalam Proses agar dapat dilihat kembali oleh civitas akademika.',
      confirmText: 'Ya, Buka Kembali',
      icon: Icons.replay_rounded,
      iconColor: AppColors.teal600,
      iconBgColor: const Color(0xFFE8F5F2),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _itemData['statusLabel'] = 'Dalam Proses';
        _itemData['isCompleted'] = false;
        _itemData['resolvedDate'] = null;
      });
      AppToast.success(
        context,
        title: 'Laporan Dibuka Kembali 🔄',
        message: 'Barang temuan "${_itemData['title']}" berhasil diubah kembali menjadi Dalam Proses.',
      );
    }
  }

  /// Form Edit Laporan Temuan Komprehensif (Sesuai Form Orang 3 & Lokasi Orang 2)
  void _openEditReportSheet() {
    final titleCtrl = TextEditingController(text: _itemData['title']?.toString() ?? '');
    final locationCtrl = TextEditingController(
      text: _itemData['storageLabel']?.toString() ?? _itemData['location']?.toString() ?? '',
    );
    final proofCtrl = TextEditingController(
      text: _itemData['requiredProof']?.toString() ?? '',
    );
    final claimCtrl = TextEditingController(
      text: _itemData['claimRequirement']?.toString() ?? '',
    );

    String selectedCampus = detectCampusFromText(
      locationCtrl.text,
      fallbackCampus: _itemData['campus']?.toString() ?? 'Ketintang',
    );
    String selectedCategory = _itemData['category']?.toString() ?? 'Kunci';
    String selectedStorageType = _itemData['storageType']?.toString() ?? 'satpam';
    String selectedTimeSession = _itemData['timeSession']?.toString() ?? 'Pagi (07.00 - 11.00)';

    List<CampusLocation> locationSuggestions = [];
    bool showLocationSuggestions = false;

    final List<String> categories = ['Dompet', 'HP', 'Kunci', 'KTM', 'Aksesoris', 'Lainnya'];
    final List<String> timeSessions = [
      'Pagi (07.00 - 11.00)',
      'Siang (11.00 - 15.00)',
      'Sore (15.00 - 18.00)',
      'Malam (18.00+)',
    ];

    final List<String> satpamKetintangPresets = [
      'Pos Satpam FT Ketintang',
      'Pos Satpam Gerbang Utama',
      'Pos Satpam Rektorat Lama Ketintang',
      'Pos Satpam FEB / FISIPOL',
    ];

    final List<String> satpamLidahPresets = [
      'Pos Satpam Gerbang Lidah Wetan',
      'Pos Satpam Rektorat Baru Lidah Wetan',
      'Pos Satpam Danau UNESA',
      'Pos Satpam FBS / FIP Lidah Wetan',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (editCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeSatpamPresets = selectedCampus == 'Ketintang'
                ? satpamKetintangPresets
                : satpamLidahPresets;

            final campusLocations = unesaCampusLocations
                .where((loc) => loc.campus == selectedCampus)
                .take(4)
                .toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(editCtx).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Edit Laporan Barang Temuan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green950,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(editCtx),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.slate700,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),

                    // Form Fields Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Nama Barang Temuan
                            Text(
                              'Nama Barang Temuan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: titleCtrl,
                              decoration: InputDecoration(
                                hintText: 'Contoh: Kunci Motor Honda Vario',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Kategori Barang
                            Text(
                              'Kategori Barang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categories.map((cat) {
                                final isSelected = selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () => setSheetState(() => selectedCategory = cat),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.teal600 : const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? AppColors.teal600 : AppColors.sage100,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 3. Pilihan Kampus (Ketintang / Lidah Wetan)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kampus Penemuan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildCampusToggleChip('Ketintang', selectedCampus == 'Ketintang', () {
                                      setSheetState(() => selectedCampus = 'Ketintang');
                                    }),
                                    const SizedBox(width: 8),
                                    _buildCampusToggleChip('Lidah Wetan', selectedCampus == 'Lidah Wetan', () {
                                      setSheetState(() => selectedCampus = 'Lidah Wetan');
                                    }),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 4. Status Penitipan Barang
                            Text(
                              'Status & Tempat Penitipan Barang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStorageTypeOption(
                                    label: 'Di Pos Satpam',
                                    icon: Icons.shield_outlined,
                                    isSelected: selectedStorageType == 'satpam',
                                    onTap: () => setSheetState(() => selectedStorageType = 'satpam'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStorageTypeOption(
                                    label: 'Pegang Sendiri',
                                    icon: Icons.person_outline_rounded,
                                    isSelected: selectedStorageType == 'student',
                                    onTap: () => setSheetState(() => selectedStorageType = 'student'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStorageTypeOption(
                                    label: 'Loket Kampus',
                                    icon: Icons.storefront_outlined,
                                    isSelected: selectedStorageType == 'official',
                                    onTap: () => setSheetState(() => selectedStorageType = 'official'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 5. Input Lokasi & Rekomendasi Pintar Satpam / Hotspot UNESA
                            Text(
                              'Lokasi Penyimpanan Sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: locationCtrl,
                              onChanged: (val) {
                                if (val.trim().isEmpty) {
                                  setSheetState(() {
                                    locationSuggestions = [];
                                    showLocationSuggestions = false;
                                  });
                                } else {
                                  final matches = searchCampusLocations(val);
                                  final detected = detectCampusFromText(val, fallbackCampus: selectedCampus);
                                  setSheetState(() {
                                    locationSuggestions = matches;
                                    showLocationSuggestions = matches.isNotEmpty;
                                    selectedCampus = detected;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.teal600),
                                suffixIcon: locationCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16),
                                        onPressed: () {
                                          setSheetState(() {
                                            locationCtrl.clear();
                                            locationSuggestions = [];
                                            showLocationSuggestions = false;
                                          });
                                        },
                                      )
                                    : null,
                                hintText: selectedStorageType == 'satpam'
                                    ? 'Ketik nama pos satpam atau cari kata kunci...'
                                    : 'Ketik nama gedung/tempat, atau cari kata kunci...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),

                            // Dropdown Card Rekomendasi Pintar (Smart Autocomplete sesuai Form Laporan)
                            if (showLocationSuggestions && locationSuggestions.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.teal600.withValues(alpha: 0.3),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF17695D).withValues(alpha: 0.10),
                                      offset: const Offset(0, 6),
                                      blurRadius: 16,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 14,
                                              color: AppColors.teal600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Rekomendasi Pintar Area Kampus UNESA',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.teal600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1, color: Color(0xFFEEF2F0)),
                                      ...locationSuggestions.take(4).map((loc) {
                                        final isKet = loc.campus == 'Ketintang';
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              setSheetState(() {
                                                locationCtrl.text = loc.name;
                                                selectedCampus = loc.campus;
                                                showLocationSuggestions = false;
                                                locationSuggestions = [];
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: isKet
                                                          ? const Color(0xFFE8F5F2)
                                                          : const Color(0xFFFFF1EB),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.place_rounded,
                                                      size: 14,
                                                      color: isKet ? AppColors.teal600 : AppColors.coral500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          loc.name,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12.5,
                                                            fontWeight: FontWeight.w700,
                                                            color: AppColors.green950,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 1.5),
                                                        Text(
                                                          '${loc.area} • UNESA ${loc.campus}',
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 11,
                                                            color: AppColors.slate600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: isKet
                                                          ? const Color(0xFFE8F5F2)
                                                          : const Color(0xFFFFF1EB),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      loc.campus,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: isKet ? AppColors.teal600 : AppColors.coral500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 10),

                            // Chip Cepat Rekomendasi Pos Satpam UNESA (Orang 3 Form Feature)
                            if (selectedStorageType == 'satpam') ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 13,
                                    color: AppColors.teal700,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Pilih Pos Satpam Cepat UNESA $selectedCampus:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: activeSatpamPresets.map((preset) {
                                  return GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        locationCtrl.text = preset;
                                        showLocationSuggestions = false;
                                        locationSuggestions = [];
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.mint300),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.security_rounded, size: 12, color: AppColors.teal700),
                                          const SizedBox(width: 4),
                                          Text(
                                            preset,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.teal700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                            ] else ...[
                              // Rekomendasi Kata Kunci Hotspot Kampus UNESA Orang 2
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 13,
                                    color: AppColors.teal700,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Rekomendasi Kata Kunci Area $selectedCampus:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: campusLocations.map((loc) {
                                  return GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        locationCtrl.text = loc.name;
                                        selectedCampus = loc.campus;
                                        showLocationSuggestions = false;
                                        locationSuggestions = [];
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F7F5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.sage100),
                                      ),
                                      child: Text(
                                        loc.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // 6. Sesi Waktu Penemuan
                            Text(
                              'Waktu Penemuan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: timeSessions.map((session) {
                                final isSelected = selectedTimeSession == session;
                                return GestureDetector(
                                  onTap: () => setSheetState(() => selectedTimeSession = session),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFE8F5F2) : const Color(0xFFF7FAF8),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? AppColors.teal600 : AppColors.sage100,
                                      ),
                                    ),
                                    child: Text(
                                      session,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? AppColors.teal700 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // 7. Bukti Sah & Catatan Ciri Pengambilan
                            Text(
                              'Bukti Wajib & Catatan Ciri Pengambilan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: proofCtrl,
                              decoration: InputDecoration(
                                labelText: 'Bukti Sah yang Wajib Ditunjukkan',
                                hintText: 'Contoh: Wajib menunjukkan STNK motor asli',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: claimCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Pertanyaan Verifikasi / Ciri Khusus',
                                hintText: 'Contoh: Sebutkan warna gantungan boneka kecil pada anak kunci',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Tombol Simpan Perubahan
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _itemData['title'] = titleCtrl.text.trim();
                                    _itemData['category'] = selectedCategory;
                                    _itemData['campus'] = selectedCampus;
                                    _itemData['storageType'] = selectedStorageType;
                                    _itemData['storageLabel'] = locationCtrl.text.trim();
                                    _itemData['timeSession'] = selectedTimeSession;
                                    _itemData['requiredProof'] = proofCtrl.text.trim();
                                    _itemData['claimRequirement'] = claimCtrl.text.trim();
                                  });
                                  Navigator.pop(editCtx);
                                  AppToast.success(
                                    context,
                                    title: 'Laporan Diperbarui',
                                    message: 'Perubahan pada laporan temuan berhasil disimpan.',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal600,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Simpan Perubahan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteReport() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Hapus Laporan Temuan?',
      message: 'Apakah kamu yakin ingin menghapus laporan temuan "${_itemData['title']}"?\n\nLaporan ini tidak dapat dikembalikan setelah dihapus.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFDC2626),
      iconBgColor: const Color(0xFFFEE2E2),
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context, 'deleted');
      AppToast.info(
        context,
        title: 'Laporan Dihapus',
        message: 'Laporan temuan "${_itemData['title']}" telah dihapus.',
      );
    }
  }

  Widget _buildCampusToggleChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal600 : const Color(0xFFF2F5F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageTypeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal600 : AppColors.sage100,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.teal700 : AppColors.slate600),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.teal700 : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawImages = _itemData['images'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (_itemData['imageAsset'] != null) {
      images = [_itemData['imageAsset'].toString()];
    }

    final storageType = _itemData['storageType'] as String? ?? 'satpam';
    String storageBadgeTitle = 'Diamankan di Pos Satpam';
    if (storageType == 'official') {
      storageBadgeTitle = 'Dititipkan di Loket Resmi';
    } else if (storageType == 'student') {
      storageBadgeTitle = 'Dipegang Penemu';
    }

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: GestureDetector(
          onTapDown: (_) => setState(() => _isBackPressed = true),
          onTapUp: (_) {
            setState(() => _isBackPressed = false);
            Navigator.pop(context);
          },
          onTapCancel: () => setState(() => _isBackPressed = false),
          child: AnimatedScale(
            scale: _isBackPressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.green950),
          ),
        ),
        // Title terpusat tanpa tombol share (Sesuai Poin 1)
        title: Text(
          'Detail Laporan Temuan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.green950,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // MARGIN TOP KONSISTEN & LEGA (AppDimens.screenInset = 22px)
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenInset,
          AppDimens.screenInset,
          AppDimens.screenInset,
          36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GALERI MULTI-FOTO APPLE DENGAN WATERMARK & COUNTER
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppDimens.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.sage100),
                  ),
                  child: images.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (idx) => setState(() => _activePhotoIndex = idx),
                              itemBuilder: (context, idx) {
                                return Image.asset(
                                  images[idx],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, _, _) => _buildFallbackPhoto(),
                                );
                              },
                            ),
                            // Watermark Tag Anti-Leakage
                            Positioned(
                              top: 14,
                              left: 14,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 13),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Ciri Rahasia Disamarkan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Counter Pill
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '📷 ${_activePhotoIndex + 1} / ${images.length} Foto',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildFallbackPhoto(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. JUDUL BARANG & BADGE PENYIMPANAN
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal600.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 13,
                    color: AppColors.teal700,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Laporan Temuan Anda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal700,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              _itemData['title'] as String? ?? 'Barang Temuan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const StatusChip.found(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F2),
                    borderRadius: BorderRadius.circular(AppDimens.radius99),
                  ),
                  child: Text(
                    storageBadgeTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sand100,
                    borderRadius: BorderRadius.circular(AppDimens.radius99),
                  ),
                  child: Text(
                    _itemData['category'] as String? ?? 'Temuan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green950,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textPlaceholder),
                const SizedBox(width: 6),
                Text(
                  _itemData['timeAgo'] as String? ?? '1 hari lalu',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textPlaceholder),
                const SizedBox(width: 6),
                Text(
                  _itemData['date'] as String? ?? '',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. BANNER STATUS SELESAI
            if (_isCompleted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mint200,
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                  border: Border.all(color: AppColors.mint300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.teal700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barang Telah Diserahkan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Laporan temuan ini telah selesai dan barang telah berhasil kembali kepada pemilik yang sah.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.green950,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 4. KOTAK PROTEKSI ANTI-LEAKAGE (VERIFIKASI KLAIM PALSU)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF17695D).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppDimens.radius20),
                border: Border.all(
                  color: const Color(0xFF17695D).withValues(alpha: 0.22),
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
                          color: const Color(0xFF17695D).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF17695D)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verifikasi Anti-Klaim Palsu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0D4F44),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17695D),
                          borderRadius: BorderRadius.circular(6),
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
                    'Ciri spesifik barang ini sengaja dirahasiakan dari publik. Pemilik wajib membuktikan kepemilikan sah:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, size: 15, color: Color(0xFF17695D)),
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
                                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D4F44)),
                              ),
                              TextSpan(
                                text: _itemData['requiredProof'] as String? ??
                                    'Tunjukkan bukti kepemilikan sah / login Siakadu.',
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
            const SizedBox(height: 16),

            // 5. INFO LOKASI PENYIMPANAN FISIK & PETUGAS JAGA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radius20),
                border: Border.all(color: AppColors.sage100),
                boxShadow: AppDimens.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF17695D).withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _itemData['storageIcon'] as IconData? ?? Icons.shield_outlined,
                          color: const Color(0xFF17695D),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _itemData['storageLabel'] as String? ?? 'Pos Satpam UNESA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Pihak Penyimpan: ${_itemData['holderName'] ?? 'Satpam Jaga Kampus'}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
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
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF17695D)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Jadwal Layanan: ${_itemData['operatingHours'] ?? '24 Jam / Jam Kerja Kampus'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_itemData['timeSession'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF17695D)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Waktu Penemuan: ${_itemData['timeSession']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. TOMBOL AKSI PEMILIK (OWNER MODE)
            if (widget.isOwner) ...[
              // TOMBOL 1: TANDAI TELAH DIAMBIL / BUKA KEMBALI
              if (!_isCompleted) ...[
                GestureDetector(
                  onTapDown: (_) => setState(() => _isCompletePressed = true),
                  onTapUp: (_) {
                    setState(() => _isCompletePressed = false);
                    _markAsCompleted();
                  },
                  onTapCancel: () => setState(() => _isCompletePressed = false),
                  child: AnimatedScale(
                    scale: _isCompletePressed ? 0.97 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.teal600,
                        borderRadius: BorderRadius.circular(AppDimens.radius18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal600.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tandai Telah Diambil (Selesai)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                // TOMBOL: BUKA KEMBALI LAPORAN TEMUAN (JIKA SEBELUMNYA SELESAI / TIDAK SENGAJA KEPENCET)
                GestureDetector(
                  onTapDown: (_) => setState(() => _isReopenPressed = true),
                  onTapUp: (_) {
                    setState(() => _isReopenPressed = false);
                    _reopenReport();
                  },
                  onTapCancel: () => setState(() => _isReopenPressed = false),
                  child: AnimatedScale(
                    scale: _isReopenPressed ? 0.97 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radius18),
                        border: Border.all(color: AppColors.teal600, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal600.withValues(alpha: 0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.replay_rounded, color: AppColors.teal600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Buka Kembali Laporan Temuan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.teal600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // TOMBOL 2: EDIT LAPORAN (Label: Edit Laporan, Sesuai Poin 5)
              GestureDetector(
                onTapDown: (_) => setState(() => _isEditPressed = true),
                onTapUp: (_) {
                  setState(() => _isEditPressed = false);
                  _openEditReportSheet();
                },
                onTapCancel: () => setState(() => _isEditPressed = false),
                child: AnimatedScale(
                  scale: _isEditPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radius16),
                      border: Border.all(color: AppColors.teal600, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_outlined, color: AppColors.teal600, size: 19),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Laporan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL 3: HAPUS LAPORAN TEMUAN
              GestureDetector(
                onTapDown: (_) => setState(() => _isDeletePressed = true),
                onTapUp: (_) {
                  setState(() => _isDeletePressed = false);
                  _deleteReport();
                },
                onTapCancel: () => setState(() => _isDeletePressed = false),
                child: AnimatedScale(
                  scale: _isDeletePressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radius16),
                      border: Border.all(color: AppColors.rust800.withValues(alpha: 0.6), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded, color: AppColors.rust800, size: 19),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus Laporan Temuan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.rust800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhoto() {
    return Container(
      color: const Color(0xFFF0F4F2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.teal600.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              'Foto Tidak Disertakan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
