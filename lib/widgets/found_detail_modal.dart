import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import 'app_toast_stack.dart';
import 'apple_confirm_dialog.dart';
import 'status_chip.dart';

/// Modal Action Sheet Detail Barang Temuan (FindIT Campus - Orang 2 Architecture).
///
/// Mendukung 2 mode penggunaan:
/// 1. Mode Umum (`isOwner: false`): Digunakan di FoundScreen untuk pencari barang yang ingin mengajukan klaim atau verifikasi anti-leakage ke satpam/penemu.
/// 2. Mode Pribadi (`isOwner: true`): Digunakan di Riwayat Laporan (Tab Ditemukan) untuk penemu/pemilik laporan mengelola status (Tandai Selesai, Edit Lokasi Penitipan, Hapus).
Future<void> showFoundDetailModal(
  BuildContext context,
  Map<String, dynamic> item, {
  bool isOwner = false,
  Function(String newStatus)? onStatusChanged,
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return _FoundDetailSheet(
        item: item,
        isOwner: isOwner,
        onStatusChanged: onStatusChanged,
        onDelete: onDelete,
      );
    },
  );
}

class _FoundDetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isOwner;
  final Function(String newStatus)? onStatusChanged;
  final VoidCallback? onDelete;

  const _FoundDetailSheet({
    required this.item,
    required this.isOwner,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  State<_FoundDetailSheet> createState() => _FoundDetailSheetState();
}

class _FoundDetailSheetState extends State<_FoundDetailSheet> {
  int _activePhotoIndex = 0;
  bool _isClaimPressed = false;
  bool _isMapsPressed = false;
  bool _isCompletePressed = false;
  bool _isEditPressed = false;
  bool _isDeletePressed = false;

  late Map<String, dynamic> _itemData;

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
      widget.onStatusChanged?.call('Selesai');
      AppToast.success(
        context,
        title: 'Laporan Selesai 🎉',
        message: 'Barang temuan "${_itemData['title']}" telah ditandai selesai.',
      );
    }
  }

  void _editStorageLocation() {
    final locCtrl = TextEditingController(
      text: _itemData['storageLocation']?.toString() ??
          _itemData['location']?.toString() ??
          '',
    );
    final noteCtrl = TextEditingController(
      text: _itemData['claimRequirement']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (editCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(editCtx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              Text(
                'Edit Informasi Penitipan Barang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green950,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  labelText: 'Lokasi Penyimpanan Sekarang',
                  hintText: 'Contoh: Pos Satpam Utama Ketintang',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Catatan Ciri Pengambilan',
                  hintText: 'Syarat bagi pemilik saat mengambil',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _itemData['storageLocation'] = locCtrl.text.trim();
                      _itemData['claimRequirement'] = noteCtrl.text.trim();
                    });
                    Navigator.pop(editCtx);
                    AppToast.success(
                      context,
                      title: 'Data Diperbarui',
                      message: 'Lokasi penyimpanan barang temuan berhasil diupdate.',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.plusJakartaSans(
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
    );
  }

  Future<void> _deleteReport() async {
    final confirmed = await showAppleConfirmDialog(
      context: context,
      title: 'Hapus Laporan Temuan?',
      message: 'Apakah kamu yakin ingin menghapus laporan temuan "${_itemData['title']}"?\n\nLaporan yang dihapus tidak dapat dipulihkan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFDC2626),
      iconBgColor: const Color(0xFFFEE2E2),
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context);
      widget.onDelete?.call();
      AppToast.info(
        context,
        title: 'Laporan Dihapus',
        message: 'Laporan "${_itemData['title']}" berhasil dihapus dari riwayat.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageType = _itemData['storageType'] as String? ?? 'satpam';
    final rawImages = _itemData['images'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (_itemData['imageAsset'] != null) {
      images = [_itemData['imageAsset'].toString()];
    }

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
      badgeTitle = 'Masih Dipegang Penemu';
    }

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
              maxHeight: MediaQuery.of(context).size.height * 0.90,
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
                        color: const Color(0xFF12312E).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header: Status Chip & Judul
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const StatusChip.found(),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(8),
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
                              _itemData['title'] as String? ?? 'Barang Temuan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            if (widget.isOwner) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.teal600.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Laporan Temuan Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Banner Status Laporan Selesai (Jika Selesai)
                  if (_isCompleted) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.mint200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.mint300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.teal700, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barang Telah Diserahkan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.teal700,
                                  ),
                                ),
                                Text(
                                  'Laporan temuan ini sudah selesai dan barang telah diambil pemilik sah.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: AppColors.green950,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 1. Galeri Gambar (Multi-photo preview)
                  if (images.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 185,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF17695D).withValues(alpha: 0.08),
                          border: Border.all(
                            color: const Color(0xFF12312E).withValues(alpha: 0.10),
                          ),
                        ),
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (idx) => setState(() => _activePhotoIndex = idx),
                              itemBuilder: (context, idx) {
                                return Image.asset(
                                  images[idx],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFF17695D),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Watermark Tag
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 13),
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
                            // Counter Foto
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF17695D).withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17695D).withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF17695D), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Foto disembunyikan demi mencegah pemalsuan kepemilikan barang.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
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

                  // 2. Kotak Proteksi Anti-Leakage
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17695D).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
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
                                  fontSize: 13,
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
                          'Ciri spesifik barang ini sengaja dirahasiakan dari publik. Penemu / petugas akan menanyakan detail khusus saat verifikasi:',
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

                  // 3. Info Lokasi Penyimpanan & Petugas Jaga
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF12312E).withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _itemData['storageLabel'] as String? ?? 'Pos Satpam UNESA',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Pihak Penyimpan: ${_itemData['holderName'] ?? 'Satpam Kampus'}',
                                    style: GoogleFonts.plusJakartaSans(
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
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF17695D)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Jam Layanan: ${_itemData['operatingHours'] ?? 'Jam Kerja Kampus (08.00 - 16.00 WIB)'}',
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
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. BAGIAN TOMBOL AKSI: MODE PRIBADI (OWNER) VS MODE UMUM (VISITOR)
                  if (widget.isOwner) ...[
                    // TOMBOL PEMILIK: TANDAI SELESAI
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
                              borderRadius: BorderRadius.circular(16),
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
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // TOMBOL PEMILIK: EDIT LOKASI TITIP
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isEditPressed = true),
                      onTapUp: (_) {
                        setState(() => _isEditPressed = false);
                        _editStorageLocation();
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.teal600, width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_location_alt_outlined, color: AppColors.teal600, size: 19),
                              const SizedBox(width: 8),
                              Text(
                                'Update Lokasi Penitipan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TOMBOL PEMILIK: HAPUS LAPORAN
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
                            borderRadius: BorderRadius.circular(16),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rust800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // TOMBOL PENGUNJUNG UMUM: KLAIM VIA WA
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isClaimPressed = true),
                      onTapUp: (_) async {
                        setState(() => _isClaimPressed = false);
                        final rawPhone = (_itemData['holderPhone'] ??
                                _itemData['finderPhone'] ??
                                _itemData['finderWhatsapp'] ??
                                '081234567890')
                            .toString()
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        final formattedPhone = rawPhone.startsWith('0')
                            ? '62${rawPhone.substring(1)}'
                            : rawPhone;

                        Navigator.pop(context);
                        final waUri = Uri.parse(
                            'https://wa.me/$formattedPhone?text=Halo%20saya%20ingin%20mengonfirmasi%20laporan%20barang%20temuan:%20${Uri.encodeComponent(_itemData['title'] ?? '')}');
                        if (await canLaunchUrl(waUri)) {
                          await launchUrl(waUri, mode: LaunchMode.externalApplication);
                        } else if (context.mounted) {
                          AppToast.success(
                            context,
                            title: 'Membuka WhatsApp',
                            message: 'Menghubungkan ke $formattedPhone untuk konfirmasi klaim.',
                          );
                        }
                      },
                      onTapCancel: () => setState(() => _isClaimPressed = false),
                      child: AnimatedScale(
                        scale: _isClaimPressed ? 0.97 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.whatsapp700,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.whatsapp700.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_rounded, color: Colors.white, size: 19),
                              const SizedBox(width: 8),
                              Text(
                                storageType == 'satpam'
                                    ? 'Tanya Penemu Awal via WA'
                                    : 'Klaim ke Penemu via WA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (storageType != 'student' ||
                        (_itemData['mapsUrl'] != null &&
                            (_itemData['mapsUrl'] as String).isNotEmpty)) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isMapsPressed = true),
                        onTapUp: (_) async {
                          setState(() => _isMapsPressed = false);
                          Navigator.pop(context);
                          final mapsUrl = _itemData['mapsUrl'] as String?;
                          if (mapsUrl != null && mapsUrl.isNotEmpty) {
                            final uri = Uri.parse(mapsUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                              return;
                            }
                          }
                          if (context.mounted) {
                            AppToast.info(
                              context,
                              title: 'Lokasi Penitipan',
                              message: '${_itemData['storageLabel']}. Bawa kartu identitas sah.',
                            );
                          }
                        },
                        onTapCancel: () => setState(() => _isMapsPressed = false),
                        child: AnimatedScale(
                          scale: _isMapsPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF17695D), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.near_me_outlined, size: 16, color: Color(0xFF17695D)),
                                const SizedBox(width: 6),
                                Text(
                                  'Petunjuk Rute ke Pos Satpam',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF17695D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
