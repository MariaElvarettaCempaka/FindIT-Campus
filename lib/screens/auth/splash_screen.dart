import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';

/// Screen 1: Splash Screen
/// Visual presisi 1:1 sesuai Figma Node 181:1829
/// Fitur:
/// - Background edge-to-edge solid dark teal #12312E tanpa ada celah/border putih
/// - Garis radar konsentris sesuai warna asli Figma:
///     * Gelombang 1 (300px): Stroke #F2603F (coral) opacity 0.14
///     * Gelombang 2 (230px): Stroke #F2603F (coral) opacity 0.26
///     * Gelombang 3 (170px): Stroke #BFE9DA (mint) opacity 0.42
/// - Glow teal (320px, #1F7A6B opacity 0.28) di kanan atas
/// - Glow coral (300px, #F2603F opacity 0.20) di kiri bawah
/// - 5 Bintang/Dots (2 Kuning #FFE8A3, 2 Mint #BFE9DA, 1 Peach #FFD9CC)
/// - Ikon Kaca Pembesar 3D dengan peach glass lens, specular reflection crescent, rim silver, dan gagang hitam 45°
/// - 3 Floating Tiles (HP #FFE8A3 +5°, Dompet #FFD9CC -9°, Kunci #BFE9DA +8°) dengan path SVG asli
/// - Badges "Hilang" (#FFE0D6, -6°) & "Ditemukan" (#CFEFE3, +5°)
/// - Loading bar garis oren bergerak mulus dari 0% hingga 100% (160px) lalu bertransisi ke Onboarding 1
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  late final Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOutCubic,
    );

    // Saat animasi garis oren mencapai 100%, navigasi otomatis ke Onboarding 1
    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    });

    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF12312E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF12312E), // Canvas Dark Figma
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF12312E), // Menjamin 100% tidak ada putih di background
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Glow Teal (Kanan Atas: 320x320, #1F7A6B opacity 0.28)
                  Positioned(
                    top: -100,
                    left: screenWidth * 0.55,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1F7A6D).withValues(alpha: 0.28),
                      ),
                    ),
                  ),

                  // 2. Glow Coral (Kiri Bawah: 300x300, #F2603F opacity 0.20) - Asli Figma
                  Positioned(
                    bottom: -60,
                    left: -120,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF2603F).withValues(alpha: 0.20),
                      ),
                    ),
                  ),

                  // 3. Bintang / Dots Dekoratif Asli Figma (5 Titik tanpa warna putih)
                  // Bintang 1: Kuning #FFE8A3 (size 8x8)
                  Positioned(
                    top: topInset + (screenHeight * 0.08),
                    left: 70,
                    child: _buildSparkleDot(size: 8, color: const Color(0xFFFFE8A3)),
                  ),
                  // Bintang 2: Mint #BFE9DA (size 6x6)
                  Positioned(
                    top: topInset + (screenHeight * 0.11),
                    right: 68,
                    child: _buildSparkleDot(size: 6, color: const Color(0xFFBFE9DA)),
                  ),
                  // Bintang 3: Mint #BFE9DA (size 6x6)
                  Positioned(
                    top: topInset + (screenHeight * 0.28),
                    left: 26,
                    child: _buildSparkleDot(size: 6, color: const Color(0xFFBFE9DA)),
                  ),
                  // Bintang 4: Kuning #FFE8A3 (size 8x8)
                  Positioned(
                    top: topInset + (screenHeight * 0.42),
                    right: 36,
                    child: _buildSparkleDot(size: 8, color: const Color(0xFFFFE8A3)),
                  ),
                  // Bintang 5: Peach #FFD9CC (size 7x7)
                  Positioned(
                    top: topInset + (screenHeight * 0.62),
                    left: 40,
                    child: _buildSparkleDot(size: 7, color: const Color(0xFFFFD9CC)),
                  ),

                  // 4. Area Visual Utama (Radar Gelombang Asli Figma, Pusat Kaca Pembesar, 3 Kartu & 2 Badges)
                  Positioned(
                    top: topInset + (screenHeight * 0.05),
                    left: 0,
                    right: 0,
                    height: 380,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Gelombang 1 (Lingkaran luar: 300px, Stroke #F2603F opacity 0.14 - Sesuai Figma)
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF2603F).withValues(alpha: 0.14),
                              width: 2.0,
                            ),
                          ),
                        ),

                        // Gelombang 2 (Lingkaran tengah: 230px, Stroke #F2603F opacity 0.26 - Sesuai Figma)
                        Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF2603F).withValues(alpha: 0.26),
                              width: 2.0,
                            ),
                          ),
                        ),

                        // Gelombang 3 (Lingkaran dalam: 170px, Stroke #BFE9DA opacity 0.42 - Sesuai Figma)
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBFE9DA).withValues(alpha: 0.42),
                              width: 2.0,
                            ),
                          ),
                        ),

                        // Lingkaran Pusat Coral 124x124 dengan Glow Drop Shadow
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2603F), // Coral
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF2603F).withValues(alpha: 0.50),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Center(
                            // Kaca pembesar 3D dengan lensa peach, rim silver, dan gagang hitam
                            child: CustomPaint(
                              size: const Size(64, 64),
                              painter: _FigmaMagnifyingGlassPainter(),
                            ),
                          ),
                        ),

                        // Tile 1: HP Kuning (Atas tengah, rotate 5 deg)
                        Positioned(
                          top: 4,
                          child: Transform.rotate(
                            angle: 5 * math.pi / 180,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8A3), // Kuning
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(30, 30),
                                  painter: _PhoneIconPainter(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Tile 2: Dompet Peach (Kiri, rotate -9 deg)
                        Positioned(
                          left: (screenWidth / 2) - 165,
                          top: 55,
                          child: Transform.rotate(
                            angle: -9 * math.pi / 180,
                            child: Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD9CC), // Peach
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(38, 38),
                                  painter: _WalletIconPainter(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Tile 3: Kunci Mint (Kanan, rotate 8 deg)
                        Positioned(
                          right: (screenWidth / 2) - 160,
                          top: 85,
                          child: Transform.rotate(
                            angle: 8 * math.pi / 180,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFE9DA), // Mint
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(38, 38),
                                  painter: _KeyIconPainter(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Pill "Hilang" (Kiri radar, rotate -6 deg)
                        Positioned(
                          left: (screenWidth / 2) - 170,
                          top: 250,
                          child: Transform.rotate(
                            angle: -6 * math.pi / 180,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0D6), // lost-bg
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 9,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Hilang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF9B2C12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Pill "Ditemukan" (Kanan radar, rotate 5 deg)
                        Positioned(
                          right: (screenWidth / 2) - 170,
                          top: 195,
                          child: Transform.rotate(
                            angle: 5 * math.pi / 180,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCFEFE3), // found-bg
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 9,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Ditemukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF14573F),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Teks Brand & Tagline
                  Positioned(
                    top: topInset + (screenHeight * 0.48),
                    left: 24,
                    right: 24,
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                            children: const [
                              TextSpan(
                                text: 'FindIt',
                                style: TextStyle(color: Color(0xFFFBF8F3)),
                              ),
                              TextSpan(
                                text: ' Campus',
                                style: TextStyle(color: Color(0xFFF2603F)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hilang? Temukan.\nMenemukan? Kembalikan.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: const Color(0xFFBFE9DA), // Mint text
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 6. Garis Oren Animasi Loading & Footer UNESA (Paling Bawah)
                  Positioned(
                    bottom: bottomInset + 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Loading Bar Track (160x6) dengan Animasi Bergerak Garis Oren
                        Container(
                          width: 160,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFE9DA), // Mint Track Figma
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.centerLeft,
                          child: AnimatedBuilder(
                            animation: _loadingAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 160 * _loadingAnimation.value,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2603F), // Coral Oren Figma
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF2603F)
                                          .withValues(alpha: 0.65),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Footer UNESA
                        Text(
                          'Kelompok 2 · SI 2024A · UNESA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFBFE9DA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSparkleDot({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Custom Painter Kaca Pembesar 3D Sesuai Figma
class _FigmaMagnifyingGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.42, size.height * 0.42);
    final radius = size.width * 0.28;

    // 1. Gagang Kaca Pembesar (Gagang hitam miring ke kanan bawah 45 derajat)
    final handlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final handleStart = center + const Offset(15, 15);
    final handleEnd = center + const Offset(28, 28);
    canvas.drawLine(handleStart, handleEnd, handlePaint);

    // Sambungan gagang (ferrule) metalik silver
    final ferrulePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt;
    final ferruleEnd = center + const Offset(18, 18);
    canvas.drawLine(handleStart, ferruleEnd, ferrulePaint);

    // 2. Lensa Kaca Peach Lembut
    final lensPaint = Paint()
      ..color = const Color(0xFFFFD9CC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, lensPaint);

    // 3. Highlight Specular Kaca (Kilauan cahaya bulan sabit di kiri atas lensa)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      -2.4,
      1.4,
      false,
      highlightPaint,
    );

    // 4. Rim / Bingkai Metalik Silver
    final rimPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter Icon Phone Sesuai SVG Asli Figma (30x30)
class _PhoneIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body HP rounded rect
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8.75, 3.125, 12.5, 23.75),
      const Radius.circular(3.75),
    );
    canvas.drawRRect(rrect, paint);

    // Home indicator line
    canvas.drawLine(
      const Offset(13.75, 23.125),
      const Offset(16.25, 23.125),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter Icon Wallet Sesuai SVG Asli Figma (38x38)
class _WalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body dompet rounded rect
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4.75, 9.5, 28.5, 19.0),
      const Radius.circular(5.5),
    );
    canvas.drawRRect(rrect, paint);

    // Clasp line kanan
    canvas.drawLine(
      const Offset(24.5, 19.0),
      const Offset(27.7, 19.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter Icon Key Sesuai SVG Asli Figma (38x38)
class _KeyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Lingkaran kepala kunci (center: 12.67, 19.0, radius: 4.75)
    canvas.drawCircle(const Offset(12.67, 19.0), 4.75, paint);

    // Batang kunci & gerigi
    canvas.drawLine(const Offset(17.42, 19.0), const Offset(31.67, 19.0), paint);
    canvas.drawLine(const Offset(26.92, 19.0), const Offset(26.92, 23.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
