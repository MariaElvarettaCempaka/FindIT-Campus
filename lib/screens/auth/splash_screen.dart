import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';

/// Screen 1: Splash Screen
/// Visual presisi 1:1 sesuai Figma Node 181:1829
/// Disempurnakan dengan prinsip /apple-design, /ui-taste, dan /charles-ux-animation:
/// - Background edge-to-edge solid dark teal #12312E tanpa ada celah/border putih
/// - Garis radar konsentris sesuai warna asli Figma dengan animasi breathing subtle
/// - 3 Floating Tiles dengan ikon bergaya Apple SF Symbols (Non-Generic AI)
/// - Animasi idle floating fisik (harmonic oscillation out-of-phase)
/// - Staggered spring entrance untuk logo, tiles, badges, dan teks
/// - Kaca Pembesar 3D dengan lensa frosted translucent, bevel rim, dan specular highlight
/// - Footer bersih tanpa teks kelompok, fokus pada loading bar progress oren
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk progres loading bar (2400ms)
  late final AnimationController _loadingController;
  late final Animation<double> _loadingAnimation;

  // Controller untuk staggered entrance (1000ms)
  late final AnimationController _entranceController;
  late final Animation<double> _centerScaleAnim;
  late final Animation<double> _tile1ScaleAnim;
  late final Animation<double> _tile2ScaleAnim;
  late final Animation<double> _tile3ScaleAnim;
  late final Animation<double> _badgeLostScaleAnim;
  late final Animation<double> _badgeFoundScaleAnim;
  late final Animation<double> _textFadeAnim;
  late final Animation<Offset> _textSlideAnim;

  // Controller untuk idle floating & radar breathing loop (3200ms)
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();

    // 1. Loading Bar Controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOutCubic,
    );

    // Navigasi otomatis ke Onboarding 1 dengan transisi fade halus
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
            transitionDuration: const Duration(milliseconds: 380),
          ),
        );
      }
    });

    // 2. Entrance Stagger Controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Center coral disk (0ms - 450ms) dengan spring overshoot
    _centerScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    // Tile 1 - HP (100ms - 550ms)
    _tile1ScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.10, 0.55, curve: Curves.easeOutBack),
    );

    // Tile 2 - Dompet (200ms - 650ms)
    _tile2ScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.65, curve: Curves.easeOutBack),
    );

    // Tile 3 - Kunci (300ms - 750ms)
    _tile3ScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOutBack),
    );

    // Badge "Hilang" (350ms - 750ms)
    _badgeLostScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutBack),
    );

    // Badge "Ditemukan" (450ms - 850ms)
    _badgeFoundScaleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutBack),
    );

    // Text Fade & Slide (400ms - 850ms)
    _textFadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
    );
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Idle Continuous Loop Controller (Floating physics & breathing radar)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Mulai animasi
    _entranceController.forward();
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _entranceController.dispose();
    _idleController.dispose();
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
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF12312E), // Canvas Dark Figma
        body: SizedBox.expand(
          child: Container(
            color: const Color(0xFF12312E), // Solid edge-to-edge
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight;
                  final screenWidth = constraints.maxWidth;

                  return AnimatedBuilder(
                    animation: _idleController,
                    builder: (context, child) {
                      final t = _idleController.value;

                      // Nilai osilasi harmonik floating out-of-phase (gerakan naik-turun halus)
                      final floatTile1 = math.sin(t * 2 * math.pi) * 3.5;
                      final floatTile2 =
                          math.sin((t + 0.33) * 2 * math.pi) * 4.0;
                      final floatTile3 =
                          math.sin((t + 0.66) * 2 * math.pi) * 3.8;

                      // Breathing subtle untuk gelombang radar (skala 0.985 - 1.015)
                      final radarScale =
                          1.0 + (math.sin(t * 2 * math.pi) * 0.015);
                      final radarOpacityPulse =
                          0.88 + (math.sin(t * 2 * math.pi) * 0.12);

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
                                color: const Color(0xFF1F7A6D)
                                    .withValues(alpha: 0.28),
                              ),
                            ),
                          ),

                          // 2. Glow Coral (Kiri Bawah: 300x300, #F2603F opacity 0.20)
                          Positioned(
                            bottom: -60,
                            left: -120,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF2603F)
                                    .withValues(alpha: 0.20),
                              ),
                            ),
                          ),

                          // 3. Bintang / Dots Dekoratif Asli Figma (5 Titik tanpa warna putih)
                          Positioned(
                            top: topInset + (screenHeight * 0.08),
                            left: 70,
                            child: _buildSparkleDot(
                              size: 8,
                              color: const Color(0xFFFFE8A3),
                            ),
                          ),
                          Positioned(
                            top: topInset + (screenHeight * 0.11),
                            right: 68,
                            child: _buildSparkleDot(
                              size: 6,
                              color: const Color(0xFFBFE9DA),
                            ),
                          ),
                          Positioned(
                            top: topInset + (screenHeight * 0.28),
                            left: 26,
                            child: _buildSparkleDot(
                              size: 6,
                              color: const Color(0xFFBFE9DA),
                            ),
                          ),
                          Positioned(
                            top: topInset + (screenHeight * 0.42),
                            right: 36,
                            child: _buildSparkleDot(
                              size: 8,
                              color: const Color(0xFFFFE8A3),
                            ),
                          ),
                          Positioned(
                            top: topInset + (screenHeight * 0.62),
                            left: 40,
                            child: _buildSparkleDot(
                              size: 7,
                              color: const Color(0xFFFFD9CC),
                            ),
                          ),

                          // 4. Area Visual Utama (Radar Gelombang, Kaca Pembesar, 3 Kartu & 2 Badges)
                          Positioned(
                            top: topInset + (screenHeight * 0.05),
                            left: 0,
                            right: 0,
                            height: 380,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Gelombang 1 (Lingkaran luar: 300px, Stroke #F2603F opacity 0.14)
                                Transform.scale(
                                  scale: radarScale,
                                  child: Opacity(
                                    opacity: radarOpacityPulse.clamp(0.0, 1.0),
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF2603F)
                                              .withValues(alpha: 0.14),
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Gelombang 2 (Lingkaran tengah: 230px, Stroke #F2603F opacity 0.26)
                                Transform.scale(
                                  scale: radarScale,
                                  child: Container(
                                    width: 230,
                                    height: 230,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFF2603F)
                                            .withValues(alpha: 0.26),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),

                                // Gelombang 3 (Lingkaran dalam: 170px, Stroke #BFE9DA opacity 0.42)
                                Transform.scale(
                                  scale: radarScale,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFBFE9DA)
                                            .withValues(alpha: 0.42),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),

                                // Lingkaran Pusat Coral 124x124 dengan Glow Drop Shadow & Kaca Pembesar 3D
                                ScaleTransition(
                                  scale: _centerScaleAnim,
                                  child: Container(
                                    width: 124,
                                    height: 124,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2603F), // Coral
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF2603F)
                                              .withValues(alpha: 0.50),
                                          blurRadius: 40,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 18),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(64, 64),
                                        painter:
                                            _AppleMagnifyingGlassPainter(),
                                      ),
                                    ),
                                  ),
                                ),

                                // Tile 1: HP Kuning (Atas tengah, rotate 5 deg + Idle Float)
                                Positioned(
                                  top: 4 + floatTile1,
                                  child: ScaleTransition(
                                    scale: _tile1ScaleAnim,
                                    child: Transform.rotate(
                                      angle: 5 * math.pi / 180,
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE8A3), // Kuning
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.16),
                                              blurRadius: 16,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFFFFE8A3)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CustomPaint(
                                            size: const Size(30, 30),
                                            painter: _ApplePhoneIconPainter(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Tile 2: Dompet Peach (Kiri, rotate -9 deg + Idle Float)
                                Positioned(
                                  left: (screenWidth / 2) - 165,
                                  top: 55 + floatTile2,
                                  child: ScaleTransition(
                                    scale: _tile2ScaleAnim,
                                    child: Transform.rotate(
                                      angle: -9 * math.pi / 180,
                                      child: Container(
                                        width: 78,
                                        height: 78,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD9CC), // Peach
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.16),
                                              blurRadius: 16,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFFFFD9CC)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CustomPaint(
                                            size: const Size(38, 38),
                                            painter: _AppleWalletIconPainter(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Tile 3: Kunci Mint (Kanan, rotate 8 deg + Idle Float)
                                Positioned(
                                  right: (screenWidth / 2) - 160,
                                  top: 85 + floatTile3,
                                  child: ScaleTransition(
                                    scale: _tile3ScaleAnim,
                                    child: Transform.rotate(
                                      angle: 8 * math.pi / 180,
                                      child: Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFBFE9DA), // Mint
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.16),
                                              blurRadius: 16,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFFBFE9DA)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CustomPaint(
                                            size: const Size(38, 38),
                                            painter: _AppleKeyIconPainter(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Pill "Hilang" (Kiri radar, rotate -6 deg)
                                Positioned(
                                  left: (screenWidth / 2) - 170,
                                  top: 250,
                                  child: ScaleTransition(
                                    scale: _badgeLostScaleAnim,
                                    child: Transform.rotate(
                                      angle: -6 * math.pi / 180,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE0D6), // lost-bg
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.40),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
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
                                ),

                                // Pill "Ditemukan" (Kanan radar, rotate 5 deg)
                                Positioned(
                                  right: (screenWidth / 2) - 170,
                                  top: 195,
                                  child: ScaleTransition(
                                    scale: _badgeFoundScaleAnim,
                                    child: Transform.rotate(
                                      angle: 5 * math.pi / 180,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCFEFE3), // found-bg
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.40),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
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
                                ),
                              ],
                            ),
                          ),

                          // 5. Teks Brand & Tagline (Dengan Entrance Slide + Fade)
                          Positioned(
                            top: topInset + (screenHeight * 0.48),
                            left: 24,
                            right: 24,
                            child: FadeTransition(
                              opacity: _textFadeAnim,
                              child: SlideTransition(
                                position: _textSlideAnim,
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
                                            style: TextStyle(
                                                color: Color(0xFFFBF8F3)),
                                          ),
                                          TextSpan(
                                            text: ' Campus',
                                            style: TextStyle(
                                                color: Color(0xFFF2603F)),
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
                            ),
                          ),

                          // 6. Garis Oren Animasi Loading (Bawah - Bersih & Rapi tanpa footer kelompok)
                          Positioned(
                            bottom: bottomInset + 36,
                            left: 24,
                            right: 24,
                            child: Center(
                              child: Container(
                                width: 160,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFE9DA)
                                      .withValues(alpha: 0.65), // Mint Track Figma
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
                                        borderRadius:
                                            BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF2603F)
                                                .withValues(alpha: 0.75),
                                            blurRadius: 8,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
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

// =============================================================================
// IKON-IKON REFINED APPLE-DESIGN & ANTI-UI-SLOP
// Menghindari tampilan flat garis generik AI; menggunakan proporsi elegan,
// detail hardware tactile, dan line-weight terkalibrasi.
// =============================================================================

/// Ikon Kaca Pembesar 3D Bergaya Apple (Frosted Translucent Lens, Silver Rim, Bevel, Specular)
class _AppleMagnifyingGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.42, size.height * 0.42);
    final radius = size.width * 0.28;

    // 1. Gagang Kaca Pembesar Ergonomis (Sudut 45 derajat)
    final handlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;

    final handleStart = center + const Offset(14, 14);
    final handleEnd = center + const Offset(27, 27);
    canvas.drawLine(handleStart, handleEnd, handlePaint);

    // Kilauan highlights subtle pada gagang (Apple style tactile sheen)
    final handleSheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      handleStart + const Offset(-1, 1),
      handleEnd + const Offset(-1, 1),
      handleSheenPaint,
    );

    // Titanium Ferrule (Cincin penyambung antara rim dan gagang)
    final ferrulePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 9.5
      ..strokeCap = StrokeCap.butt;
    final ferruleEnd = center + const Offset(17.5, 17.5);
    canvas.drawLine(handleStart, ferruleEnd, ferrulePaint);

    // 2. Lensa Peach Translucent dengan Gradien Kedalaman
    final lensGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.9,
      colors: [
        const Color(0xFFFFEDE6), // Inti pantulan terang
        const Color(0xFFFFD9CC), // Warna peach Figma
        const Color(0xFFF7BFAE), // Bayangan tepi lensa
      ],
      stops: const [0.0, 0.65, 1.0],
    );
    final lensPaint = Paint()
      ..shader = lensGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, lensPaint);

    // 3. Highlight Specular Kaca (Kilauan cahaya bulan sabit di kiri atas)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      -2.45,
      1.35,
      false,
      highlightPaint,
    );

    // Titik kilauan specular mikro kedua (Apple glass characteristic)
    final miniDotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-7, -7), 1.2, miniDotPaint);

    // 4. Bingkai Rim Metalik Silver Presisi
    final rimPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6;
    canvas.drawCircle(center, radius, rimPaint);

    // Cincin bevel tipis di sisi luar rim
    final outerBevelPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius + 1.8, outerBevelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ikon Smartphone Bergaya Apple SF Symbols (Proporsi Golden Ratio, Bezel Elegan, Dynamic Island)
class _ApplePhoneIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body Smartphone: w: 14.5, h: 25.5, radius: 4.2
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 14.5,
      height: 25.5,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4.2));
    canvas.drawRRect(rrect, strokePaint);

    // Dynamic Island / Pill Speaker di bagian atas
    final pillPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.fill;
    final pillRect = Rect.fromCenter(
      center: Offset(size.width / 2, rect.top + 3.2),
      width: 4.4,
      height: 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(1.0)),
      pillPaint,
    );

    // Home indicator bar di bagian bawah
    final indicatorPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2 - 2.8, rect.bottom - 2.8),
      Offset(size.width / 2 + 2.8, rect.bottom - 2.8),
      indicatorPaint,
    );

    // Layar display subtle (memberikan kedalaman tanpa menjadi berlebihan)
    final screenBezel = Paint()
      ..color = const Color(0xFF12312E).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final screenRect = Rect.fromLTWH(
      rect.left + 1.4,
      rect.top + 5.5,
      rect.width - 2.8,
      rect.height - 10.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(1.8)),
      screenBezel,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ikon Dompet Kartu Bergaya Apple Wallet / Leather Cardholder (Lipatan Halus, Card Slot, Hardware Clasp)
class _AppleWalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);

    // 1. Body Dompet Utama (Rounded Rect Proporsional 28x20, r: 5.5)
    final walletRect = Rect.fromCenter(
      center: center + const Offset(0, 1),
      width: 28.0,
      height: 20.0,
    );
    final walletRRect =
        RRect.fromRectAndRadius(walletRect, const Radius.circular(5.5));
    canvas.drawRRect(walletRRect, strokePaint);

    // 2. Garis Lipatan / Slot Kartu di Bagian Atas
    final slotPath = Path()
      ..moveTo(walletRect.left + 3.0, walletRect.top + 6.0)
      ..cubicTo(
        walletRect.left + 10.0,
        walletRect.top + 7.5,
        walletRect.right - 10.0,
        walletRect.top + 7.5,
        walletRect.right - 3.0,
        walletRect.top + 6.0,
      );
    final slotPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(slotPath, slotPaint);

    // 3. Clasp Lid / Tab Kancing Dompet di Kanan
    final claspRect = Rect.fromCenter(
      center: Offset(walletRect.right - 2.5, walletRect.center.dy + 1),
      width: 7.0,
      height: 8.5,
    );
    final claspRRect =
        RRect.fromRectAndRadius(claspRect, const Radius.circular(3.0));

    // Fill pembersih agar garis belakang tab tidak tembus
    final claspBg = Paint()
      ..color = const Color(0xFFFFD9CC)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(claspRRect, claspBg);
    canvas.drawRRect(claspRRect, strokePaint);

    // Kancing Hardware Stud Kuningan di Tengah Clasp
    final studPaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(claspRect.center, 1.2, studPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ikon Kunci Bergaya Apple SF Symbols (Precision-Machined Key Head, Stepped Teeth, Golden Ratio)
class _AppleKeyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerY = size.height / 2;

    // 1. Kepala Kunci (Circular Bow) di Sisi Kiri
    final headCenter = Offset(size.width * 0.32, centerY);
    const headRadius = 6.2;
    canvas.drawCircle(headCenter, headRadius, strokePaint);

    // Lubang Gantungan Kunci di Bagian Tengah Kepala
    final holePaint = Paint()
      ..color = const Color(0xFF12312E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headCenter, 2.0, holePaint);

    // 2. Batang Poros Kunci (Key Shaft) Mendatar ke Kanan
    final shaftStart = headCenter + const Offset(headRadius, 0);
    final shaftEnd = Offset(size.width * 0.82, centerY);
    canvas.drawLine(shaftStart, shaftEnd, strokePaint);

    // 3. Dua Gerigi Kunci Presisi (Stepped Bit Teeth) ke Arah Bawah
    // Gerigi 1 (Panjang)
    canvas.drawLine(
      Offset(shaftEnd.dx - 8.0, centerY),
      Offset(shaftEnd.dx - 8.0, centerY + 5.2),
      strokePaint,
    );
    // Gerigi 2 (Pendek)
    canvas.drawLine(
      Offset(shaftEnd.dx - 2.5, centerY),
      Offset(shaftEnd.dx - 2.5, centerY + 3.8),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
