import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

/// Dialog Konfirmasi Bergaya Apple (/apple-design & /charles-ux-animation).
///
/// Fitur:
/// - Backdrop blur halus (ImageFilter.blur sigma 8) dengan transisi easeOutCubic.
/// - Top icon badge elegan dengan background sirkular beraksen lembut.
/// - Tipografi Plus Jakarta Sans dengan kontras dan hierarchy yang proporsional.
/// - Layout tombol berdampingan (Side-by-Side Row) yang simetris dan seimbang.
/// - Feedback taktil pegas (AnimatedScale 0.96, 100ms) pada seluruh tombol.
Future<bool?> showAppleConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  Color? confirmButtonColor,
  bool isDestructive = false,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (dialogCtx, animation, secondaryAnimation, _) {
      final curvedAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * animation.value,
          sigmaY: 8 * animation.value,
        ),
        child: FadeTransition(
          opacity: curvedAnim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedAnim),
            child: Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE8EFEA),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12312E).withValues(alpha: 0.12),
                      offset: const Offset(0, 8),
                      blurRadius: 28,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Top Circular Icon Badge
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDestructive ? const Color(0xFFDC2626) : AppColors.green950,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3. Message Body
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 4. Action Buttons (Side by Side Row)
                    _AppleDialogActionsRow(
                      confirmText: confirmText,
                      isDestructive: isDestructive,
                      confirmButtonColor: confirmButtonColor,
                      onCancel: () => Navigator.pop(dialogCtx, false),
                      onConfirm: () => Navigator.pop(dialogCtx, true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AppleDialogActionsRow extends StatefulWidget {
  final String confirmText;
  final bool isDestructive;
  final Color? confirmButtonColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _AppleDialogActionsRow({
    required this.confirmText,
    required this.isDestructive,
    this.confirmButtonColor,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_AppleDialogActionsRow> createState() => _AppleDialogActionsRowState();
}

class _AppleDialogActionsRowState extends State<_AppleDialogActionsRow> {
  bool _isCancelPressed = false;
  bool _isConfirmPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.confirmButtonColor ??
        (widget.isDestructive ? const Color(0xFFDC2626) : AppColors.teal600);

    return Row(
      children: [
        // Batal Button
        Expanded(
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isCancelPressed = true),
            onTapUp: (_) {
              setState(() => _isCancelPressed = false);
              widget.onCancel();
            },
            onTapCancel: () => setState(() => _isCancelPressed = false),
            child: AnimatedScale(
              scale: _isCancelPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDEE5E1),
                    width: 1.2,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Confirm Button
        Expanded(
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isConfirmPressed = true),
            onTapUp: (_) {
              setState(() => _isConfirmPressed = false);
              widget.onConfirm();
            },
            onTapCancel: () => setState(() => _isConfirmPressed = false),
            child: AnimatedScale(
              scale: _isConfirmPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.28),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.confirmText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
