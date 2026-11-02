import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_dimens.dart';

enum AppButtonType {
  primary,
  secondary,
  lost,
  whatsapp,
}

/// Tombol standar FindIT Campus yang presisi sesuai Design System Figma.
/// Memiliki 4 varian: primary (teal), secondary (sand), lost (coral), whatsapp (green).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = AppButtonType.secondary;

  const AppButton.whatsapp({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.chat,
    this.isLoading = false,
    this.width,
  }) : type = AppButtonType.whatsapp;

  const AppButton.lost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : type = AppButtonType.lost;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    double height;
    double radius;
    double fontSize;

    switch (type) {
      case AppButtonType.primary:
        bgColor = AppColors.actionPrimary;
        fgColor = AppColors.actionOnPrimary;
        height = AppDimens.buttonPrimaryHeight;
        radius = AppDimens.radius18;
        fontSize = 15;
        break;
      case AppButtonType.secondary:
        bgColor = AppColors.actionSecondary;
        fgColor = AppColors.actionOnSecondary;
        height = AppDimens.buttonSecondaryHeight;
        radius = AppDimens.radius18;
        fontSize = 13;
        break;
      case AppButtonType.lost:
        bgColor = AppColors.actionLost;
        fgColor = AppColors.actionOnLost;
        height = AppDimens.buttonLostHeight;
        radius = AppDimens.radius12;
        fontSize = 14;
        break;
      case AppButtonType.whatsapp:
        bgColor = AppColors.actionWhatsapp;
        fgColor = AppColors.actionOnWhatsapp;
        height = AppDimens.buttonWhatsappHeight;
        radius = AppDimens.radius18;
        fontSize = 15;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          disabledForegroundColor: fgColor.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fgColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

