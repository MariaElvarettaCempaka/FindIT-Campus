import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/smooth_page_route.dart';
import '../../services/auth_service.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../auth/login_screen.dart';
import '../found/found_screen.dart';
import '../home/home_screen.dart';
import '../post/post_report_screen.dart';
import '../search/search_screen.dart';
import 'edit_profile_screen.dart';
import 'report_history_screen.dart';
import 'widgets/logout_dialog.dart';

/// Halaman 9 · Profil Pengguna (Figma Node 181:2164).
/// Desain visual presisi 1:1 sesuai Figma:
/// - Header identitas (Avatar peach 72x72, nama, prodi, tombol edit)
/// - Baris statistik (3 kartu: Postingan, Aktif, Selesai)
/// - Seksi AKUN (Kartu modular berbayangan lembut dengan 4 baris opsi)
/// - Baris WhatsApp dengan badge pill 'Privat'
/// - Tombol Keluar bergaris coral (#C8431F) terhubung ke Dialog Logout
/// - Floating Bottom Nav terintegrasi dengan index Profil (3) aktif
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLogoutPressed = false;

  String _formatDisplayPhone(String raw) {
    if (raw.isEmpty) return '+62 812-••••-7890';
    if (raw.length >= 8) {
      final prefix = raw.substring(0, 3);
      final suffix = raw.substring(raw.length - 4);
      return '+62 $prefix-••••-$suffix';
    }
    return '+62 $raw';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showLogoutDialog(context);
    if (confirmed == true) {
      await AuthService.instance.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 3) return; // Sudah di halaman Profil

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const FoundScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = user?.nama ?? 'Rani Putri';
    final role = '${user?.peran ?? "Mahasiswa"} · ${user?.prodi ?? "SI 2024"}';
    final email = user?.email ?? 'rani@email.com';
    final phone = _formatDisplayPhone(user?.whatsapp ?? '81234567890');
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'R';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // AppColors.bgCanvas
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Konten Scrollable
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 20,
                24,
                118, // Ruang kosong untuk FloatingBottomNav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identitas Pengguna
                  Row(
                    children: [
                      // Avatar Peach 72x72
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD9CC), // Peach
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF9B2C12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Nama & Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF12312E),
                                letterSpacing: -0.22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              role,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF5B6E6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Baris Statistik (3 Kartu)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          value: '${user?.totalPostingan ?? 4}',
                          label: 'Postingan',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          value: '${user?.laporanAktif ?? 2}',
                          label: 'Aktif',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          value: '${user?.laporanSelesai ?? 2}',
                          label: 'Selesai',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Label Seksi: AKUN
                  Text(
                    'AKUN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5B6E6B),
                      letterSpacing: 0.56,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kartu Daftar Akun (White Card Rounded 24)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF12312E).withValues(alpha: 0.05),
                          offset: const Offset(0, 6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Baris 1: Edit Profil
                        _buildAccountRow(
                          icon: Icons.person_outline_rounded,
                          iconBg: const Color(0xFFBFE9DA), // Mint
                          title: 'Edit profil',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF5B6E6B),
                          ),
                          onTap: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (updated == true && mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        _buildDivider(),

                        // Baris 2: Riwayat Laporan
                        _buildAccountRow(
                          icon: Icons.format_list_bulleted_rounded,
                          iconBg: const Color(0xFFFFE8A3), // Kuning
                          title: 'Riwayat laporan',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${user?.totalPostingan ?? 4}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5B6E6B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Color(0xFF5B6E6B),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),

                        // Baris 3: Nomor WhatsApp (dengan pil Privat)
                        _buildAccountRow(
                          icon: Icons.phone_outlined,
                          iconBg: const Color(0xFFFFD9CC), // Peach
                          title: 'Nomor WhatsApp',
                          subtitle: phone,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFEFE3), // Mint chip
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 11,
                                  color: Color(0xFF14573F),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Privat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF14573F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildDivider(),

                        // Baris 4: Email
                        _buildAccountRow(
                          icon: Icons.mail_outline_rounded,
                          iconBg: const Color(0xFFEDE8DF), // Neutral
                          title: 'Email',
                          subtitle: email,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tombol Keluar (Outlined Coral)
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isLogoutPressed = true),
                    onTapUp: (_) {
                      setState(() => _isLogoutPressed = false);
                      _handleLogout();
                    },
                    onTapCancel: () => setState(() => _isLogoutPressed = false),
                    child: AnimatedScale(
                      scale: _isLogoutPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: const Color(0xFFC8431F),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: Color(0xFFC8431F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Keluar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFC8431F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 2. Fixed Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: 3, // Tab Profil aktif
              onTabSelected: _onBottomNavSelected,
              onPostTap: () {
                Navigator.push<Map<String, dynamic>>(
                  context,
                  SmoothPageRoute(
                    child: const PostReportScreen(
                      initialType: ReportType.lost,
                      initialCampus: 'Ketintang',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
  }) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12312E).withValues(alpha: 0.05),
            offset: const Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF12312E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5B6E6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF12312E),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight:
                          subtitle == null ? FontWeight.w700 : FontWeight.w400,
                      color: subtitle == null
                          ? const Color(0xFF12312E)
                          : const Color(0xFF5B6E6B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF12312E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: const Color(0xFFEFE9DD),
      ),
    );
  }
}
