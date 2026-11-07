import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../widgets/status_chip.dart';

/// Halaman Detail Laporan (Figma Node 181:2508 & 181:2679 / Apple Design Refined).
/// Mendukung 2 mode tampilan:
/// 1. Public Visitor Mode (`isOwner: false`): Menampilkan detail barang, trust badge pelapor, tips serah terima, dan tombol Hubungi via WhatsApp.
/// 2. Owner Management Mode (`isOwner: true`): Menampilkan dasbor kelola laporan milik sendiri (insights statistik, tombol Tandai Selesai / Ditemukan, Edit, & Hapus).
///
/// Fitur UX & Polish (/apple-design):
/// - Fixed Sticky Glassy Navigation Bar: Tombol Back, Share, & Bookmark tetap melayang di atas dan konten blur di bawahnya saat di-scroll.
/// - Scrollbar bebas thumb/track tersembunyi halus.
/// - Hero Photo Box interaktif: Floating Glass Status Badge, Tap-to-Zoom Fullscreen.
/// - Owner Analytics Bar: 48x Dilihat, 1 Respon Masuk, Masa Aktif.
/// - Modal Sheet Konfirmasi: Frosted Glass dengan dual button responsif.
class DetailScreen extends StatefulWidget {
  final String title;
  final ReportStatus status;
  final String timeAgo;
  final String location;
  final String date;
  final String category;
  final String description;
  final String reporterName;
  final String reporterRole;
  final String? imageAsset;
  final IconData? icon;
  final String? whatsappNumber;
  final bool isOwner;

  const DetailScreen({
    super.key,
    this.title = 'Dompet kulit hitam',
    this.status = ReportStatus.lost,
    this.timeAgo = 'Diposting 2 jam lalu',
    this.location = 'Gedung Perkuliahan, Lt. 2',
    this.date = '12 Okt 2026',
    this.category = 'Dompet',
    this.description =
        'Dompet hitam berisi KTM dan SIM. Terakhir terlihat di dekat tangga lantai 2.',
    this.reporterName = 'Rizky',
    this.reporterRole = 'Mahasiswa · SI 2024',
    this.imageAsset = 'assets/images/dompet_kulit.jpg',
    this.icon,
    this.whatsappNumber = '6281234567890',
    this.isOwner = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBackPressed = false;
  bool _isBookmarkPressed = false;
  bool _isBookmarked = false;
  bool _isWaPressed = false;

  // State untuk Pemilik Laporan (Owner Mode)
  bool _isEditPressed = false;
  bool _isDeletePressed = false;
  bool _isMarkResolvedPressed = false;
  bool _isResolved = false;

  late String _title;
  late String _location;
  late String _description;
  late ReportStatus _status;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _location = widget.location;
    _description = widget.description;
    _status = widget.status;
  }

  void _showWhatsAppConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WhatsAppConfirmSheet(
          itemTitle: _title,
          reporterName: widget.reporterName,
          reporterRole: widget.reporterRole,
          whatsappNumber: widget.whatsappNumber ?? '6281234567890',
          imageAsset: widget.imageAsset,
          icon: widget.icon,
        );
      },
    );
  }

  void _showFullscreenImage() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.imageAsset != null
                      ? Image.asset(widget.imageAsset!, fit: BoxFit.contain)
                      : Container(
                          width: 250,
                          height: 250,
                          color: Colors.white.withValues(alpha: 0.1),
                          child: Icon(
                            widget.icon ?? Icons.inventory_2_outlined,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkResolvedSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OwnerActionConfirmSheet(
          icon: _isResolved
              ? Icons.replay_rounded
              : Icons.check_circle_rounded,
          iconColor: _isResolved
              ? const Color(0xFF17695D)
              : const Color(0xFF17695D),
          title: _isResolved
              ? 'Buka Kembali Laporan?'
              : 'Tandai Barang Ditemukan?',
          description: _isResolved
              ? 'Laporan ini akan kembali diaktifkan di daftar pencarian aktif kampus.'
              : 'Apakah barang ini sudah berhasil ditemukan atau kembali? Laporan ini akan ditandai selesai dan diarsipkan dari feed publik kampus.',
          confirmText: _isResolved ? 'Ya, Aktifkan' : 'Ya, Sudah Ditemukan',
          onConfirm: () {
            setState(() {
              _isResolved = !_isResolved;
              _status =
                  _isResolved ? ReportStatus.found : ReportStatus.lost;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isResolved
                      ? 'Laporan ditandai selesai dan berhasil ditemukan.'
                      : 'Laporan berhasil diaktifkan kembali.',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OwnerActionConfirmSheet(
          icon: Icons.delete_forever_rounded,
          iconColor: const Color(0xFFE0533C),
          title: 'Hapus Laporan Ini?',
          description:
              'Laporan "$_title" akan dihapus secara permanen dari FindIT Campus dan tidak dapat dipulihkan.',
          confirmText: 'Hapus Sekarang',
          isDanger: true,
          onConfirm: () {
            Navigator.pop(context); // Tutup sheet
            Navigator.pop(context); // Kembali ke Beranda
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan telah berhasil dihapus.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditReportSheet() {
    final titleCtrl = TextEditingController(text: _title);
    final locationCtrl = TextEditingController(text: _location);
    final descCtrl = TextEditingController(text: _description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OwnerEditSheet(
          titleCtrl: titleCtrl,
          locationCtrl: locationCtrl,
          descCtrl: descCtrl,
          onSave: (newTitle, newLocation, newDesc) {
            setState(() {
              _title = newTitle;
              _location = newLocation;
              _description = newDesc;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Informasi laporan berhasil diperbarui.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Konten Scrollable (Tanpa scrollbar indicator)
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 68,
                  22,
                  widget.isOwner ? 150 : 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoBox(),
                    const SizedBox(height: 18),
                    _buildTitleSection(),
                    const SizedBox(height: 18),

                    // Fitur khusus Pemilik Laporan: Dasbor Statistik & Pelacakan
                    if (widget.isOwner) ...[
                      _buildOwnerInsightsCard(),
                      const SizedBox(height: 18),
                    ],

                    _buildInfoCard(),
                    const SizedBox(height: 18),
                    _buildDescriptionSection(),
                    const SizedBox(height: 18),
                    _buildReporterCard(),
                    const SizedBox(height: 18),
                    _buildSafetyTipCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 2. Fixed Sticky Frosted Glass Top Bar (Apple Navigation Bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFixedTopBar(context),
          ),

          // 3. Sticky Bottom Bar: WhatsApp for Stranger, Owner Management Actions for Owner!
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.isOwner ? _buildOwnerBottomBar() : _buildBottomCta(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. FIXED TOP BAR (Sticky Glassy Navigation Bar)
  // ===========================================================================
  Widget _buildFixedTopBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 10,
            left: 22,
            right: 22,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F3).withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFDEE8E2).withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Kembali
              _buildCircleButton(
                icon: Icons.chevron_left_rounded,
                isPressed: _isBackPressed,
                onTapDown: () => setState(() => _isBackPressed = true),
                onTapUp: () {
                  setState(() => _isBackPressed = false);
                  Navigator.pop(context);
                },
                onTapCancel: () => setState(() => _isBackPressed = false),
              ),

              // Owner Indicator Pill di Navigation Bar
              if (widget.isOwner)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17695D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFF17695D).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 13,
                        color: Color(0xFF17695D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kelola Laporan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF17695D),
                        ),
                      ),
                    ],
                  ),
                ),

              // Aksi Kanan: Simpan (Bookmark)
              _buildCircleButton(
                icon: _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                iconColor: _isBookmarked
                    ? AppColors.coral500
                    : const Color(0xFF12312E),
                isPressed: _isBookmarkPressed,
                onTapDown: () => setState(() => _isBookmarkPressed = true),
                onTapUp: () {
                  setState(() {
                    _isBookmarkPressed = false;
                    _isBookmarked = !_isBookmarked;
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isBookmarked
                            ? 'Laporan berhasil disimpan ke bookmark'
                            : 'Laporan dihapus dari bookmark',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onTapCancel: () => setState(() => _isBookmarkPressed = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
    Color? iconColor,
    double iconSize = 25,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapCancel(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12312E).withValues(
                  alpha: isPressed ? 0.03 : 0.08,
                ),
                offset: isPressed ? const Offset(0, 2) : const Offset(0, 4),
                blurRadius: isPressed ? 4 : 12,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF12312E),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. HERO PHOTO BOX (Interaktif dengan Floating Badges)
  // ===========================================================================
  Widget _buildPhotoBox() {
    return GestureDetector(
      onTap: _showFullscreenImage,
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12302E).withValues(alpha: 0.08),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar Utama
              widget.imageAsset != null
                  ? Image.asset(
                      widget.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _status == ReportStatus.lost
                              ? const Color(0xFFFFE8E0)
                              : const Color(0xFFE0F4ED),
                          child: Center(
                            child: Icon(
                              widget.icon ?? Icons.inventory_2_outlined,
                              size: 64,
                              color: const Color(0xFF12312E),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: _status == ReportStatus.lost
                          ? const Color(0xFFFFE8E0)
                          : const Color(0xFFE0F4ED),
                      child: Center(
                        child: Icon(
                          widget.icon ?? Icons.inventory_2_outlined,
                          size: 64,
                          color: const Color(0xFF12312E),
                        ),
                      ),
                    ),

              // Glassy Floating Status Badge di pojok kiri atas foto
              Positioned(
                top: 14,
                left: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _status == ReportStatus.lost
                            ? const Color(0xFFFFE8E0).withValues(alpha: 0.90)
                            : const Color(0xFFD5F3E7).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _status == ReportStatus.lost
                                  ? const Color(0xFFE0533C)
                                  : const Color(0xFF17695D),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _status == ReportStatus.lost
                                ? 'Hilang'
                                : (_isResolved
                                    ? 'Selesai Ditemukan'
                                    : 'Ditemukan'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _status == ReportStatus.lost
                                  ? const Color(0xFFB03322)
                                  : const Color(0xFF115047),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Glassy Tap-to-Zoom Badge di pojok kanan bawah foto
              Positioned(
                bottom: 14,
                right: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lihat Foto',
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
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. TITLE & SOCIAL PROOF / ACTIVITY METADATA
  // ===========================================================================
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isOwner) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF17695D).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 13,
                  color: Color(0xFF17695D),
                ),
                const SizedBox(width: 5),
                Text(
                  'Laporan Anda Sendiri',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF17695D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          _title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: const Color(0xFF12312E),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF5E6E6A),
            ),
            const SizedBox(width: 4),
            Text(
              widget.timeAgo,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5E6E6A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 3.5,
              height: 3.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B9D98),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.visibility_outlined,
              size: 14,
              color: Color(0xFF5E6E6A),
            ),
            const SizedBox(width: 4),
            Text(
              '48x dilihat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5E6E6A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 3B. OWNER INSIGHTS & PERFORMANCE CARD (Khusus Pemilik Laporan)
  // ===========================================================================
  Widget _buildOwnerInsightsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF17695D).withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17695D).withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: Color(0xFF17695D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Performa & Status Laporan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF12312E),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isResolved
                      ? const Color(0xFF17695D).withValues(alpha: 0.12)
                      : const Color(0xFFE0533C).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isResolved ? 'Selesai' : 'Sedang Dicari',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isResolved
                        ? const Color(0xFF17695D)
                        : const Color(0xFFE0533C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Baris Metrik Stat
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.visibility_outlined,
                  value: '48x',
                  label: 'Dilihat Mahasiswa',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  value: '1 Kontak',
                  label: 'Respon Masuk',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.timer_outlined,
                  value: '2 Hari',
                  label: 'Masa Aktif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDEE8E2).withValues(alpha: 0.7),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF17695D)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF12312E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5E6E6A),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. INFO CARD (Lokasi, Tanggal, Kategori)
  // ===========================================================================
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            iconBg: const Color(0xFFE8F5F1),
            iconColor: const Color(0xFF17695D),
            label: 'Lokasi Terakhir',
            value: _location,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFDEE8E2).withValues(alpha: 0.6),
            ),
          ),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            iconBg: const Color(0xFFFFF1EB),
            iconColor: const Color(0xFFE0533C),
            label: 'Tanggal Dilaporkan',
            value: widget.date,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFDEE8E2).withValues(alpha: 0.6),
            ),
          ),
          _buildInfoRow(
            icon: Icons.category_rounded,
            iconBg: const Color(0xFFEBF3FF),
            iconColor: const Color(0xFF2563EB),
            label: 'Kategori Barang',
            value: widget.category,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 19),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5E6E6A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF12312E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. DESKRIPSI BARANG (Glassy Box)
  // ===========================================================================
  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 18,
                color: Color(0xFF17695D),
              ),
              const SizedBox(width: 8),
              Text(
                'Deskripsi Barang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF12312E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF425551),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. REPORTER CARD (Trust Badge Civitas UNESA / Owner Badge)
  // ===========================================================================
  Widget _buildReporterCard() {
    final name =
        widget.isOwner ? 'Farrel Farica (Kamu)' : widget.reporterName;
    final role = widget.isOwner
        ? 'Pemilik Laporan • Mahasiswa SI 2024'
        : widget.reporterRole;
    final initial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isOwner
                    ? [const Color(0xFF17695D), const Color(0xFF0F473E)]
                    : [const Color(0xFF17695D), const Color(0xFF2E8B7E)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF12312E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF17695D).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isOwner
                                ? Icons.admin_panel_settings_rounded
                                : Icons.verified_rounded,
                            size: 12,
                            color: const Color(0xFF17695D),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.isOwner
                                ? 'Pemilik'
                                : 'UNESA Terverifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF17695D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5E6E6A),
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
  // 7. CAMPUS SAFETY TIP NOTICE
  // ===========================================================================
  Widget _buildSafetyTipCard() {
    final title = widget.isOwner
        ? 'Panduan Aman Pemilik Laporan'
        : 'Tips Serah Terima Aman di Kampus';
    final desc = widget.isOwner
        ? 'Bila ada pihak yang mengabari menemukan barangmu, mintalah foto bukti spesifik (ciri khusus atau isi barang) sebelum melakukan serah terima di area publik kampus (seperti Pos Satpam atau Lobby Fakultas).'
        : 'Lakukan serah terima di area publik kampus (seperti Pos Satpam atau Lobby Fakultas). Pastikan memeriksa bukti kepemilikan sebelum menyerahkan barang.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDBA74).withValues(alpha: 0.45),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 18,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9A3412),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFC2410C),
                    height: 1.4,
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
  // 8A. FLOATING BOTTOM BAR (OWNER MANAGEMENT ACTIONS)
  // ===========================================================================
  Widget _buildOwnerBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row Tombol Sekunder: Edit & Hapus
            Row(
              children: [
                // Edit Laporan Button
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isEditPressed = true),
                    onTapUp: (_) {
                      setState(() => _isEditPressed = false);
                      _showEditReportSheet();
                    },
                    onTapCancel: () => setState(() => _isEditPressed = false),
                    child: AnimatedScale(
                      scale: _isEditPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDEE8E2),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF12312E)
                                  .withValues(alpha: 0.04),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF17695D),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit Laporan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF17695D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Hapus Laporan Button
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isDeletePressed = true),
                    onTapUp: (_) {
                      setState(() => _isDeletePressed = false);
                      _showDeleteReportSheet();
                    },
                    onTapCancel: () =>
                        setState(() => _isDeletePressed = false),
                    child: AnimatedScale(
                      scale: _isDeletePressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFDCFD0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE0533C)
                                  .withValues(alpha: 0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFE0533C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE0533C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tombol Utama: Tandai Sudah Ditemukan / Selesai
            GestureDetector(
              onTapDown: (_) =>
                  setState(() => _isMarkResolvedPressed = true),
              onTapUp: (_) {
                setState(() => _isMarkResolvedPressed = false);
                _showMarkResolvedSheet();
              },
              onTapCancel: () =>
                  setState(() => _isMarkResolvedPressed = false),
              behavior: HitTestBehavior.opaque,
              child: AnimatedScale(
                scale: _isMarkResolvedPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isResolved
                          ? [
                              const Color(0xFF5E6E6A),
                              const Color(0xFF455450),
                            ]
                          : [
                              const Color(0xFF17695D),
                              const Color(0xFF2E8B7E),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isResolved
                                ? const Color(0xFF5E6E6A)
                                : const Color(0xFF17695D))
                            .withValues(
                          alpha: _isMarkResolvedPressed ? 0.25 : 0.40,
                        ),
                        offset: _isMarkResolvedPressed
                            ? const Offset(0, 3)
                            : const Offset(0, 8),
                        blurRadius: _isMarkResolvedPressed ? 8 : 20,
                        spreadRadius: _isMarkResolvedPressed ? 0 : 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isResolved
                            ? Icons.replay_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isResolved
                            ? 'Buka Kembali Laporan'
                            : 'Tandai Sudah Ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 8B. FLOATING BOTTOM CTA (WHATSAPP BUTTON FOR STRANGER)
  // ===========================================================================
  Widget _buildBottomCta() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isWaPressed = true),
          onTapUp: (_) {
            setState(() => _isWaPressed = false);
            _showWhatsAppConfirmationSheet();
          },
          onTapCancel: () => setState(() => _isWaPressed = false),
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isWaPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF25D366),
                    Color(0xFF128C7E),
                  ],
                ),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF128C7E).withValues(
                      alpha: _isWaPressed ? 0.30 : 0.45,
                    ),
                    offset: _isWaPressed
                        ? const Offset(0, 3)
                        : const Offset(0, 8),
                    blurRadius: _isWaPressed ? 8 : 20,
                    spreadRadius: _isWaPressed ? 0 : 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hubungi via WhatsApp',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODAL BOTTOM SHEET: EDIT LAPORAN (OWNER MODE)
// =============================================================================
class _OwnerEditSheet extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController descCtrl;
  final Function(String, String, String) onSave;

  const _OwnerEditSheet({
    required this.titleCtrl,
    required this.locationCtrl,
    required this.descCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: Colors.white,
              width: 1.2,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                14,
                22,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12302E).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Edit Detail Laporan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF12312E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Perbarui data terkini agar penemu lebih mudah mengenali barangmu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5E6E6A),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Input Judul
                    Text(
                      'Nama Barang',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF12312E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: titleCtrl,
                      hint: 'Contoh: Dompet kulit hitam',
                    ),
                    const SizedBox(height: 14),

                    // Input Lokasi
                    Text(
                      'Lokasi Terakhir Terlihat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF12312E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: locationCtrl,
                      hint: 'Contoh: Gedung Perkuliahan, Lt. 2',
                    ),
                    const SizedBox(height: 14),

                    // Input Deskripsi
                    Text(
                      'Deskripsi & Ciri Spesifik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF12312E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(
                      controller: descCtrl,
                      hint: 'Sebutkan ciri khas yang membantu identifikasi',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),

                    // Tombol Simpan
                    GestureDetector(
                      onTap: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        onSave(
                          titleCtrl.text.trim(),
                          locationCtrl.text.trim(),
                          descCtrl.text.trim(),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF17695D), Color(0xFF2E8B7E)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF17695D)
                                  .withValues(alpha: 0.35),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDEE8E2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: const Color(0xFF12312E),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF8B9D98),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODAL BOTTOM SHEET: KONFIRMASI AKSI OWNER (Selesai / Hapus)
// =============================================================================
class _OwnerActionConfirmSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String confirmText;
  final VoidCallback onConfirm;
  final bool isDanger;

  const _OwnerActionConfirmSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.onConfirm,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: Colors.white,
              width: 1.2,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12302E).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 24, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF12312E),
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5E6E6A),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dual Button Side-by-Side
                  Row(
                    children: [
                      // Tombol Batal
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFDEE8E2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Batal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF12312E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol Konfirmasi
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDanger
                                    ? [
                                        const Color(0xFFE0533C),
                                        const Color(0xFFC2410C),
                                      ]
                                    : [
                                        const Color(0xFF17695D),
                                        const Color(0xFF2E8B7E),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDanger
                                          ? const Color(0xFFE0533C)
                                          : const Color(0xFF17695D))
                                      .withValues(alpha: 0.35),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                confirmText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODAL BOTTOM SHEET: KONFIRMASI WHATSAPP (Frosted Glass & Side-by-Side Dual Button)
// =============================================================================
class _WhatsAppConfirmSheet extends StatefulWidget {
  final String itemTitle;
  final String reporterName;
  final String reporterRole;
  final String whatsappNumber;
  final String? imageAsset;
  final IconData? icon;

  const _WhatsAppConfirmSheet({
    required this.itemTitle,
    required this.reporterName,
    required this.reporterRole,
    required this.whatsappNumber,
    this.imageAsset,
    this.icon,
  });

  @override
  State<_WhatsAppConfirmSheet> createState() => _WhatsAppConfirmSheetState();
}

class _WhatsAppConfirmSheetState extends State<_WhatsAppConfirmSheet> {
  bool _isSubmitPressed = false;
  bool _isCancelPressed = false;

  Future<void> _launchWhatsApp(BuildContext context) async {
    final cleanPhone = widget.whatsappNumber
        .replaceAll('+', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');

    final message = Uri.encodeComponent(
      'Halo ${widget.reporterName}, saya melihat laporan Anda di FindIT Campus mengenai "${widget.itemTitle}". Apakah barang tersebut masih ada?',
    );

    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Tidak dapat membuka WhatsApp (${widget.whatsappNumber})'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                Colors.white.withValues(alpha: 0.76),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12302E).withValues(alpha: 0.12),
                offset: const Offset(0, -6),
                blurRadius: 30,
                spreadRadius: -2,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12302E).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul Sheet
                  Text(
                    'Hubungi via WhatsApp?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF12312E),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kamu akan diarahkan ke WhatsApp untuk menghubungi pelapor tentang:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5E6E6A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quoted Item Box (Glassy Card)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.90),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF12302E).withValues(alpha: 0.04),
                          offset: const Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 42,
                            height: 42,
                            color: const Color(0xFFFFD9CC),
                            child: widget.imageAsset != null
                                ? Image.asset(
                                    widget.imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Color(0xFF12312E),
                                        size: 22,
                                      );
                                    },
                                  )
                                : Icon(
                                    widget.icon ?? Icons.inventory_2_outlined,
                                    color: const Color(0xFF12312E),
                                    size: 22,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${widget.itemTitle}"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF12312E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pelapor: ${widget.reporterName} (${widget.reporterRole})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF5E6E6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Dual Buttons Side-by-Side (Opsi 1: Batal & Buka WhatsApp Berdampingan)
                  Row(
                    children: [
                      // Tombol Batal (Secondary Glassy Pill)
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _isCancelPressed = true),
                          onTapUp: (_) {
                            setState(() => _isCancelPressed = false);
                            Navigator.pop(context);
                          },
                          onTapCancel: () =>
                              setState(() => _isCancelPressed = false),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedScale(
                            scale: _isCancelPressed ? 0.94 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: _isCancelPressed
                                    ? const Color(0xFF12302E)
                                        .withValues(alpha: 0.10)
                                    : Colors.white.withValues(alpha: 0.60),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: _isCancelPressed
                                      ? const Color(0xFF12302E)
                                          .withValues(alpha: 0.18)
                                      : const Color(0xFFDEE8E2),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF12312E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol Buka WhatsApp (Primary Glassy Green Pill)
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _isSubmitPressed = true),
                          onTapUp: (_) {
                            setState(() => _isSubmitPressed = false);
                            _launchWhatsApp(context);
                          },
                          onTapCancel: () =>
                              setState(() => _isSubmitPressed = false),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedScale(
                            scale: _isSubmitPressed ? 0.95 : 1.0,
                            duration: const Duration(milliseconds: 110),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF25D366), // WhatsApp Green
                                    Color(0xFF128C7E), // Deep WhatsApp Teal
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF128C7E).withValues(
                                      alpha: _isSubmitPressed ? 0.25 : 0.42,
                                    ),
                                    offset: _isSubmitPressed
                                        ? const Offset(0, 2)
                                        : const Offset(0, 6),
                                    blurRadius: _isSubmitPressed ? 6 : 16,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buka WhatsApp',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
