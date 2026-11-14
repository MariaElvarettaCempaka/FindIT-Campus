import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halaman 11 · Popup Logout (Figma Node 181:2320).
/// Desain dialog modal persis sesuai Figma:
/// - Container putih rounded 30 dengan drop-shadow tebal
/// - Ikon Logout dalam lingkaran peach 64x64
/// - Judul "Keluar dari akun?" & penjelasan
/// - Dua tombol pill: "Batal" (Neutral #EDE8DF) & "Ya, keluar" (Coral #C8431F)
Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0xFF12312E).withValues(alpha: 0.60),
    builder: (context) => const _LogoutDialog(),
  );
}

class _LogoutDialog extends StatefulWidget {
  const _LogoutDialog();

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _isCancelPressed = false;
  bool _isConfirmPressed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12312E).withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Ikon Peach Bundar 64x64
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD9CC), // Peach
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  size: 28,
                  color: Color(0xFFC8431F),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Judul Dialog
            Text(
              'Keluar dari akun?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12312E),
                letterSpacing: -0.21,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Deskripsi
            Text(
              'Kamu perlu masuk lagi untuk membuat laporan atau menghubungi pelapor lewat WhatsApp.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5B6E6B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // 4. Dua Tombol Aksi (Batal & Ya, Keluar)
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isCancelPressed = true),
                    onTapUp: (_) {
                      setState(() => _isCancelPressed = false);
                      Navigator.pop(context, false);
                    },
                    onTapCancel: () => setState(() => _isCancelPressed = false),
                    child: AnimatedScale(
                      scale: _isCancelPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE8DF),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF12312E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tombol Ya, keluar
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isConfirmPressed = true),
                    onTapUp: (_) {
                      setState(() => _isConfirmPressed = false);
                      Navigator.pop(context, true);
                    },
                    onTapCancel: () =>
                        setState(() => _isConfirmPressed = false),
                    child: AnimatedScale(
                      scale: _isConfirmPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8431F),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Center(
                          child: Text(
                            'Ya, keluar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

