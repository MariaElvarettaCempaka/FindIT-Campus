import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimens.dart';
import '../../models/report_item_model.dart';
import '../../widgets/status_chip.dart';
import '../detail/detail_screen.dart';
import '../detail/found_detail_screen.dart';

/// Halaman Riwayat Laporan Pengguna (FindIT Campus - Apple Design & Taste Refined).
///
/// Fitur Utama:
/// 1. TabBar 2 Tab (Barang Hilang & Barang Ditemukan) dengan margin top konsisten (AppDimens.screenInset = 22px).
/// 2. Tab Barang Hilang: Laporan barang hilang pribadi -> tap membuka DetailScreen (Mode Pemilik / Owner Mode).
/// 3. Tab Barang Ditemukan: Menggunakan detail modal temuan Orang 2 (showFoundDetailModal) versi Pribadi / Owner Mode
///    (bisa update status selesai, edit lokasi titip, dan hapus laporan).
/// 4. Charles UX Animation: Feedback taktil pegas (AnimatedScale) pada tombol back dan kartu laporan.
class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBackPressed = false;
  int? _pressedLostIndex;
  int? _pressedFoundIndex;

  // Mock list laporan user sendiri (In-memory, Zero Firebase)
  late List<ReportItemModel> _myLostReports;
  late List<Map<String, dynamic>> _myFoundReports;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _myLostReports = [
      ReportItemModel(
        id: 'lost_01',
        title: 'Dompet kulit hitam',
        category: 'Dompet',
        location: 'Gedung Perkuliahan, Lt. 2 • Ketintang',
        date: '14 Nov 2026',
        timeAgo: '2 jam lalu',
        description:
            'Dompet hitam berisi KTM, SIM C, dan kartu identitas penting. Terakhir terlihat saat kuliah jam 10 pagi di tangga lantai 2.',
        reporterName: 'Farrel Farica',
        reporterRole: 'Mahasiswa · SI 2024',
        reporterPhone: '081234567890',
        imageAsset: 'assets/images/dompet_kulit.jpg',
        isLost: true,
        status: 'Dalam Proses',
        isOwner: true,
        viewsCount: 32,
        responsesCount: 3,
        activeDays: '1 hari',
      ),
      ReportItemModel(
        id: 'lost_02',
        title: 'KTM UNESA atas nama Farrel',
        category: 'Dokumen',
        location: 'Perpustakaan Pusat • Lidah Wetan',
        date: '10 Nov 2026',
        timeAgo: '4 hari lalu',
        description:
            'Kartu Tanda Mahasiswa tertinggal di meja baca lantai 2 dekat jendela barat.',
        reporterName: 'Farrel Farica',
        reporterRole: 'Mahasiswa · SI 2024',
        reporterPhone: '081234567890',
        imageAsset: 'assets/images/raw_image_4.png',
        isLost: true,
        status: 'Selesai',
        isOwner: true,
        resolvedDate: '11 Nov 2026',
        viewsCount: 45,
        responsesCount: 2,
        activeDays: 'Selesai',
      ),
    ];

    _myFoundReports = [
      {
        'id': 'found_01',
        'title': 'Kunci Motor Honda Vario',
        'category': 'Kunci',
        'location': 'Pos Satpam Utama • Ketintang',
        'date': '13 Nov 2026',
        'timeAgo': '1 hari lalu',
        'images': ['assets/images/kunci_motor.jpg'],
        'imageAsset': 'assets/images/kunci_motor.jpg',
        'storageType': 'satpam',
        'storageLabel': 'Pos Satpam Utama Ketintang',
        'holderName': 'Pak Joko (Satpam Ketintang)',
        'operatingHours': '24 Jam (Posko Satpam Gerbang Depan)',
        'requiredProof': 'Wajib menunjukkan STNK motor asli atau kunci cadangan motor saat serah terima.',
        'claimRequirement': 'Sebutkan warna gantungan boneka kecil pada anak kunci.',
        'statusLabel': 'Dalam Proses',
        'isCompleted': false,
      },
      {
        'id': 'found_02',
        'title': 'Tumbler Minum Biru Toska',
        'category': 'Aksesoris',
        'location': 'Lobby Rektorat Lt. 1 • Lidah Wetan',
        'date': '08 Nov 2026',
        'timeAgo': '6 hari lalu',
        'images': ['assets/images/raw_image_1.png'],
        'imageAsset': 'assets/images/raw_image_1.png',
        'storageType': 'official',
        'storageLabel': 'Loket Informasi Rektorat Lt. 1',
        'holderName': 'Staff Informasi Kampus Lidah Wetan',
        'operatingHours': 'Jam Kerja Kampus (08.00 - 16.00 WIB)',
        'requiredProof': 'Sebutkan warna karet seal penutup bagian dalam.',
        'claimRequirement': 'Sebutkan bentuk stiker atau ciri goresan pada tumbler.',
        'statusLabel': 'Selesai',
        'isCompleted': true,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openLostDetail(ReportItemModel report, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          report: report,
          isOwner: true,
        ),
      ),
    );

    if (result == 'deleted' && mounted) {
      setState(() {
        _myLostReports.removeWhere((r) => r.id == report.id);
      });
    } else if (result is ReportItemModel && mounted) {
      setState(() {
        _myLostReports[index] = result;
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  void _openFoundDetail(Map<String, dynamic> item, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoundDetailScreen(
          item: item,
          isOwner: true,
        ),
      ),
    );

    if (result == 'deleted' && mounted) {
      setState(() {
        _myFoundReports.removeAt(index);
      });
    } else if (result is Map<String, dynamic> && mounted) {
      setState(() {
        _myFoundReports[index] = result;
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Riwayat Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.green950,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.teal700,
          unselectedLabelColor: AppColors.slate600,
          indicatorColor: AppColors.teal600,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.search_rounded, size: 20),
              text: 'Barang Hilang',
            ),
            Tab(
              icon: Icon(Icons.inventory_2_outlined, size: 20),
              text: 'Barang Ditemukan',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLostList(),
          _buildFoundList(),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: LIST BARANG HILANG PRIBADI (APPLE DESIGN & UI-TASTE REFINED)
  // ===========================================================================
  Widget _buildLostList() {
    if (_myLostReports.isEmpty) {
      return _buildEmptyState(
        isLostTab: true,
        title: 'Belum Ada Laporan Kehilangan',
        subtitle: 'Kamu belum pernah membuat laporan barang hilang di kampus.',
      );
    }

    return ListView.builder(
      // MARGIN TOP KONSISTEN & LEGA (AppDimens.screenInset = 22px)
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenInset,
        AppDimens.screenInset,
        AppDimens.screenInset,
        40,
      ),
      itemCount: _myLostReports.length,
      itemBuilder: (context, index) {
        final item = _myLostReports[index];
        final isCompleted = item.isCompleted;
        final isPressed = _pressedLostIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressedLostIndex = index),
            onTapUp: (_) {
              setState(() => _pressedLostIndex = null);
              _openLostDetail(item, index);
            },
            onTapCancel: () => setState(() => _pressedLostIndex = null),
            child: AnimatedScale(
              scale: isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                  border: Border.all(color: const Color(0xFFE8EFEA), width: 1.2),
                  boxShadow: AppDimens.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail 84x84 Rounded 16px dengan soft border
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE8EFEA), width: 1),
                            ),
                            child: item.imageAsset != null && item.imageAsset!.isNotEmpty
                                ? Image.asset(
                                    item.imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.teal600,
                                      size: 32,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.teal600,
                                    size: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info Kolom Kanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badges Row: Status + Kategori
                              Row(
                                children: [
                                  const StatusChip.lost(),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.sand100,
                                      borderRadius: BorderRadius.circular(AppDimens.radius99),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green950,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Judul Barang
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Lokasi Terakhir Terlihat
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13.5,
                                    color: AppColors.teal700,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                      ],
                    ),

                    // Hairline Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),
                    ),

                    // Baris Bawah: Tanggal di Kiri, Status + Drilldown di Kanan
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12.5,
                          color: AppColors.textPlaceholder,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.mint200 : AppColors.peach100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCompleted ? AppColors.mint300 : AppColors.peach200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                                size: 11.5,
                                color: isCompleted ? AppColors.teal700 : AppColors.rust800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.status,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted ? AppColors.teal700 : AppColors.rust800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.slate600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 2: LIST BARANG TEMUAN PRIBADI (APPLE DESIGN & UI-TASTE REFINED)
  // ===========================================================================
  Widget _buildFoundList() {
    if (_myFoundReports.isEmpty) {
      return _buildEmptyState(
        isLostTab: false,
        title: 'Belum Ada Laporan Penemuan',
        subtitle: 'Kamu belum pernah membuat laporan barang temuan di kampus.',
      );
    }

    return ListView.builder(
      // MARGIN TOP KONSISTEN & LEGA (AppDimens.screenInset = 22px)
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenInset,
        AppDimens.screenInset,
        AppDimens.screenInset,
        40,
      ),
      itemCount: _myFoundReports.length,
      itemBuilder: (context, index) {
        final item = _myFoundReports[index];
        final isCompleted = item['isCompleted'] == true || item['statusLabel'] == 'Selesai';
        final isPressed = _pressedFoundIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressedFoundIndex = index),
            onTapUp: (_) {
              setState(() => _pressedFoundIndex = null);
              _openFoundDetail(item, index);
            },
            onTapCancel: () => setState(() => _pressedFoundIndex = null),
            child: AnimatedScale(
              scale: isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                  border: Border.all(color: const Color(0xFFE8EFEA), width: 1.2),
                  boxShadow: AppDimens.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail 84x84 Rounded 16px dengan soft border
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE8EFEA), width: 1),
                            ),
                            child: item['imageAsset'] != null
                                ? Image.asset(
                                    item['imageAsset'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.teal600,
                                      size: 32,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.teal600,
                                    size: 32,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info Kolom Kanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badges Row: Status Temuan + Kategori
                              Row(
                                children: [
                                  const StatusChip.found(),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.sand100,
                                      borderRadius: BorderRadius.circular(AppDimens.radius99),
                                    ),
                                    child: Text(
                                      item['category'] as String? ?? 'Temuan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green950,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Judul Barang
                              Text(
                                item['title'] as String? ?? 'Barang Temuan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Lokasi Penyimpanan / Hotspot
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 13.5,
                                    color: AppColors.teal600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['storageLabel'] as String? ?? item['location'] as String? ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                      ],
                    ),

                    // Hairline Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),
                    ),

                    // Baris Bawah: Tanggal di Kiri, Status + Drilldown di Kanan
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12.5,
                          color: AppColors.textPlaceholder,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item['date'] as String? ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.mint200 : const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCompleted ? AppColors.mint300 : const Color(0xFFFFEEBA),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                                size: 11.5,
                                color: isCompleted ? AppColors.teal700 : const Color(0xFF856404),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCompleted ? 'Selesai' : 'Dalam Proses',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted ? AppColors.teal700 : const Color(0xFF856404),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.slate600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required bool isLostTab,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.mint300.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 40, color: AppColors.teal700),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.green950,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.slate700,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
