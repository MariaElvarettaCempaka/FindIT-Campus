import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/item_card.dart';
import '../../widgets/status_chip.dart';
import '../detail/detail_screen.dart';

/// Halaman Pencarian Interaktif (Figma Node 181:2536, 181:2559, & 181:2664).
/// Menggabungkan 3 state visual dinamis:
/// 1. Search / Typing: Saran pencarian & riwayat chip pencarian terakhir
/// 2. Search / Results: Daftar kartu hasil pencarian dengan counter hasil
/// 3. Search / Empty: Tampilan ramah ketika kata kunci tidak ditemukan
class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  int _currentNavIndex = 1; // Tab 'Hilang' / Search
  bool _isBackPressed = false;

  // Data mock feed untuk pencarian kampus
  final List<Map<String, dynamic>> _allItems = [
    {
      'title': 'Dompet kulit hitam',
      'location': 'Gedung Perkuliahan, Lt. 2',
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
      'location': 'Kantin Barat • Meja 3',
      'date': '11 Okt 2026',
      'category': 'Dompet',
      'timeAgo': '1 hari lalu',
      'status': ReportStatus.found,
      'icon': Icons.inventory_2_outlined,
      'description':
          'Dompet kartu warna coklat muda tertinggal di kursi kantin barat.',
      'reporterName': 'Siti',
      'reporterRole': 'Mahasiswa · SI 2023',
    },
    {
      'title': 'Dompet lipat Eiger',
      'location': 'Lab Komputer 3',
      'date': '10 Okt 2026',
      'category': 'Dompet',
      'timeAgo': '3 hari lalu',
      'status': ReportStatus.lost,
      'icon': Icons.inventory_2_outlined,
      'description':
          'Dompet lipat merk Eiger warna abu-abu hitam, ada kartu flash.',
      'reporterName': 'Dimas',
      'reporterRole': 'Mahasiswa · TI 2022',
    },
    {
      'title': 'Kunci motor Honda',
      'location': 'Stasiun UI, Beji',
      'date': '29 Okt 2026',
      'category': 'Elektronik',
      'timeAgo': '12 menit lalu',
      'status': ReportStatus.found,
      'imageAsset': 'assets/images/kunci_motor.jpg',
      'description':
          'Gantungan kunci tali hitam berlogo Honda Vario ditemukan di area loket.',
      'reporterName': 'Ahmad',
      'reporterRole': 'Staff Perpustakaan',
    },
    {
      'title': 'Tas laptop hitam',
      'location': 'Gedung Kuliah FISIP',
      'date': '28 Okt 2026',
      'category': 'Elektronik',
      'timeAgo': '45 menit lalu',
      'status': ReportStatus.lost,
      'icon': Icons.inventory_2_outlined,
      'description':
          'Merk Asus ROG hitam, tertinggal di kursi baris ke-3 lantai 1.',
      'reporterName': 'Farhan',
      'reporterRole': 'Mahasiswa · FISIP 2024',
    },
    {
      'title': 'Kacamata hitam frame bulat',
      'location': 'Perpustakaan UI Lt. 1',
      'date': '28 Okt 2026',
      'category': 'Lainnya',
      'timeAgo': '1 jam lalu',
      'status': ReportStatus.found,
      'icon': Icons.inventory_2_outlined,
      'description':
          'Lensa minus dengan kotak kacamata warna cokelat di meja baca.',
      'reporterName': 'Nadia',
      'reporterRole': 'Mahasiswa · FIB 2023',
    },
    {
      'title': 'Ponsel pintar merah',
      'location': 'Kantin FISIP',
      'date': '28 Okt 2026',
      'category': 'Elektronik',
      'timeAgo': '30 menit lalu',
      'status': ReportStatus.lost,
      'icon': Icons.inventory_2_outlined,
      'description':
          'Casing transparan dengan stiker kucing di belakang.',
      'reporterName': 'Budi',
      'reporterRole': 'Mahasiswa · FMIPA 2024',
    },
  ];

  final List<String> _suggestions = [
    'dompet kulit hitam',
    'dompet coklat kartu',
    'dompet wanita panjang',
  ];

  final List<String> _recentSearches = [
    'KTM SI',
    'Kunci Honda',
    'Charger Type C',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
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

  List<Map<String, dynamic>> _getFilteredItems(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];
    return _allItems.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final category = (item['category'] as String).toLowerCase();
      final location = (item['location'] as String).toLowerCase();
      return title.contains(cleanQuery) ||
          category.contains(cleanQuery) ||
          location.contains(cleanQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final isQueryEmpty = query.isEmpty;
    final results = _getFilteredItems(query);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top Header: Tombol Back + Input Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _buildSearchHeader(),
                ),

                const SizedBox(height: 16),

                // Body Content berdasarkan State (Typing, Results, atau Empty)
                Expanded(
                  child: ScrollConfiguration(
                    behavior:
                        const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isQueryEmpty)
                            _buildTypingState()
                          else if (results.isNotEmpty)
                            _buildResultsState(results, query)
                          else
                            _buildEmptyState(query),

                          // Spacer bawah agar konten tidak tertutup bottom navbar
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentNavIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  Navigator.pop(context, 0); // Kembali ke Home
                } else {
                  setState(() => _currentNavIndex = index);
                }
              },
              onPostTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buka form pembuatan laporan baru'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. SEARCH HEADER (Back Button + Search Bar)
  // ===========================================================================
  Widget _buildSearchHeader() {
    final isFocused = _searchFocusNode.hasFocus;

    return Row(
      children: [
        // Tombol Kembali Lingkaran
        GestureDetector(
          onTapDown: (_) => setState(() => _isBackPressed = true),
          onTapUp: (_) {
            setState(() => _isBackPressed = false);
            Navigator.pop(context, 0);
          },
          onTapCancel: () => setState(() => _isBackPressed = false),
          child: AnimatedScale(
            scale: _isBackPressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDEE8E2).withValues(alpha: 0.7),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12312E).withValues(
                      alpha: _isBackPressed ? 0.03 : 0.07,
                    ),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF12312E),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Search Bar Input
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isFocused ? const Color(0xFF17695D) : const Color(0xFFDEE8E2),
                width: isFocused ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFocused
                      ? const Color(0xFF17695D).withValues(alpha: 0.14)
                      : const Color(0xFF12312E).withValues(alpha: 0.04),
                  offset: isFocused ? const Offset(0, 4) : const Offset(0, 2),
                  blurRadius: isFocused ? 14 : 8,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isFocused
                      ? const Color(0xFF17695D)
                      : const Color(0xFF5E6E6A),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF12312E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari barang yang hilang...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF5E6E6A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Color(0xFF8A9A96),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. STATE 1: TYPING / SUGGESTIONS & RECENT (Figma Node 181:2536)
  // ===========================================================================
  Widget _buildTypingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saran pencarian Label
        Text(
          'Saran pencarian',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12312E),
          ),
        ),
        const SizedBox(height: 10),

        // Suggestions Box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDEE8E2).withValues(alpha: 0.7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12312E).withValues(alpha: 0.04),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: List.generate(_suggestions.length, (index) {
              final suggestion = _suggestions[index];
              final isLast = index == _suggestions.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _searchController.text = suggestion;
                        _searchFocusNode.unfocus();
                      },
                      borderRadius: BorderRadius.vertical(
                        top: index == 0 ? const Radius.circular(20) : Radius.zero,
                        bottom: isLast ? const Radius.circular(20) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 16,
                              color: Color(0xFF5E6E6A),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF12312E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEFECE6),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        // Pencarian terakhir Label
        Text(
          'Pencarian terakhir',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12312E),
          ),
        ),
        const SizedBox(height: 12),

        // Chips Pencarian Terakhir
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((tag) {
            return GestureDetector(
              onTap: () {
                _searchController.text = tag;
                _searchFocusNode.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE9DF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12312E),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. STATE 2: HASIL PENCARIAN (Figma Node 181:2559)
  // ===========================================================================
  Widget _buildResultsState(List<Map<String, dynamic>> results, String query) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Counter Hasil
        Text(
          '${results.length} hasil ditemukan untuk "$query"',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5E6E6A),
          ),
        ),
        const SizedBox(height: 14),

        // List Hasil Pencarian
        ...results.map((item) {
          return ItemCard(
            title: item['title'] as String,
            location: item['location'] as String,
            timeAgo: item['timeAgo'] as String,
            status: item['status'] as ReportStatus,
            imageAsset: item['imageAsset'] as String?,
            icon: item['icon'] as IconData?,
            snippet: item['description'] as String?,
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(
                  child: DetailScreen(
                    title: item['title'] as String,
                    status: item['status'] as ReportStatus,
                    timeAgo: item['timeAgo'] as String,
                    location: item['location'] as String,
                    date: item['date'] as String,
                    category: item['category'] as String,
                    description: item['description'] as String,
                    reporterName: item['reporterName'] as String,
                    reporterRole: item['reporterRole'] as String,
                    imageAsset: item['imageAsset'] as String?,
                    icon: item['icon'] as IconData?,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // 4. STATE 3: KOSONG / TIDAK DITEMUKAN (Figma Node 181:2664)
  // ===========================================================================
  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 54,
              color: Color(0xFF8A9A96),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12312E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada laporan yang cocok dengan kata kunci.\nCoba periksa ejaan atau gunakan kata kunci lain.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5E6E6A),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE9DF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF12312E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
