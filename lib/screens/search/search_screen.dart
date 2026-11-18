import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/smooth_page_route.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/item_card.dart';
import '../../widgets/status_chip.dart';
import '../found/found_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_report_screen.dart';
import '../detail/detail_screen.dart';
import '../../models/report_item_model.dart';
import '../../services/report_service.dart';

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

  // State pencarian live Firestore
  List<ReportItemModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

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
    _searchController.addListener(_onSearchChanged);
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _performSearch(widget.initialQuery!.trim());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    _debounceTimer?.cancel();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(q);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final results = await ReportService.searchReports(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final isQueryEmpty = query.isEmpty;

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

                // Body Content berdasarkan State (Typing, Loading, Results, atau Empty)
                Expanded(
                  child: ScrollConfiguration(
                    behavior:
                        const ScrollBehavior().copyWith(scrollbars: false),
                    child: RepaintBoundary(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isQueryEmpty)
                              _buildTypingState()
                            else if (_isSearching)
                              _buildLoadingState()
                            else if (_searchResults.isNotEmpty)
                              _buildResultsState(_searchResults, query)
                            else
                              _buildEmptyState(query),

                            // Spacer bawah agar konten tidak tertutup bottom navbar
                            const SizedBox(height: 120),
                          ],
                        ),
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    SmoothPageRoute(child: const FoundScreen()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    SmoothPageRoute(child: const ProfileScreen()),
                  ).then((_) {
                    if (mounted) {
                      setState(() => _currentNavIndex = 1);
                    }
                  });
                } else {
                  setState(() => _currentNavIndex = index);
                }
              },
              onPostTap: () {
                Navigator.push<Map<String, dynamic>>(
                  context,
                  SmoothPageRoute(
                    child: const PostReportScreen(initialType: ReportType.lost),
                  ),
                ).then((newReport) {
                  if (newReport != null && mounted) {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _performSearch(query);
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
                      _searchController.clear();
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

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF17695D),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. STATE 2: HASIL PENCARIAN (Figma Node 181:2559)
  // ===========================================================================
  Widget _buildResultsState(List<ReportItemModel> results, String query) {
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
          final isLost = item.isLost;
          return ItemCard(
            title: item.title,
            location: '${item.location} • ${item.timeAgo}',
            timeAgo: item.timeAgo,
            status: item.isLost ? ReportStatus.lost : ReportStatus.found,
            imageUrl: item.imageUrl,
            imageAsset: item.imageAsset,
            snippet: item.description,
            onTap: () {
              if (item.id.isNotEmpty) {
                ReportService.incrementViewCount(item.id);
              }
              if (isLost) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(report: item),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoundScreen(),
                  ),
                );
              }
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
        padding: const EdgeInsets.only(top: 120),
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
                Navigator.popUntil(context, (route) => route.isFirst);
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
