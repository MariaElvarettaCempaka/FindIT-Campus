import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

/// Screen 2, 3, 4: Onboarding (3 slides)
/// Sesuai Figma node 181:1863, 181:1895, 181:1939
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isButtonPressed = false;

  void _onSkipOrLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _onSkipOrLogin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: "Lewati" (hanya muncul di slide 1 & 2; di slide 3 disembunyikan agar fokus ke tombol "Mulai")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                height: 38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < 2)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _onSkipOrLogin,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Lewati',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F7A6B), // Teal
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Middle: PageView (Visual Illustration + Title + Subtitle)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),

            // Bottom Section: Dots Indicator & Tombol Lanjut / Mulai (Selalu di Bawah)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Pill Dots Indicator
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1F7A6B) // Teal aktif
                              : const Color(0xFFCFD9D4), // Dot nonaktif
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Action Button ("Lanjut" / "Mulai") dengan Tactile Spring Feedback (/apple-design)
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isButtonPressed = false);
                      _onNext();
                    },
                    onTapCancel: () => setState(() => _isButtonPressed = false),
                    child: AnimatedScale(
                      scale: _isButtonPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F7A6B), // Teal
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F7A6B).withValues(alpha: 0.28),
                              blurRadius: _isButtonPressed ? 6 : 14,
                              offset: Offset(0, _isButtonPressed ? 2 : 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _currentPage == 2 ? 'Mulai' : 'Lanjut',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SLIDE 1: Laporkan dalam hitungan menit (Figma 181:1863)
  // ===========================================================================
  Widget _buildSlide1() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Area Visual
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 330,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran Blob Peach Belakang
                        Container(
                          width: 280,
                          height: 280,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD9CC), // Blob Peach
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Kartu Form Laporan (Rotated -4 deg)
                        Transform.rotate(
                          angle: -4 * 3.1415926535 / 180,
                          child: Container(
                            width: 226,
                            height: 270,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF12312E).withValues(alpha: 0.14),
                                  blurRadius: 18,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Segmen Hilang / Ditemukan
                                Container(
                                  height: 38,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE8DF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF2603F), // Coral
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Hilang',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Ditemukan',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF5B6E6B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Area Unggah Foto Putus-putus
                                Container(
                                  height: 88,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF8F3),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFF1F7A6B),
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_rounded,
                                        size: 22,
                                        color: Color(0xFF1F7A6B),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Unggah foto barang',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1F7A6B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Placeholder Bar 1
                                Container(
                                  height: 12,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE8DF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Chips Kategori (Dompet, HP, Kunci)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF12312E),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Dompet',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFFBF8F3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDE8DF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'HP',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF12312E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDE8DF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Kunci',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF12312E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // FAB Lingkaran Coral (Ukuran 60x60, Kanan Bawah)
                        Positioned(
                          right: 32,
                          bottom: 12,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2603F), // Coral
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF2603F).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Judul
                Text(
                  'Laporkan dalam hitungan menit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.25,
                    color: const Color(0xFF12312E),
                  ),
                ),
                const SizedBox(height: 12),

                // Deskripsi
                Text(
                  'Unggah foto, pilih kategori, dan tandai lokasi barang yang hilang atau yang kamu temukan di kampus.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                    color: const Color(0xFF5B6E6B),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SLIDE 2: Cari di satu tempat (Figma 181:1895)
  // ===========================================================================
  Widget _buildSlide2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Area Visual
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 330,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Lingkaran Blob Mint Belakang
                        Container(
                          width: 280,
                          height: 280,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCFEFE3), // Mint Blob
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Kolom Cari Pill (Rotated -2 deg)
                        Positioned(
                          top: 24,
                          child: Transform.rotate(
                            angle: -2 * 3.1415926535 / 180,
                            child: Container(
                              width: 266,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFD3E0DA),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF12312E).withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: Color(0xFF12312E),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Dompet',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF12312E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Chip Row (Semua, Dompet, HP, Kunci)
                        Positioned(
                          top: 86,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPillChip('Semua', isSelected: true),
                              const SizedBox(width: 6),
                              _buildPillChip('Dompet', isSelected: false),
                              const SizedBox(width: 6),
                              _buildPillChip('HP', isSelected: false),
                              const SizedBox(width: 6),
                              _buildPillChip('Kunci', isSelected: false),
                            ],
                          ),
                        ),

                        // Kartu 1: Dompet Hilang (Rotated +1.5 deg)
                        Positioned(
                          top: 132,
                          child: Transform.rotate(
                            angle: 1.5 * 3.1415926535 / 180,
                            child: Container(
                              width: 304,
                              height: 72,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF12312E)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Foto Asli Dompet Kulit Hitam (Thumbnail 48x48)
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD9CC), // Peach fallback
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF12312E).withValues(alpha: 0.08),
                                        width: 1.0,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/dompet_hitam_thumb.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(
                                        child: CustomPaint(
                                          size: const Size(26, 26),
                                          painter: _OnboardingWalletIconPainter(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Dompet kulit hitam',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.visible,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF12312E),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Gedung Perkuliahan',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF5B6E6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE0D6), // Hilang
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Hilang',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF9B2C12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Kartu 2: Dompet Ditemukan (Rotated -1.5 deg)
                        Positioned(
                          top: 216,
                          child: Transform.rotate(
                            angle: -1.5 * 3.1415926535 / 180,
                            child: Container(
                              width: 304,
                              height: 72,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF12312E)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Foto Asli Dompet Cokelat (Thumbnail 48x48)
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFBFE9DA), // Mint fallback
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF12312E).withValues(alpha: 0.08),
                                        width: 1.0,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/dompet_cokelat.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(
                                        child: CustomPaint(
                                          size: const Size(26, 26),
                                          painter: _OnboardingWalletIconPainter(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Dompet cokelat',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.visible,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF12312E),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kantin Barat',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF5B6E6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFCFEFE3), // Ditemukan
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Ditemukan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF14573F),
                                      ),
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
                ),
                const SizedBox(height: 24),

                // Judul
                Text(
                  'Cari di satu tempat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.25,
                    color: const Color(0xFF12312E),
                  ),
                ),
                const SizedBox(height: 12),

                // Deskripsi
                Text(
                  'Tidak perlu lagi menggulir grup obrolan. Cari nama barang atau saring berdasarkan kategori seperti dompet, HP, kunci, dan KTM.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                    color: const Color(0xFF5B6E6B),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPillChip(String title, {required bool isSelected}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF12312E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          color: isSelected ? const Color(0xFFFBF8F3) : const Color(0xFF12312E),
        ),
      ),
    );
  }

  // ===========================================================================
  // SLIDE 3: Hubungi lewat WhatsApp (Figma 181:1939)
  // ===========================================================================
  Widget _buildSlide3() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Area Visual
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 330,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Lingkaran Blob Kuning Belakang
                        Container(
                          width: 280,
                          height: 280,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE8A3), // Yellow Blob
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Kartu Detail Barang (Rotated +3 deg)
                        Transform.rotate(
                          angle: 3 * 3.1415926535 / 180,
                          child: Container(
                            width: 218,
                            height: 288,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F3),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF12312E).withValues(alpha: 0.16),
                                  blurRadius: 28,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Kartu Peach (110px) dengan Foto Asli Dompet Kulit Hitam
                                Container(
                                  height: 110,
                                  width: double.infinity,
                                  color: const Color(0xFFFFD9CC), // Peach header
                                  child: Image.asset(
                                    'assets/images/dompet_kulit.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Center(
                                      child: CustomPaint(
                                        size: const Size(54, 54),
                                        painter: _OnboardingWalletIconPainter(
                                          strokeWidth: 3.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Isi Detail
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE0D6),
                                          borderRadius: BorderRadius.circular(11),
                                        ),
                                        child: Text(
                                          'Hilang',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF9B2C12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Dompet kulit hitam',
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF12312E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Gedung Perkuliahan · 12 Okt',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF5B6E6B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Tombol WhatsApp Hijau
                                      Container(
                                        height: 44,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF12753D), // WhatsApp Green
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Hubungi via WhatsApp',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
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

                        // Chip "Wajib login" (Rotated -3 deg, Kiri Atas Kartu)
                        Positioned(
                          left: 46,
                          top: 48,
                          child: Transform.rotate(
                            angle: -3 * 3.1415926535 / 180,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF12312E).withValues(alpha: 0.16),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock_rounded,
                                    size: 15,
                                    color: Color(0xFF1F7A6B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Wajib login',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F7A6B),
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
                ),
                const SizedBox(height: 24),

                // Judul
                Text(
                  'Hubungi lewat WhatsApp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.25,
                    color: const Color(0xFF12312E),
                  ),
                ),
                const SizedBox(height: 12),

                // Deskripsi
                Text(
                  'Temui pemilik atau penemunya langsung, lalu serah terima barang di kampus. Nomor hanya terlihat setelah kamu masuk.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                    color: const Color(0xFF5B6E6B),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Painter Dompet Bergaya Apple Wallet / Leather Bifold (/apple-design, /ui-taste)
/// Menggantikan ikon garis generik material dengan proporsi elegan, card slot, dan hardware clasp
class _OnboardingWalletIconPainter extends CustomPainter {
  final double strokeWidth;

  const _OnboardingWalletIconPainter({this.strokeWidth = 2.2});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width * 0.85;
    final h = size.height * 0.62;

    // 1. Body Dompet Utama
    final walletRect = Rect.fromCenter(
      center: center + Offset(0, size.height * 0.03),
      width: w,
      height: h,
    );
    final walletRRect = RRect.fromRectAndRadius(
      walletRect,
      Radius.circular(size.width * 0.16),
    );
    canvas.drawRRect(walletRRect, strokePaint);

    // 2. Garis Lipatan / Slot Kartu
    final slotPath = Path()
      ..moveTo(walletRect.left + w * 0.1, walletRect.top + h * 0.32)
      ..cubicTo(
        walletRect.left + w * 0.35,
        walletRect.top + h * 0.40,
        walletRect.right - w * 0.35,
        walletRect.top + h * 0.40,
        walletRect.right - w * 0.1,
        walletRect.top + h * 0.32,
      );
    final slotPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(slotPath, slotPaint);

    // 3. Clasp Lid / Tab Kancing di Kanan
    final claspWidth = w * 0.24;
    final claspHeight = h * 0.42;
    final claspRect = Rect.fromCenter(
      center: Offset(walletRect.right - claspWidth * 0.35, walletRect.center.dy + 1),
      width: claspWidth,
      height: claspHeight,
    );
    final claspRRect = RRect.fromRectAndRadius(
      claspRect,
      Radius.circular(claspWidth * 0.35),
    );

    // Fill pembersih agar tidak tembus garis body
    final claspBg = Paint()
      ..color = const Color(0xFFFFD9CC)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(claspRRect, claspBg);
    canvas.drawRRect(claspRRect, strokePaint);

    // Kancing Stud Hardware di Tengah Clasp
    final studPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(claspRect.center, strokeWidth * 0.55, studPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
