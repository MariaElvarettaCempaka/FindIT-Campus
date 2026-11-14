import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_dimens.dart';

enum ReportStatus {
  lost,
  found,
}

/// Chip status laporan (Hilang / Ditemukan) sesuai spesifikasi Figma Fondasi.
/// Padding 4 / 10 · Radius 99 (Pill) · Bold 11.
class StatusChip extends StatelessWidget {
  final ReportStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  const StatusChip.lost({
    super.key,
    this.customLabel,
  }) : status = ReportStatus.lost;

  const StatusChip.found({
    super.key,
    this.customLabel,
  }) : status = ReportStatus.found;

  @override
  Widget build(BuildContext context) {
    final isLost = status == ReportStatus.lost;
    final bgColor = isLost ? AppColors.chipLostBg : AppColors.chipFoundBg;
    final textColor = isLost ? AppColors.chipLostText : AppColors.chipFoundText;
    final label = customLabel ?? (isLost ? 'Hilang' : 'Ditemukan');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radius99),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Filter chip kategori barang (Semua, Dompet, HP, Kunci, dll).
/// Padding 8 / 14 · Radius 99 · Bold 12.
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.actionPrimary : AppColors.sand100;
    final textColor = isSelected ? AppColors.actionOnPrimary : AppColors.green950;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimens.radius99),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

