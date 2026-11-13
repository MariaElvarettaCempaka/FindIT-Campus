import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Popup Konfirmasi Perubahan Profil
/// Dibuat mengikuti gaya desain dialog popup logout (Figma Node 181:2320):
/// - Container rounded 30 dengan drop-shadow lembut
/// - Ikon sukses mint/teal bundar 64x64
/// - Judul konfirmasi & deskripsi informatif
/// - Tombol aksi pill teal #1F7A6B
Future<void> showProfileUpdatedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0xFF12312E).withValues(alpha: 0.60),
    builder: (context) => const _ProfileUpdatedDialog(),
  );
}

class _ProfileUpdatedDialog extends StatefulWidget {
  const _ProfileUpdatedDialog();

  @override
  State<_ProfileUpdatedDialog> createState() => _ProfileUpdatedDialogState();
}

class _ProfileUpdatedDialogState extends State<_ProfileUpdatedDialog> {
  bool _isButtonPressed = false;

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
            // 1. Ikon Sukses Bundar 64x64 (Mint Background + Teal Checkmark)
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFCFEFE3), // Mint lembut
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 32,
                  color: Color(0xFF1F7A6B), // Teal
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Judul Dialog
            Text(
              'Profil Berhasil Diperbarui',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12312E),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Deskripsi
            Text(
              'Perubahan nama, nomor WhatsApp, dan status kampus kamu telah tersimpan dengan aman.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5B6E6B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tombol Pill Teal "Oke, Mengerti"
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _isButtonPressed = true),
              onTapUp: (_) {
                setState(() => _isButtonPressed = false);
                Navigator.pop(context);
              },
              onTapCancel: () => setState(() => _isButtonPressed = false),
              child: AnimatedScale(
                scale: _isButtonPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7A6D), // Teal
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F7A6D).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Oke, Mengerti',
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
          ],
        ),
      ),
    );
  }
}

