import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/item_card.dart';
import '../../widgets/location_command_palette.dart';
import '../../widgets/notification_command_palette.dart';
import '../../widgets/app_toast_stack.dart';
import '../../widgets/status_chip.dart';
import '../search/search_screen.dart';
import '../found/found_screen.dart';
import '../profile/profile_screen.dart';

/// Halaman Beranda (Home / Default & Home / Filter Active).
/// Implementasi presisi 1:1 sesuai Figma Node 181:2788 & Node 181:2652.
/// - Filter kategori bekerja in-place di halaman Beranda (tidak redirect ke Search)
/// - Menampilkan 'Laporan Kamu' & feed lengkap saat tab 'Semua' aktif
/// - Menampilkan item terfilter saat kategori (Dompet, HP, Kunci, dll.) dipilih
/// - Feedback tactile spring scale & dynamic shadow depth pada setiap interaksi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _selectedCategoryIndex = 0;
  int? _pressedCategoryIndex;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // State untuk micro-interactions
  bool _isBellPressed = false;
  int _unreadNotificationCount = 3;
  bool _isLocationPressed = false;
  bool _isSortPressed = false;
  bool _isSortLatest = true;
  bool _isMyReportPressed = false;
  bool _isManagePressed = false;

  // Lokasi aktif yang dipilih melalui Command Palette
  String _currentLocation = 'UNESA Kampus Ketintang, Surabaya';

  final List<String> _categories = [
    'Semua',
    'Dompet',
    'Elektronik',
    'HP',
    'Kunci',
    'KTM',
    'Lainnya',
  ];

  // Database mock laporan feed kampus
  final List<Map<String, dynamic>> _campusFeedItems = [
    {
      'title': 'Dompet kulit hitam',
      'location': 'Gedung Perkuliahan • 2 jam lalu',
      'date': '12 Okt 2026',
      'category': 'Dompet',
      'timeAgo': '2 jam lalu',
      'status': ReportStatus.lost,
      'imageAsset': 'assets/images/dompet_kulit.jpg',
      'description':
          'Dompet hitam berisi KTM dan SIM. Terakhir terlihat di dekat tangga lantai 2.',
      'reporterName': 'Rizky',
      'reporterRole': 'Mahasiswa · SI 2024',
    },
    {
      'title': 'Dompet kartu coklat',
      'location': 'Kantin Barat • 1 hari lalu',
      'date': '11 Okt 2026',
      'category': 'Dompet',
      'timeAgo': '1 hari lalu',
      'status': ReportStatus.found,
      'icon': Icons.inventory_2_outlined,
      'snippet': 'Dompet kartu warna coklat muda tertinggal di kasir',
      'description':
          'Dompet kartu warna coklat muda tertinggal di kasir kantin barat.',
      'reporterName': 'Siti',
      'reporterRole': 'Mahasiswa · SI 2023',
    },
    {
      'title': 'Kunci motor Honda',
      'location': 'Stasiun UI, Beji',
      'date': '29 Okt 2026',
      'category': 'Kunci',
      'timeAgo': '12 menit lalu',
      'status': ReportStatus.found,
      'imageAsset': 'assets/images/kunci_motor.jpg',
      'snippet': 'Gantungan kunci tali hitam berlogo Honda Vario',
      'description':
          'Gantungan kunci tali hitam berlogo Honda Vario ditemukan di area loket stasiun.',
      'reporterName': 'Ahmad',
      'reporterRole': 'Staff Perpustakaan UI',
    },
    {
      'title': 'Tas laptop hitam',
      'location': 'Gedung Kuliah FISIP',
      'date': '28 Okt 2026',
      'category': 'Elektronik',
      'timeAgo': '45 menit lalu',
      'status': ReportStatus.lost,
      'icon': Icons.inventory_2_outlined,
      'snippet': 'Merk Asus ROG hitam, tertinggal di kursi baris ke-3',
      'description':
          'Merk Asus ROG hitam, tertinggal di kursi baris ke-3 lantai 1 FISIP.',
      'reporterName': 'Farhan',
      'reporterRole': 'Mahasiswa · FISIP 2024',
    },
    {
      'title': 'Ponsel pintar merah',
      'location': 'Kantin FISIP',
      'date': '28 Okt 2026',
      'category': 'HP',
      'timeAgo': '30 menit lalu',
      'status': ReportStatus.lost,
      'icon': Icons.inventory_2_outlined,
      'snippet': 'Casing transparan dengan stiker kucing di belakang',
      'description':
          'Casing transparan dengan stiker kucing di belakang meja kasir kantin.',
      'reporterName': 'Budi',
      'reporterRole': 'Mahasiswa · FMIPA 2024',
    },
    {
      'title': 'Kacamata hitam frame bulat',
      'location': 'Perpustakaan UI Lt. 1',
      'date': '28 Okt 2026',
      'category': 'Lainnya',
      'timeAgo': '1 jam lalu',
      'status': ReportStatus.found,
      'icon': Icons.inventory_2_outlined,
      'snippet': 'Lensa minus dengan kotak kacamata warna cokelat',
      'description':
          'Lensa minus dengan kotak kacamata warna cokelat di meja baca lantai 1.',
      'reporterName': 'Nadia',
      'reporterRole': 'Mahasiswa · FIB 2023',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _navigateToDetail(String title) {
    AppToast.info(
      context,
      title: 'Detail Barang',
      message: 'Detail "$title" akan dibuka oleh modul Orang 4.',
    );
  }

  Future<void> _navigateToSearch([String? query]) async {
    final result = await Navigator.push<int>(
      context,
      SmoothPageRoute(
        child: SearchScreen(initialQuery: query),
      ),
    );
    // Saat kembali ke halaman HomeScreen, selalu sinkronkan tab aktif kembali ke Home (0)
    if (mounted) {
      setState(() {
        _currentNavIndex = result ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
      body: Stack(
        fit: StackFit.expand, // Memastikan Stack selalu memenuhi seluruh layar (navbar tetap fixed di bawah)
        children: [
          // Konten Scrollable
          SafeArea(
            bottom: false,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                physics: const BouncingScrollPhysics(),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildCategoryFilters(),
                  const SizedBox(height: 22),

                  // Jika filter "Semua" aktif (default view):
                  if (_selectedCategoryIndex == 0) ...[
                    _buildMyReportsSection(),
                    const SizedBox(height: 14),
                    _buildCampusImpactBar(),
                    const SizedBox(height: 20),
                    _buildCampusFeedSection(),
                  ] else ...[
                    // Jika kategori spesifik dipilih (Home / Filter Active - Figma 181:2652):
                    _buildFilteredSection(),
                  ],

                  // Spacer bawah disesuaikan agar kartu terakhir tetap terbaca saat mentok di bawah dan blur saat scroll
                  const SizedBox(height: 118),
                ],
              ),
            ),
          ),
        ),

          // Floating Capsule Bottom Navigation Bar (Elevated Floating FAB)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentNavIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  setState(() => _currentNavIndex = 0);
                } else if (index == 1) {
                  _navigateToSearch();
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    SmoothPageRoute(child: const FoundScreen()),
                  ).then((_) {
                    if (mounted) {
                      setState(() => _currentNavIndex = 0);
                    }
                  });
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    SmoothPageRoute(child: const ProfileScreen()),
                  ).then((_) {
                    if (mounted) {
                      setState(() => _currentNavIndex = 0);
                    }
                  });
                } else {
                  setState(() => _currentNavIndex = index);
                }
              },
              onPostTap: () {
                AppToast.info(
                  context,
                  title: 'Formulir Laporan',
                  message: 'Buka form pembuatan laporan baru.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER (Sapaan, Nama, Dropdown Lokasi Interaktif, Bell Notification)
  // ===========================================================================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF12312E),
                ),
              ),
              Text(
                'Nama',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  color: const Color(0xFF12312E),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),

              // Dropdown Lokasi dengan Tactile Touch Response (Membuka Command Palette)
              GestureDetector(
                onTapDown: (_) => setState(() => _isLocationPressed = true),
                onTapUp: (_) async {
                  setState(() => _isLocationPressed = false);
                  final selected = await showLocationCommandPalette(
                    context,
                    currentLocation: _currentLocation,
                  );
                  if (selected != null && mounted) {
                    setState(() {
                      _currentLocation = selected;
                    });
                    AppToast.info(
                      context,
                      title: 'Lokasi Kampus',
                      message: 'Lokasi aktif diubah ke "$selected".',
                    );
                  }
                },
                onTapCancel: () => setState(() => _isLocationPressed = false),
                child: AnimatedScale(
                  scale: _isLocationPressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF17695D),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _currentLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5E6E6A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: Color(0xFF5E6E6A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notifikasi Bell Circle (49x49) dengan Tactile Bounce & Badge Dot
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isBellPressed = true),
          onTapCancel: () => setState(() => _isBellPressed = false),
          onTap: () async {
            setState(() => _isBellPressed = false);
            final remainingUnread = await showNotificationCommandPalette(
              context,
              initialUnreadCount: _unreadNotificationCount,
            );
            if (mounted && remainingUnread != null) {
              setState(() {
                _unreadNotificationCount = remainingUnread;
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
                  if (_unreadNotificationCount > 0)
                    Positioned(
                      top: 13,
                      right: 14,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.coral500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
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
  // 2. SEARCH BAR (Tap to SearchScreen)
  // ===========================================================================
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => _navigateToSearch(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: const Color(0xFFDEE8E2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12312E).withValues(alpha: 0.04),
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF5E6E6A),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari nama barang...',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF5E6E6A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. FILTER KATEGORI (Chips yang memfilter in-place di Beranda)
  // ===========================================================================
  Widget _buildCategoryFilters() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          final isPressed = _pressedCategoryIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressedCategoryIndex = index),
              onTapUp: (_) {
                setState(() {
                  _pressedCategoryIndex = null;
                  _selectedCategoryIndex = index;
                });
              },
              onTapCancel: () => setState(() => _pressedCategoryIndex = null),
              child: AnimatedScale(
                scale: isPressed ? 0.93 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF12312E) : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF12312E)
                          : const Color(0xFFDEE8E2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF12312E).withValues(alpha: 0.22)
                            : const Color(0xFF12312E).withValues(alpha: 0.04),
                        offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
                        blurRadius: isSelected ? 10 : 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF12312E),
                    ),
                    child: Text(_categories[index]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
  }


  // ===========================================================================
  // EMPTY STATE (Figma Node 181:2639 - Home / Empty)
  // ===========================================================================
  Widget _buildEmptyHomeState({String? category}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cardboard Box Illustration (Node 181:2647)
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEFE9DF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 38,
                  color: Color(0xFF9E7B58),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Judul Belum ada laporan terbaru (Node 181:2648)
            Text(
              category != null
                  ? 'Belum ada laporan untuk "$category"'
                  : 'Belum ada laporan terbaru',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12312E),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle Penjelasan (Node 181:2649)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                category != null
                    ? 'Belum ada laporan di kategori ini. Jadilah yang pertama melaporkan barang hilang atau ditemukan!'
                    : 'Jadilah yang pertama melaporkan barang hilang atau ditemukan di kampus!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5E6E6A),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Tombol "+ Buat Laporan" (Node 181:2650)
            GestureDetector(
              onTap: () {
                AppToast.info(
                  context,
                  title: 'Formulir Laporan',
                  message: 'Buka form pembuatan laporan baru.',
                );
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF17695D),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF17695D).withValues(alpha: 0.35),
                      offset: const Offset(0, 4),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Buat Laporan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
  }

  // ===========================================================================
  // 4. SECTION FILTER AKTIF (Figma Node 181:2652 - Tampil saat Kategori Dipilih)
  // ===========================================================================
  Widget _buildFilteredSection() {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final filteredItems = _campusFeedItems.where((item) {
      final itemCat = (item['category'] as String).toLowerCase();
      final selCat = selectedCategory.toLowerCase();
      if (selCat == 'elektronik') {
        return itemCat == 'elektronik' || itemCat == 'hp';
      }
      return itemCat == selCat;
    }).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyHomeState(category: selectedCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredItems.map((item) {
        return ItemCard(
          title: item['title'] as String,
          location: item['location'] as String,
          timeAgo: item['timeAgo'] as String,
          status: item['status'] as ReportStatus,
          imageAsset: item['imageAsset'] as String?,
          icon: item['icon'] as IconData?,
          snippet: item['snippet'] as String?,
          onTap: () {
            _navigateToDetail(item['title'] as String);
          },
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // CAMPUS IMPACT BAR (Social Proof / Micro Activity)
  // ===========================================================================
  Widget _buildCampusImpactBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD0E6DE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF17695D).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.volunteer_activism_rounded,
                size: 15,
                color: Color(0xFF17695D),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF12312E),
                  height: 1.3,
                ),
                children: [
                  const TextSpan(
                    text: '42 Laporan Aktif',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: '  •  ',
                    style: TextStyle(
                      color: const Color(0xFF17695D).withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: '28 barang kembali minggu ini',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF17695D),
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
  // 5. SECTION "Laporan Kamu" (Apple Compact Split Hero Card)
  // ===========================================================================
  Widget _buildMyReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Seksi + Live Badge 1 Aktif
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Laporan Kamu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: const Color(0xFF12312E),
              ),
            ),
            // Pill status "1 Aktif"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF17695D),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '1 Aktif',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17695D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Apple Compact Split Hero Card (~170px)
        GestureDetector(
          onTapDown: (_) => setState(() => _isMyReportPressed = true),
          onTapUp: (_) {
            setState(() => _isMyReportPressed = false);
            _navigateToDetail('Dompet kulit hitam');
          },
          onTapCancel: () => setState(() => _isMyReportPressed = false),
          child: AnimatedScale(
            scale: _isMyReportPressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isMyReportPressed
                      ? const Color(0xFF17695D).withValues(alpha: 0.3)
                      : const Color(0xFFDEE8E2).withValues(alpha: 0.75),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12312E).withValues(
                      alpha: _isMyReportPressed ? 0.03 : 0.07,
                    ),
                    offset: _isMyReportPressed
                        ? const Offset(0, 2)
                        : const Offset(0, 5),
                    blurRadius: _isMyReportPressed ? 6 : 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Upper Split Section
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Thumbnail (92x92)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 92,
                            height: 92,
                            color: const Color(0xFFFFD9CC),
                            child: Image.asset(
                              'assets/images/dompet_kulit.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.wallet_rounded,
                                    size: 36,
                                    color: Color(0xFF6B210F),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Right Content Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status & "Baru saja" indicator
                              Row(
                                children: [
                                  const StatusChip.lost(),
                                  const Spacer(),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF17695D),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Baru saja',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF17695D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Judul Barang
                              Text(
                                'Dompet kulit hitam',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF12312E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Lokasi dengan Apple Teal Location Pin
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 13,
                                    color: Color(0xFF17695D),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Gedung Perkuliahan, Lt. 2',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4F625E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Social Proof micro stats
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility_outlined,
                                    size: 12,
                                    color: Color(0xFF7D8E89),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '48x dilihat',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF7D8E89),
                                    ),
                                  ),
                                  Text(
                                    '  •  ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF7D8E89),
                                    ),
                                  ),
                                  Text(
                                    '1 respon',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF17695D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: const Color(0xFFDEE8E2).withValues(alpha: 0.6),
                  ),

                  // Bottom Action Strip
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 13,
                              color: Color(0xFF17695D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Terlihat oleh civitas kampus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5E6E6A),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) =>
                              setState(() => _isManagePressed = true),
                          onTapUp: (_) {
                            setState(() => _isManagePressed = false);
                            _navigateToDetail('Dompet kulit hitam');
                          },
                          onTapCancel: () =>
                              setState(() => _isManagePressed = false),
                          child: AnimatedScale(
                            scale: _isManagePressed ? 0.94 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOutCubic,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Kelola laporan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF17695D),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                AnimatedSlide(
                                  offset:
                                      Offset(_isManagePressed ? 0.25 : 0.0, 0),
                                  duration: const Duration(milliseconds: 140),
                                  curve: Curves.easeOutCubic,
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 15,
                                    color: Color(0xFF17695D),
                                  ),
                                ),
                              ],
                            ),
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
      ],
    );
  }

  // ===========================================================================
  // 6. SECTION "Terbaru di kampus" (Feed Lengkap - Khusus Tab 'Semua')
  // ===========================================================================
  Widget _buildCampusFeedSection() {
    // List item feed kampus (mengecualikan 'Dompet kulit hitam' yang merupakan laporan milik pengguna sendiri)
    final feedItems = _campusFeedItems
        .where((item) => item['title'] != 'Dompet kulit hitam')
        .toList();

    // Sorting dinamis: jika _isSortLatest true (terbaru duluan), jika false dibalik
    final displayedItems =
        _isSortLatest ? feedItems : feedItems.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Seksi + Tombol Sort Interaktif (Gestalt Law of Proximity)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terbaru di kampus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: const Color(0xFF12312E),
              ),
            ),
            GestureDetector(
              onTapDown: (_) => setState(() => _isSortPressed = true),
              onTapUp: (_) {
                setState(() {
                  _isSortPressed = false;
                  _isSortLatest = !_isSortLatest;
                });
                AppToast.info(
                  context,
                  title: 'Urutan Feed',
                  message: _isSortLatest
                      ? 'Menampilkan laporan terbaru.'
                      : 'Menampilkan laporan terlama.',
                );
              },
              onTapCancel: () => setState(() => _isSortPressed = false),
              child: AnimatedScale(
                scale: _isSortPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOutCubic,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17695D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF17695D).withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 5),
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
        ),
        const SizedBox(height: 12),

        // List Kartu Feed Kampus
        ...displayedItems.map((item) {
          return ItemCard(
            title: item['title'] as String,
            location: item['location'] as String,
            timeAgo: item['timeAgo'] as String,
            status: item['status'] as ReportStatus,
            imageAsset: item['imageAsset'] as String?,
            icon: item['icon'] as IconData?,
            snippet: item['snippet'] as String?,
            onTap: () {
              _navigateToDetail(item['title'] as String);
            },
          );
        }),
      ],
    );
  }
}
