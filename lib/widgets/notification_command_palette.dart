import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/smooth_page_route.dart';
import '../main.dart';
import '../screens/found/found_screen.dart';
import 'app_toast_stack.dart';

/// Kategori Filter Notifikasi
enum NotificationPaletteCategory {
  all,
  myReports,
  campusInfo,
}

/// Item Model Notifikasi untuk Command Palette
class PaletteNotificationItem {
  final String id;
  final String title;
  final String sender;
  final String message;
  final String targetItemTitle;
  final String targetLocation;
  final NotificationPaletteCategory category;
  final String timeAgo;
  final String timeSection; // 'HARI INI', 'KEMARIN', 'PEKAN LALU'
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  bool isRead;

  PaletteNotificationItem({
    required this.id,
    required this.title,
    required this.sender,
    required this.message,
    required this.targetItemTitle,
    required this.targetLocation,
    required this.category,
    required this.timeAgo,
    required this.timeSection,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRead = false,
  });
}

/// Tampilkan Notification Command Palette Modal (Mobile-First Apple Glassy Blur Style)
/// Terinspirasi dari Motion.dev Command Palette dengan Glassy Translucent Blur khas Apple.
Future<int?> showNotificationCommandPalette(
  BuildContext context, {
  required int initialUnreadCount,
  bool isAlreadyOnFoundScreen = false,
}) {
  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup Notifikasi Command Palette',
    barrierColor: const Color(0xFF12312E).withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, anim1, anim2) {
      return NotificationCommandPalette(
        initialUnreadCount: initialUnreadCount,
        isAlreadyOnFoundScreen: isAlreadyOnFoundScreen,
      );
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
          scale: Tween<double>(begin: 0.93, end: 1.0).animate(curvedAnim),
          child: child,
        ),
      );
    },
  );
}

/// Widget Modal Notification Command Palette untuk Mobile / HP
class NotificationCommandPalette extends StatefulWidget {
  final int initialUnreadCount;
  final bool isAlreadyOnFoundScreen;

  const NotificationCommandPalette({
    super.key,
    required this.initialUnreadCount,
    this.isAlreadyOnFoundScreen = false,
  });

  @override
  State<NotificationCommandPalette> createState() =>
      _NotificationCommandPaletteState();
}

class _NotificationCommandPaletteState
    extends State<NotificationCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  NotificationPaletteCategory _selectedFilter = NotificationPaletteCategory.all;
  int? _pressedFilterIndex;
  int? _pressedItemIndex;
  bool _isMarkAllPressed = false;
  String? _expandedItemId;

  late List<PaletteNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      PaletteNotificationItem(
        id: 'notif-1',
        title: 'Laporan Berhasil Dipublikasikan',
        sender: 'Sistem FindIT Kampus',
        message:
            'Laporan kehilangan "Dompet kulit hitam" kamu sudah tayang di feed civitas kampus.',
        targetItemTitle: 'Dompet kulit hitam',
        targetLocation: 'Gedung Perkuliahan, Lt. 2',
        category: NotificationPaletteCategory.myReports,
        timeAgo: '15 menit lalu',
        timeSection: 'HARI INI',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF17695D),
        iconBg: const Color(0xFF17695D).withValues(alpha: 0.12),
        isRead: false,
      ),
      PaletteNotificationItem(
        id: 'notif-2',
        title: 'Barang Temuan Baru di Sekitarmu',
        sender: 'Perpustakaan Pusat • Ketintang',
        message:
            'Mahasiswa melaporkan penemuan "Kunci motor Honda" di meja baca lantai 1. Ketuk untuk memeriksa...',
        targetItemTitle: 'Kunci motor Honda',
        targetLocation: 'Stasiun Ketintang',
        category: NotificationPaletteCategory.campusInfo,
        timeAgo: '45 menit lalu',
        timeSection: 'HARI INI',
        icon: Icons.inventory_2_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFF2563EB).withValues(alpha: 0.10),
        isRead: false,
      ),
      PaletteNotificationItem(
        id: 'notif-3',
        title: 'Pengumuman Pos Satpam Utama',
        sender: 'Pos Satpam UNESA Ketintang',
        message:
            'Ditemukan tas ransel laptop hitam di Gazebo Fakultas Teknik. Bagi pemilik silakan mengambil ke Pos Barat.',
        targetItemTitle: 'Tas laptop hitam',
        targetLocation: 'Gazebo FT UNESA',
        category: NotificationPaletteCategory.campusInfo,
        timeAgo: '2 jam lalu',
        timeSection: 'HARI INI',
        icon: Icons.campaign_rounded,
        iconColor: AppColors.coral500,
        iconBg: AppColors.coral500.withValues(alpha: 0.12),
        isRead: false,
      ),
      PaletteNotificationItem(
        id: 'notif-4',
        title: 'Pengingat Masa Aktif Laporan',
        sender: 'Sistem FindIT Kampus',
        message:
            'Laporan "Dompet kulit hitam" sudah aktif 2 hari. Sudahkah barangmu kembali? Ketuk untuk memperbarui status.',
        targetItemTitle: 'Dompet kulit hitam',
        targetLocation: 'Gedung Perkuliahan, Lt. 2',
        category: NotificationPaletteCategory.myReports,
        timeAgo: 'Kemarin, 14.15',
        timeSection: 'KEMARIN',
        icon: Icons.access_time_filled_rounded,
        iconColor: const Color(0xFFD97706),
        iconBg: const Color(0xFFD97706).withValues(alpha: 0.12),
        isRead: true,
      ),
      PaletteNotificationItem(
        id: 'notif-5',
        title: 'Laporan Ditandai Selesai',
        sender: 'Sistem FindIT Kampus',
        message:
            'Laporan temuan "Kacamata hitam frame bulat" telah berhasil diserahterimakan kepada pemiliknya.',
        targetItemTitle: 'Kacamata hitam frame bulat',
        targetLocation: 'Perpustakaan Lt. 1',
        category: NotificationPaletteCategory.myReports,
        timeAgo: '4 hari lalu',
        timeSection: 'PEKAN LALU',
        icon: Icons.task_alt_rounded,
        iconColor: const Color(0xFF16A34A),
        iconBg: const Color(0xFF16A34A).withValues(alpha: 0.12),
        isRead: true,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<PaletteNotificationItem> get _filteredNotifications {
    final query = _searchQuery.trim().toLowerCase();

    return _notifications.where((item) {
      // Filter Kategori
      if (_selectedFilter == NotificationPaletteCategory.myReports &&
          item.category != NotificationPaletteCategory.myReports) {
        return false;
      }
      if (_selectedFilter == NotificationPaletteCategory.campusInfo &&
          item.category != NotificationPaletteCategory.campusInfo) {
        return false;
      }

      // Filter Query Pencarian
      if (query.isNotEmpty) {
        final matches = item.title.toLowerCase().contains(query) ||
            item.sender.toLowerCase().contains(query) ||
            item.message.toLowerCase().contains(query) ||
            item.targetItemTitle.toLowerCase().contains(query);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    AppToast.success(
      context,
      title: 'Pemberitahuan Dibaca',
      message: 'Semua notifikasi berhasil ditandai sudah dibaca.',
    );
  }

  void _handleItemTap(PaletteNotificationItem item) {
    setState(() {
      item.isRead = true;
      if (_expandedItemId == item.id) {
        _expandedItemId = null;
      } else {
        _expandedItemId = item.id;
      }
    });
  }

  void _openItemDetail(PaletteNotificationItem item) {
    setState(() {
      item.isRead = true;
    });

    final unread = _unreadCount;
    // Tutup modal
    Navigator.pop(context, unread);

    // Navigasi ke Halaman Ditemukan jika dibuka dari halaman lain
    if (!widget.isAlreadyOnFoundScreen) {
      final nav = FindITCampusApp.navigatorKey.currentState;
      if (nav != null) {
        nav.push(
          SmoothPageRoute(child: const FoundScreen()),
        );
      }
    }

    // Tampilkan Toast Stack sesuai Status Lifecycle
    final isCompleted = item.id == 'notif-5';
    final isBroadcast = item.id == 'notif-3';
    final isMyReport = item.id == 'notif-1' || item.id == 'notif-4';

    if (isCompleted) {
      AppToast.info(
        null,
        title: 'Status: Sudah Selesai',
        message:
            'Laporan "${item.targetItemTitle}" telah diserahterimakan ke pemilik sah dan diarsipkan dari feed aktif.',
      );
    } else if (isBroadcast) {
      AppToast.info(
        null,
        title: 'Pos Satpam Kampus',
        message:
            'Barang temuan "${item.targetItemTitle}" siap diambil di ${item.targetLocation}.',
      );
    } else if (isMyReport) {
      AppToast.success(
        null,
        title: 'Laporan Civitas Aktif',
        message:
            'Laporan "${item.targetItemTitle}" kamu sedang aktif dipantau di sistem kampus.',
      );
    } else {
      AppToast.success(
        null,
        title: 'Barang Temuan Aktif',
        message:
            'Menampilkan rincian temuan: "${item.targetItemTitle}" (${item.targetLocation}).',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final filtered = _filteredNotifications;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context, _unreadCount),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Center(
          child: GestureDetector(
            // Mencegah klik di dalam kartu dialog agar tidak menutup dialog
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: media.size.height * 0.80,
                  maxWidth: 440, // Lebar ideal mobile/tablet
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  // Apple Translucent Glass Surface
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12312E).withValues(alpha: 0.20),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: const Color(0xFF12312E).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Search Bar & Header Row (Motion.dev Palette Header)
                      _buildPaletteSearchHeader(),

                      // 2. Filter Pills & Tandai Dibaca Row
                      _buildFilterRow(),

                      const Divider(height: 1, color: Color(0xFFE8EFEA)),

                      // 3. Scrollable Notification List
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : _buildNotificationList(filtered),
                      ),

                      // 4. Command Palette Footer Bar
                      _buildPaletteFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. SEARCH HEADER COMMAND PALETTE
  // ===========================================================================
  Widget _buildPaletteSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
      ),
      child: Row(
        children: [
          // Search Icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF17695D).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 18,
              color: Color(0xFF17695D),
            ),
          ),
          const SizedBox(width: 10),

          // Search Input
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari notifikasi...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPlaceholder,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // Unread Pill Badge (Jika ada yang belum dibaca)
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.coral500,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount Baru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

          // Close Button
          IconButton(
            onPressed: () => Navigator.pop(context, _unreadCount),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. FILTER ROW & QUICK ACTION
  // ===========================================================================
  Widget _buildFilterRow() {
    final filters = [
      {'label': 'Semua', 'category': NotificationPaletteCategory.all},
      {'label': 'Laporanmu', 'category': NotificationPaletteCategory.myReports},
      {'label': 'Info Kampus', 'category': NotificationPaletteCategory.campusInfo},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: Colors.white.withValues(alpha: 0.65),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Pills
          Row(
            children: List.generate(filters.length, (idx) {
              final item = filters[idx];
              final isSelected = _selectedFilter == item['category'];
              final isPressed = _pressedFilterIndex == idx;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressedFilterIndex = idx),
                  onTapUp: (_) {
                    setState(() {
                      _pressedFilterIndex = null;
                      _selectedFilter =
                          item['category'] as NotificationPaletteCategory;
                    });
                  },
                  onTapCancel: () =>
                      setState(() => _pressedFilterIndex = null),
                  child: AnimatedScale(
                    scale: isPressed ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF17695D)
                            : const Color(0xFF17695D).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF17695D),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Action Tandai Semua Dibaca
          if (_unreadCount > 0)
            GestureDetector(
              onTapDown: (_) => setState(() => _isMarkAllPressed = true),
              onTapUp: (_) {
                setState(() => _isMarkAllPressed = false);
                _markAllAsRead();
              },
              onTapCancel: () => setState(() => _isMarkAllPressed = false),
              child: AnimatedScale(
                scale: _isMarkAllPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    const Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: Color(0xFF17695D),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Tandai dibaca',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17695D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. NOTIFICATION LIST DENGAN TIMELINE GROUPING
  // ===========================================================================
  Widget _buildNotificationList(List<PaletteNotificationItem> items) {
    // Grouping berdasarkan timeSection (HARI INI, KEMARIN, PEKAN LALU)
    final Map<String, List<PaletteNotificationItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.timeSection, () => []).add(item);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: grouped.keys.length,
      itemBuilder: (context, sectionIdx) {
        final sectionName = grouped.keys.elementAt(sectionIdx);
        final sectionItems = grouped[sectionName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
              child: Text(
                sectionName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.slate600,
                ),
              ),
            ),

            // Section Items
            ...sectionItems.map((item) {
              final itemIndex = items.indexOf(item);
              final isPressed = _pressedItemIndex == itemIndex;
              final isExpanded = _expandedItemId == item.id;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) =>
                    setState(() => _pressedItemIndex = itemIndex),
                onTapCancel: () =>
                    setState(() => _pressedItemIndex = null),
                onTap: () {
                  setState(() => _pressedItemIndex = null);
                  _handleItemTap(item);
                },
                child: AnimatedScale(
                  scale: isPressed ? 0.98 : 1.0,
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPressed
                          ? const Color(0xFF17695D).withValues(alpha: 0.08)
                          : (isExpanded
                              ? const Color(0xFF17695D).withValues(alpha: 0.05)
                              : (item.isRead
                                  ? Colors.white.withValues(alpha: 0.60)
                                  : Colors.white)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isExpanded
                            ? const Color(0xFF17695D).withValues(alpha: 0.35)
                            : (!item.isRead
                                ? const Color(0xFF17695D).withValues(alpha: 0.20)
                                : const Color(0xFF12312E).withValues(alpha: 0.06)),
                        width: isExpanded ? 1.2 : 1,
                      ),
                      boxShadow: [
                        if (!item.isRead || isExpanded)
                          BoxShadow(
                            color:
                                const Color(0xFF17695D).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leading Icon Circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: item.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.timeAgo,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      width: 6.5,
                                      height: 6.5,
                                      decoration: const BoxDecoration(
                                        color: AppColors.coral500,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 4),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.slate600,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),

                              // Sender Name
                              Text(
                                item.sender,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF17695D),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Message Snippet / Full Text saat Expanded
                              Text(
                                item.message,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                                maxLines: isExpanded ? null : 2,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Target Item Chip Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF17695D)
                                      .withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 11,
                                      color: Color(0xFF17695D),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${item.targetItemTitle} • ${item.targetLocation}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF17695D),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tombol Aksi saat Card Diklik / Expanded
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _openItemDetail(item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF17695D),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Buka Laporan Terkait',
                                              style: GoogleFonts
                                                  .plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // EMPTY STATE (Saat Filter / Search Kosong)
  // ===========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF17695D).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 26,
                color: Color(0xFF17695D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tidak ada notifikasi ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ganti kata kunci pencarian atau pilih filter kategori lain.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. COMMAND PALETTE FOOTER (Mobile Status Hint - Tanpa Tombol Silang Ganda)
  // ===========================================================================
  Widget _buildPaletteFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        border: const Border(
          top: BorderSide(color: Color(0xFFE8EFEA), width: 1),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app_outlined,
              size: 13,
              color: Color(0xFF17695D),
            ),
            const SizedBox(width: 5),
            Text(
              'Ketuk notifikasi untuk baca detail · Ketuk luar untuk menutup',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

