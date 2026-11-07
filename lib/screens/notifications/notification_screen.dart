import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/status_chip.dart';
import '../detail/detail_screen.dart';

/// Kategori Notifikasi FindIT Campus (Aman & Realistis untuk Presentasi PAB)
enum NotificationCategory {
  myReport, // Status & aktivitas laporan sendiri (diterbitkan, pengingat, selesai)
  campusFinding, // Laporan temuan baru di area kampus sekitar
  campusBroadcast, // Pengumuman resmi pos satpam & civitas kampus
}

/// Model Data Notifikasi Kampus
class CampusNotificationItem {
  final String id;
  final String title;
  final String senderName;
  final String body;
  final String targetItemTitle;
  final String targetItemLocation;
  final String targetCategory;
  final ReportStatus targetStatus;
  final String? imageAsset;
  final NotificationCategory category;
  final String timeAgo;
  final String timeSection; // 'HARI INI', 'KEMARIN', 'PEKAN LALU'
  bool isRead;

  CampusNotificationItem({
    required this.id,
    required this.title,
    required this.senderName,
    required this.body,
    required this.targetItemTitle,
    required this.targetItemLocation,
    required this.targetCategory,
    required this.targetStatus,
    this.imageAsset,
    required this.category,
    required this.timeAgo,
    required this.timeSection,
    this.isRead = false,
  });
}

/// Model Stacked Toast khas Motion.dev (Vue Toast Stack)
class StackedToastItem {
  final String id;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StackedToastItem({
    required this.id,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.actionLabel,
    this.onAction,
  });
}

/// Halaman Pusat Notifikasi (Notification Center) khas Apple Design & UI-Taste
class NotificationScreen extends StatefulWidget {
  final int initialUnreadCount;

  const NotificationScreen({
    super.key,
    this.initialUnreadCount = 3,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // State Filter Segmented Control (0: Semua, 1: Respon, 2: Status, 3: Kampus)
  int _selectedFilterIndex = 0;
  bool _isBackPressed = false;
  bool _isMarkAllPressed = false;
  int? _pressedCardIndex;

  // Motion.dev Stacked Toast System
  final List<StackedToastItem> _toastStack = [];

  void _showStackedToast({
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = StackedToastItem(
      id: id,
      message: message,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    setState(() {
      if (_toastStack.length >= 3) {
        _toastStack.removeAt(0);
      }
      _toastStack.add(item);
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _toastStack.removeWhere((t) => t.id == id);
        });
      }
    });
  }

  // Dataset Mock Notifikasi Kampus Realistis (Aman untuk Ujian PAB)
  late List<CampusNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      // 1. Publikasi Laporan Sendiri (Unread - Hari Ini)
      CampusNotificationItem(
        id: 'notif_1',
        title: 'Laporan Berhasil Dipublikasikan',
        senderName: 'Sistem FindIT Kampus',
        body:
            'Laporan kehilangan "Dompet kulit hitam" kamu sudah tayang di feed dan dapat dilihat civitas kampus.',
        targetItemTitle: 'Dompet kulit hitam',
        targetItemLocation: 'Gedung Perkuliahan, Lt. 2',
        targetCategory: 'Dompet',
        targetStatus: ReportStatus.lost,
        imageAsset: 'assets/images/dompet_kulit.jpg',
        category: NotificationCategory.myReport,
        timeAgo: '15 menit lalu',
        timeSection: 'HARI INI',
        isRead: false,
      ),

      // 2. Laporan Temuan Baru di Area Kampus (Unread - Hari Ini)
      CampusNotificationItem(
        id: 'notif_2',
        title: 'Barang Temuan Baru di Sekitarmu',
        senderName: 'Perpustakaan Pusat · Ketintang',
        body:
            'Mahasiswa melaporkan penemuan "Kunci motor Honda" di meja baca lantai 1. Ketuk untuk memeriksa detail.',
        targetItemTitle: 'Kunci motor Honda',
        targetItemLocation: 'Stasiun Ketintang',
        targetCategory: 'Kunci',
        targetStatus: ReportStatus.found,
        imageAsset: 'assets/images/kunci_motor.jpg',
        category: NotificationCategory.campusFinding,
        timeAgo: '45 menit lalu',
        timeSection: 'HARI INI',
        isRead: false,
      ),

      // 3. Pengumuman Pos Satpam Kampus (Unread - Hari Ini)
      CampusNotificationItem(
        id: 'notif_3',
        title: 'Pengumuman Pos Satpam Utama',
        senderName: 'Pos Satpam UNESA Ketintang',
        body:
            'Ditemukan tas ransel laptop hitam di Gazebo Fakultas Teknik. Bagi pemilik silakan mengambil ke Pos Barat.',
        targetItemTitle: 'Tas laptop hitam',
        targetItemLocation: 'Gazebo FT UNESA',
        targetCategory: 'Elektronik',
        targetStatus: ReportStatus.found,
        imageAsset: 'assets/images/tas_laptop.jpg',
        category: NotificationCategory.campusBroadcast,
        timeAgo: '2 jam lalu',
        timeSection: 'HARI INI',
        isRead: false,
      ),

      // 4. Pengingat Masa Aktif Laporan Sendiri (Read - Kemarin)
      CampusNotificationItem(
        id: 'notif_4',
        title: 'Pengingat Masa Aktif Laporan',
        senderName: 'Sistem FindIT Kampus',
        body:
            'Laporan "Dompet kulit hitam" sudah aktif 2 hari. Sudahkah barangmu kembali? Ketuk untuk memperbarui status.',
        targetItemTitle: 'Dompet kulit hitam',
        targetItemLocation: 'Gedung Perkuliahan, Lt. 2',
        targetCategory: 'Dompet',
        targetStatus: ReportStatus.lost,
        imageAsset: 'assets/images/dompet_kulit.jpg',
        category: NotificationCategory.myReport,
        timeAgo: 'Kemarin, 14.15',
        timeSection: 'KEMARIN',
        isRead: true,
      ),

      // 5. Status Selesai / Arsip (Read - Pekan Lalu)
      CampusNotificationItem(
        id: 'notif_5',
        title: 'Laporan Ditandai Selesai',
        senderName: 'Sistem FindIT Kampus',
        body:
            'Laporan temuan "Kacamata hitam frame bulat" telah berhasil ditandai selesai dan diarsipkan dari feed publik.',
        targetItemTitle: 'Kacamata hitam frame bulat',
        targetItemLocation: 'Perpustakaan Lt. 1',
        targetCategory: 'Lainnya',
        targetStatus: ReportStatus.found,
        category: NotificationCategory.myReport,
        timeAgo: '4 hari lalu',
        timeSection: 'PEKAN LALU',
        isRead: true,
      ),
    ];
  }

  // Hitung jumlah notifikasi yang belum dibaca
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  int get _myReportsUnreadCount => _notifications
      .where((n) => !n.isRead && n.category == NotificationCategory.myReport)
      .length;

  int get _campusUnreadCount => _notifications
      .where((n) =>
          !n.isRead &&
          (n.category == NotificationCategory.campusFinding ||
              n.category == NotificationCategory.campusBroadcast))
      .length;

  // Filter notifikasi sesuai tab aktif
  List<CampusNotificationItem> get _filteredNotifications {
    switch (_selectedFilterIndex) {
      case 1:
        return _notifications
            .where((n) => n.category == NotificationCategory.myReport)
            .toList();
      case 2:
        return _notifications
            .where((n) =>
                n.category == NotificationCategory.campusFinding ||
                n.category == NotificationCategory.campusBroadcast)
            .toList();
      case 0:
      default:
        return _notifications;
    }
  }

  // Aksi Tandai Semua Dibaca
  void _markAllAsRead() {
    if (_unreadCount == 0) return;
    setState(() {
      for (final item in _notifications) {
        item.isRead = true;
      }
    });
    _showStackedToast(
      message: 'Semua notifikasi ditandai dibaca',
      icon: Icons.done_all_rounded,
      iconColor: const Color(0xFF34D399),
      iconBg: const Color(0xFF14332D),
    );
  }

  // Aksi Buka Detail Laporan saat Notifikasi di-tap
  void _handleNotificationTap(CampusNotificationItem item) {
    setState(() {
      item.isRead = true;
    });

    Navigator.push(
      context,
      SmoothPageRoute(
        child: DetailScreen(
          title: item.targetItemTitle,
          location: item.targetItemLocation,
          category: item.targetCategory,
          status: item.targetStatus,
          imageAsset: item.imageAsset,
          isOwner: item.category == NotificationCategory.myReport,
        ),
      ),
    );
  }

  // Aksi Hapus Notifikasi (Swipe-to-Dismiss)
  void _deleteNotification(CampusNotificationItem item, int index) {
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });

    _showStackedToast(
      message: 'Notifikasi dihapus',
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFF87171),
      iconBg: const Color(0xFF2C1917),
      actionLabel: 'Urungkan',
      onAction: () {
        setState(() {
          _notifications.insert(index, item);
        });
      },
    );
  }

  // Handle pop back with remaining unread count
  void _handleBack() {
    Navigator.pop(context, _unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final topPadding = MediaQuery.of(context).padding.top;
    final safeTop = topPadding > 0 ? topPadding : 20.0;
    // Header total height = safeTop + 8 (top pad) + 40 (row) + 10 (gap) + 38 (filter) + 12 (bottom pad) = safeTop + 108
    final headerHeight = safeTop + 108.0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // PopScope callback
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
        body: Stack(
          children: [
            // 1. Konten Notifikasi Utama (Scrollable)
            ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Spacer setinggi Sticky Top Bar + offset mikro elegan (6px)
                  SliverToBoxAdapter(
                    child: SizedBox(height: headerHeight + 6),
                  ),

                  // Daftar Notifikasi atau Empty State
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    ..._buildGroupedNotificationSlivers(filtered),

                  // Spacer bawah agar kartu terbawah tidak mepet
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 72),
                  ),
                ],
              ),
            ),

            // 2. Fixed Frosted Glass Top Bar + Segmented Filter Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildStickyHeaderWithFilters(safeTop),
            ),

            // 3. Motion.dev Stacked Toast Container (Vue Toast Stack)
            if (_toastStack.isNotEmpty)
              Positioned(
                bottom: 24,
                left: 18,
                right: 18,
                child: _buildToastStackView(),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. STICKY FROSTED GLASS HEADER & SEGMENTED FILTERS
  // ===========================================================================
  Widget _buildStickyHeaderWithFilters(double safeTop) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F3).withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFDEE8E2).withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: safeTop + 8,
            bottom: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar: Back Button, Title + Unread Pill, "Tandai dibaca" Action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Back Button Circle (Apple Tactile)
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isBackPressed = true),
                      onTapUp: (_) {
                        setState(() => _isBackPressed = false);
                        _handleBack();
                      },
                      onTapCancel: () => setState(() => _isBackPressed = false),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedScale(
                        scale: _isBackPressed ? 0.90 : 1.0,
                        duration: const Duration(milliseconds: 110),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDEE8E2)
                                  .withValues(alpha: 0.7),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF12302E)
                                    .withValues(alpha: 0.05),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 17,
                              color: Color(0xFF12312E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title Header + Badge Unread Count
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Notifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF12312E),
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.coral500,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '$_unreadCount Baru',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Trailing Action: "Tandai dibaca"
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _isMarkAllPressed = true),
                      onTapUp: (_) {
                        setState(() => _isMarkAllPressed = false);
                        _markAllAsRead();
                      },
                      onTapCancel: () =>
                          setState(() => _isMarkAllPressed = false),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedScale(
                        scale: _isMarkAllPressed ? 0.94 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _unreadCount > 0
                                ? const Color(0xFF17695D)
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.done_all_rounded,
                                size: 16,
                                color: _unreadCount > 0
                                    ? const Color(0xFF17695D)
                                    : const Color(0xFF8B9D98),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tandai dibaca',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _unreadCount > 0
                                      ? const Color(0xFF17695D)
                                      : const Color(0xFF8B9D98),
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

              const SizedBox(height: 10),

              // Filter Capsules Segmented Bar
              _buildFilterCapsules(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. APPLE FILTER CAPSULES (SEGMENTED CONTROL)
  // ===========================================================================
  Widget _buildFilterCapsules() {
    final filters = [
      {'label': 'Semua', 'count': _unreadCount},
      {
        'label': 'Laporanmu',
        'count': _myReportsUnreadCount > 0 ? _myReportsUnreadCount : null,
      },
      {
        'label': 'Info Kampus',
        'count': _campusUnreadCount > 0 ? _campusUnreadCount : null,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          final isSelected = _selectedFilterIndex == index;
          final count = filter['count'] as int?;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF17695D)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF17695D)
                        : const Color(0xFFDEE8E2),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF17695D)
                                .withValues(alpha: 0.22),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF5E6E6A),
                      ),
                    ),
                    if (count != null && count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.coral500,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // 3. GROUPED NOTIFICATIONS (SLIVERS)
  // ===========================================================================
  List<Widget> _buildGroupedNotificationSlivers(
      List<CampusNotificationItem> items) {
    // Kelompokkan item berdasarkan timeSection: 'HARI INI', 'KEMARIN', 'PEKAN LALU'
    final Map<String, List<CampusNotificationItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.timeSection, () => []).add(item);
    }

    final slivers = <Widget>[];

    grouped.forEach((section, sectionItems) {
      // Header Section
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
            child: Text(
              section,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: const Color(0xFF8B9D98),
              ),
            ),
          ),
        ),
      );

      // Card List per Section
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = sectionItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildNotificationCard(item),
                );
              },
              childCount: sectionItems.length,
            ),
          ),
        ),
      );
    });

    return slivers;
  }

  // ===========================================================================
  // 4. NOTIFICATION CARD COMPONENT (WITH SWIPE-TO-DISMISS & TACTILE PRESS)
  // ===========================================================================
  Widget _buildNotificationCard(CampusNotificationItem item) {
    final originalIndex = _notifications.indexOf(item);
    final isPressed = _pressedCardIndex == originalIndex;

    // Visual attributes berdasarkan category
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (item.category) {
      case NotificationCategory.myReport:
        if (item.title.contains('Pengingat') ||
            item.title.contains('Masa Aktif')) {
          icon = Icons.schedule_rounded;
          iconColor = const Color(0xFFCA8A04);
          iconBg = const Color(0xFFFEF9C3);
        } else {
          icon = Icons.check_circle_outline_rounded;
          iconColor = const Color(0xFF17695D);
          iconBg = const Color(0xFFE8F5F1);
        }
        break;
      case NotificationCategory.campusFinding:
        icon = Icons.inventory_2_outlined;
        iconColor = const Color(0xFF2563EB);
        iconBg = const Color(0xFFEBF3FF);
        break;
      case NotificationCategory.campusBroadcast:
        icon = Icons.campaign_rounded;
        iconColor = const Color(0xFFE0533C);
        iconBg = const Color(0xFFFFF1EB);
        break;
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2), // Soft coral red
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _deleteNotification(item, originalIndex),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedCardIndex = originalIndex),
        onTapUp: (_) {
          setState(() => _pressedCardIndex = null);
          _handleNotificationTap(item);
        },
        onTapCancel: () => setState(() => _pressedCardIndex = null),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isPressed ? 0.982 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.isRead
                  ? Colors.white.withValues(alpha: 0.85)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: !item.isRead
                    ? const Color(0xFF17695D).withValues(alpha: 0.28)
                    : const Color(0xFFE5EDE8),
                width: !item.isRead ? 1.2 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF12302E).withValues(
                    alpha: !item.isRead ? 0.06 : 0.025,
                  ),
                  offset: const Offset(0, 3),
                  blurRadius: !item.isRead ? 10 : 4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Squircle (42x42)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Judul / Sender + Timestamp + Coral Pip Dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: !item.isRead
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: const Color(0xFF12312E),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.timeAgo,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8B9D98),
                            ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.coral500,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Sender Subtitle
                      if (item.senderName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.senderName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF17695D),
                          ),
                        ),
                      ],

                      const SizedBox(height: 5),

                      // Notification Body Message
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5E6E6A),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // Target Item Micro Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE2EBE6),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: Color(0xFF17695D),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${item.targetItemTitle} • ${item.targetItemLocation}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF12312E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 13,
                              color: Color(0xFF8B9D98),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. APPLE EMPTY STATE (ZERO SLOP)
  // ===========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Frosted Circular Icon Box
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF17695D).withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.done_all_rounded,
                  size: 34,
                  color: Color(0xFF17695D),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Semua Terbaca & Rapi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12312E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              _selectedFilterIndex == 0
                  ? 'Belum ada notifikasi baru seputar barangmu. Respon atau info kampus akan muncul di sini.'
                  : 'Tidak ada notifikasi di kategori ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5E6E6A),
                height: 1.45,
              ),
            ),

            if (_selectedFilterIndex != 0) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilterIndex = 0;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17695D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lihat Semua Notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ===========================================================================
  // 6. MOTION.DEV TOAST STACK (VUE TOAST STACK / SONNER 3D EFFECT)
  // ===========================================================================
  Widget _buildToastStackView() {
    final visibleToasts = _toastStack.length > 3
        ? _toastStack.sublist(_toastStack.length - 3)
        : _toastStack;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: List.generate(visibleToasts.length, (i) {
        final toast = visibleToasts[i];
        final depth = (visibleToasts.length - 1) - i; // 0 = aktif depan, 1 = tengah, 2 = belakang
        final scale = 1.0 - (depth * 0.05);
        final translateY = -(depth * 9.0);
        final opacity = (1.0 - (depth * 0.32)).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: depth != 0, // Hanya toast terdepan yang menerima sentuhan
                child: _buildToastCard(toast),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToastCard(StackedToastItem toast) {
    return Dismissible(
      key: ValueKey(toast.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        setState(() {
          _toastStack.removeWhere((t) => t.id == toast.id);
        });
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF071816).withValues(alpha: 0.28),
                offset: const Offset(0, 8),
                blurRadius: 22,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF142724).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Squircle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: toast.iconBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          toast.icon,
                          color: toast.iconColor,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Message Text (Ringkas 1 Baris Elegan)
                    Expanded(
                      child: Text(
                        toast.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    // Optional Action Button (e.g. "Urungkan")
                    if (toast.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          toast.onAction?.call();
                          setState(() {
                            _toastStack.removeWhere((t) => t.id == toast.id);
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17695D),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF17695D).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            toast.actionLabel!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Dismiss Close Icon
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _toastStack.removeWhere((t) => t.id == toast.id);
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.55),
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
}
