import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../core/campus_locations.dart';
import '../../models/report_item_model.dart';
import '../../widgets/app_toast_stack.dart';
import '../../widgets/apple_confirm_dialog.dart';
import '../../widgets/status_chip.dart';

/// Halaman Detail Laporan Barang Hilang (FindIT Campus - Apple Design & Taste Refined).
///
/// Memenuhi seluruh panduan design system & prinsip UX:
/// - Margin top seragam dan lega (22px) selaras dengan halaman lainnya.
/// - Menghilangkan jarak kosong (gap) antara kontainer Informasi Laporan dan tombol WhatsApp.
/// - Apple Photo Box: Floating Glass Status Badge, Tap-to-Zoom Fullscreen (`InteractiveViewer`).
/// - Charles UX Animation: Feedback taktil pegas (`AnimatedScale` 0.96, 100ms) pada setiap tombol.
/// - Mode Ganda:
///   1. Mode Pengunjung (Visitor / Umum): Info barang, pelapor, tips keamanan, dan aksi WhatsApp instan.
///   2. Mode Pemilik (Owner / Pribadi): Dasbor insight, tandai selesai, edit laporan, dan hapus laporan.
class DetailScreen extends StatefulWidget {
  final ReportItemModel? report;

  // Parameter langsung (opsional / fallback)
  final String? title;
  final String? category;
  final String? location;
  final String? date;
  final String? timeAgo;
  final String? description;
  final String? reporterName;
  final String? reporterRole;
  final String? reporterPhone;
  final String? imageAsset;
  final String? imageUrl;
  final bool isOwner;
  final String? status;

  const DetailScreen({
    super.key,
    this.report,
    this.title,
    this.category,
    this.location,
    this.date,
    this.timeAgo,
    this.description,
    this.reporterName,
    this.reporterRole,
    this.reporterPhone,
    this.imageAsset,
    this.imageUrl,
    this.isOwner = false,
    this.status,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ReportItemModel _item;

  // State animasi taktil (/charles-ux-animation)
  bool _isBackPressed = false;
  bool _isWaPressed = false;
  bool _isCompletePressed = false;
  bool _isReopenPressed = false;
  bool _isEditPressed = false;
  bool _isDeletePressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _item = widget.report!;
    } else {
      _item = ReportItemModel(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        title: widget.title ?? 'Dompet kulit hitam',
        category: widget.category ?? 'Dompet',
        location: widget.location ?? 'Gedung Perkuliahan, Lt. 2 • Ketintang',
        date: widget.date ?? '12 Okt 2026',
        timeAgo: widget.timeAgo ?? '2 jam lalu',
        description: widget.description ??
            'Dompet hitam berisi KTM dan SIM. Terakhir terlihat di dekat tangga lantai 2.',
        reporterName: widget.reporterName ?? 'Rizky',
        reporterRole: widget.reporterRole ?? 'Mahasiswa · SI 2024',
        reporterPhone: widget.reporterPhone ?? '081234567890',
        imageAsset: widget.imageAsset ?? 'assets/images/dompet_kulit.jpg',
        imageUrl: widget.imageUrl,
        isLost: true,
        status: widget.status ?? 'Dalam Proses',
        isOwner: widget.isOwner,
      );
    }
  }

  String _normalizePhone(String phone) {
    var number = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    } else if (number.startsWith('8')) {
      number = '62$number';
    }
    return number;
  }

  void _openImageFullscreen() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: _buildImageWidget(fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget({BoxFit fit = BoxFit.cover}) {
    if (_item.imageUrl != null && _item.imageUrl!.trim().isNotEmpty) {
      return Image.network(
        _item.imageUrl!,
        fit: fit,
        errorBuilder: (_, _, _) => _buildGracefulPhotoPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: AppColors.teal600));
        },
      );
    }
    if (_item.imageAsset != null && _item.imageAsset!.trim().isNotEmpty) {
      return Image.asset(
        _item.imageAsset!,
        fit: fit,
        errorBuilder: (_, _, _) => _buildGracefulPhotoPlaceholder(),
      );
    }
    return _buildGracefulPhotoPlaceholder();
  }

  /// Placeholder foto elegan bernuansa Apple (Anti-UI-Slop / UI-Taste).
  /// Menggantikan kotak abu-abu generik dengan layout terstruktur dan bermakna.
  Widget _buildGracefulPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF7F3EC),
            const Color(0xFFEFE9DE),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12312E).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.teal700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Foto Tidak Disertakan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Ciri barang dapat dicocokkan melalui deskripsi fisik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactViaWhatsApp() async {
    final number = _normalizePhone(_item.reporterPhone);
    if (number.length < 10) {
      AppToast.error(
        context,
        title: 'Nomor WhatsApp Tidak Valid',
        message: 'Nomor kontak pelapor belum lengkap atau salah.',
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hubungi via WhatsApp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green950,
                        ),
                      ),
                      Text(
                        'Konfirmasi penemuan barang kepada pelapor',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sage100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penerima: ${_item.reporterName} (${_item.reporterRole})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nomor WhatsApp: +$number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.teal700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(sheetContext, true),
                icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                label: Text(
                  'Buka Aplikasi WhatsApp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whatsapp700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final message = Uri.encodeComponent(
        'Halo ${_item.reporterName}, saya melihat laporan kehilangan barang "${_item.title}" di FindIT Campus. Saya menemukan barang serupa dan ingin mencocokkannya.',
      );
      final uri = Uri.parse('https://wa.me/$number?text=$message');
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          AppToast.error(
            context,
            title: 'Gagal Membuka WhatsApp',
            message: 'Aplikasi WhatsApp tidak terdeteksi di perangkat.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(
            context,
            title: 'Kesalahan Sistem',
            message: 'Terjadi masalah saat membuka tautan WhatsApp: $e',
          );
        }
      }
    }
  }

  Future<void> _markAsCompleted() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Tandai Laporan Selesai?',
      message: 'Apakah barang "${_item.title}" sudah berhasil ditemukan dan kembali kepada kamu?\n\nStatus laporan akan diubah menjadi Selesai.',
      confirmText: 'Ya, Selesai',
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.teal700,
      iconBgColor: AppColors.mint200,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _item.status = 'Selesai';
        _item.resolvedDate = 'Hari ini';
      });
      AppToast.success(
        context,
        title: 'Laporan Selesai 🎉',
        message: 'Status "${_item.title}" berhasil diubah menjadi Selesai.',
      );
    }
  }

  Future<void> _reopenReport() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Buka Kembali Laporan?',
      message: 'Apakah kamu ingin mengaktifkan kembali laporan "${_item.title}"?\n\nStatus laporan akan dikembalikan menjadi Dalam Proses agar dapat dilihat kembali oleh civitas akademika.',
      confirmText: 'Ya, Buka Kembali',
      icon: Icons.replay_rounded,
      iconColor: AppColors.teal600,
      iconBgColor: const Color(0xFFE8F5F2),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _item.status = 'Dalam Proses';
        _item.resolvedDate = null;
      });
      AppToast.success(
        context,
        title: 'Laporan Dibuka Kembali 🔄',
        message: 'Status "${_item.title}" berhasil diubah kembali menjadi Dalam Proses.',
      );
    }
  }

  /// Form Edit Laporan Hilang Komprehensif (Sesuai Form Orang 3 & Lokasi Orang 2)
  void _editReport() {
    final titleCtrl = TextEditingController(text: _item.title);
    final descCtrl = TextEditingController(text: _item.description);
    final locCtrl = TextEditingController(text: _item.location);
    final phoneCtrl = TextEditingController(text: _item.reporterPhone);

    String selectedCampus = detectCampusFromText(
      _item.location,
      fallbackCampus: 'Ketintang',
    );
    String selectedCategory = _item.category;
    String? selectedTimeSession;

    List<CampusLocation> locationSuggestions = [];
    bool showLocationSuggestions = false;

    final categories = [
      'Dompet',
      'HP',
      'Kunci',
      'KTM',
      'Tas / Ransel',
      'Elektronik',
      'Dokumen',
      'Lainnya',
    ];

    final timeSessions = [
      'Pagi (07.00 - 11.00)',
      'Siang (11.00 - 15.00)',
      'Sore (15.00 - 18.00)',
      'Malam (> 18.00)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (editCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final campusLocations = unesaCampusLocations
                .where((loc) => loc.campus == selectedCampus)
                .take(6)
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(editCtx).viewInsets.bottom,
              ),
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
                              'Edit Laporan Barang Hilang',
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Nama Barang
                            Text(
                              'Nama Barang',
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
                                hintText: 'Contoh: Dompet kulit hitam',
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

                            // 3. Pilihan Kampus
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kampus Terakhir Terlihat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setSheetState(() => selectedCampus = 'Ketintang'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: selectedCampus == 'Ketintang' ? AppColors.teal600 : const Color(0xFFF2F5F4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Ketintang',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: selectedCampus == 'Ketintang' ? Colors.white : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => setSheetState(() => selectedCampus = 'Lidah Wetan'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: selectedCampus == 'Lidah Wetan' ? AppColors.teal600 : const Color(0xFFF2F5F4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Lidah Wetan',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: selectedCampus == 'Lidah Wetan' ? Colors.white : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 4. Input Lokasi Kejadian dengan Smart Autocomplete & Rekomendasi Kata Kunci
                            Text(
                              'Lokasi Terakhir Terlihat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: locCtrl,
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
                                suffixIcon: locCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16),
                                        onPressed: () {
                                          setSheetState(() {
                                            locCtrl.clear();
                                            locationSuggestions = [];
                                            showLocationSuggestions = false;
                                          });
                                        },
                                      )
                                    : null,
                                hintText: 'Contoh: Gedung E1 FT, Kantin, atau Lab Komputer',
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
                                                locCtrl.text = loc.name;
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

                            // Rekomendasi Kata Kunci Populer Area UNESA
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 13,
                                  color: AppColors.teal700,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Rekomendasi Kata Kunci UNESA $selectedCampus:',
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
                                      locCtrl.text = loc.name;
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.place_outlined, size: 12, color: AppColors.teal700),
                                        const SizedBox(width: 4),
                                        Text(
                                          loc.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // 5. Perkiraan Sesi Waktu Kejadian
                            Text(
                              'Perkiraan Waktu Kejadian',
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
                                  onTap: () {
                                    setSheetState(() {
                                      selectedTimeSession = isSelected ? null : session;
                                    });
                                  },
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

                            // 6. Nomor Kontak WhatsApp Pelapor
                            Text(
                              'Nomor WhatsApp Pelapor',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.teal600),
                                hintText: '081234567890',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 7. Deskripsi Detail
                            Text(
                              'Deskripsi Detail & Ciri Khusus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: descCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Warna, merk, isi dokumen, identitas khusus...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.all(14),
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
                                    _item = _item.copyWith(
                                      title: titleCtrl.text.trim(),
                                      category: selectedCategory,
                                      location: locCtrl.text.trim(),
                                      description: descCtrl.text.trim(),
                                      reporterPhone: phoneCtrl.text.trim(),
                                    );
                                  });
                                  Navigator.pop(editCtx);
                                  AppToast.success(
                                    context,
                                    title: 'Laporan Diperbarui',
                                    message: 'Perubahan pada laporan kehilangan berhasil disimpan.',
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
      title: 'Hapus Laporan?',
      message: 'Apakah kamu yakin ingin menghapus laporan "${_item.title}"?\n\nLaporan ini tidak dapat dikembalikan setelah dihapus.',
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
        message: 'Laporan "${_item.title}" berhasil dihapus.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _item.isCompleted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _item);
      },
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: GestureDetector(
            onTapDown: (_) => setState(() => _isBackPressed = true),
            onTapUp: (_) {
              setState(() => _isBackPressed = false);
              Navigator.pop(context, _item);
            },
            onTapCancel: () => setState(() => _isBackPressed = false),
            child: AnimatedScale(
              scale: _isBackPressed ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.green950),
            ),
          ),
          title: Text(
            'Detail Laporan',
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
            // 1. FOTO UTAMA DENGAN FLOATING GLASS STATUS BADGE & TAP TO ZOOM
            GestureDetector(
              onTap: _openImageFullscreen,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppDimens.cardShadow,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.sage100),
                        ),
                        child: _buildImageWidget(),
                      ),
                    ),
                    // Glass Floating Status Badge di Kiri Atas
                    Positioned(
                      left: 14,
                      top: 14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.mint200.withValues(alpha: 0.92)
                                  : AppColors.peach100.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCompleted ? AppColors.mint300 : AppColors.peach200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                                  size: 13,
                                  color: isCompleted ? AppColors.teal700 : AppColors.rust800,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _item.status,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted ? AppColors.teal700 : AppColors.rust800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Icon Zoom Taktil di Kanan Bawah
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. JUDUL BARANG & CHIPS FIGMA RESMI
            if (_item.isOwner) ...[
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
                      Icons.verified_user_rounded,
                      size: 13,
                      color: AppColors.teal700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Laporan Anda Sendiri',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Text(
              _item.title,
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
                // Chip Status Hilang (Resmi Figma Fondasi)
                const StatusChip.lost(),

                // Chip Kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.sand100,
                    borderRadius: BorderRadius.circular(AppDimens.radius99),
                  ),
                  child: Text(
                    _item.category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
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
                  _item.timeAgo,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textPlaceholder),
                const SizedBox(width: 6),
                Text(
                  _item.date,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. BANNER LAPORAN SELESAI
            if (isCompleted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mint200,
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                  border: Border.all(color: AppColors.mint300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.teal700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Laporan Selesai',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Barang telah berhasil ditemukan dan kembali kepada pemiliknya.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.green950,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 4. KARTU INFORMASI BARANG (LOKASI & DESKRIPSI)
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Barang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Lokasi Terakhir Terlihat',
                    value: _item.location,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'Deskripsi Detail & Ciri Khusus',
                    value: _item.description,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. KARTU PROFIL PELAPOR
            _buildCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.peach200,
                    child: Text(
                      _item.reporterName.isNotEmpty ? _item.reporterName[0].toUpperCase() : 'U',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.rust900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dilaporkan oleh',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _item.reporterName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.teal600,
                            ),
                          ],
                        ),
                        Text(
                          _item.reporterRole,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. KARTU PANDUAN KEAMANAN SATPAM UNESA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(AppDimens.radius20),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFC2410C), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panduan Keamanan UNESA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9A3412),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lakukan serah terima barang di area ber-CCTV seperti Pos Satpam atau Lobby Gedung. Jangan pernah mentransfer uang tebusan secara daring.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.45,
                            color: const Color(0xFF7C2D12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. KARTU INFORMASI / INSIGHT LAPORAN
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Laporan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildInsightMetric('Dilihat', '${_item.viewsCount}x', Icons.visibility_outlined),
                      _buildInsightMetric('Respons', '${_item.responsesCount} masuk', Icons.chat_bubble_outline_rounded),
                      _buildInsightMetric('Aktif', _item.activeDays, Icons.date_range_outlined),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================================
            // 8. TOMBOL AKSI: INLINE LANGSUNG TANPA JARAK KOSONG (POINT 3)
            // =================================================================
            const SizedBox(height: 18), // Jarak teratur standar dari kartu Informasi Laporan

            // JIKA MODE PENGUNJUNG: TOMBOL WHATSAPP LANGSUNG MENEMPEL RAPI DI BAWAH KARTU
            if (!_item.isOwner) ...[
              GestureDetector(
                onTapDown: (_) => setState(() => _isWaPressed = true),
                onTapUp: (_) {
                  setState(() => _isWaPressed = false);
                  _contactViaWhatsApp();
                },
                onTapCancel: () => setState(() => _isWaPressed = false),
                child: AnimatedScale(
                  scale: _isWaPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.whatsapp700,
                      borderRadius: BorderRadius.circular(AppDimens.radius18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.whatsapp700.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Hubungi via WhatsApp',
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
            ],

            // JIKA MODE PEMILIK: AKSI KELOLA LAPORAN (SELESAI / BUKA KEMBALI, EDIT, HAPUS)
            if (_item.isOwner) ...[
              if (!isCompleted) ...[
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
                            'Tandai Selesai',
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
                // TOMBOL: BUKA KEMBALI LAPORAN (JIKA SEBELUMNYA SELESAI / TIDAK SENGAJA KEPENCET)
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
                            'Buka Kembali Laporan',
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

              GestureDetector(
                onTapDown: (_) => setState(() => _isEditPressed = true),
                onTapUp: (_) {
                  setState(() => _isEditPressed = false);
                  _editReport();
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
                          'Hapus Laporan',
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
    ),
  );
}

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: AppColors.sage100),
        boxShadow: AppDimens.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.teal600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.teal600, size: 19),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
