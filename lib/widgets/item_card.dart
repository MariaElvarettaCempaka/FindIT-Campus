import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'status_chip.dart';

/// Kartu item laporan feed "Terbaru di kampus" versi Modern Rich Card (/apple-design).
/// Dilengkapi dengan efek tactile micro-interaction (spring press scale, dynamic shadow depth, & bookmark action).
class ItemCard extends StatefulWidget {
  final String title;
  final String location;
  final String timeAgo;
  final ReportStatus status;
  final String? imageAsset;
  final IconData? icon;
  final String? snippet;
  final VoidCallback? onTap;
  final bool initialSaved;
  final ValueChanged<bool>? onSaveChanged;

  const ItemCard({
    super.key,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.status,
    this.imageAsset,
    this.icon,
    this.snippet,
    this.onTap,
    this.initialSaved = false,
    this.onSaveChanged,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isPressed = false;
  late bool _isSaved;
  bool _isBookmarkPressed = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSaved;
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.status == ReportStatus.lost;
    final tileBg = isLost ? const Color(0xFFFFD9CC) : const Color(0xFFBFE9DA);
    final iconColor = const Color(0xFF12312E);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed
                ? (isLost
                    ? AppColors.coral500.withValues(alpha: 0.3)
                    : const Color(0xFF17695D).withValues(alpha: 0.3))
                : const Color(0xFFDEE8E2).withValues(alpha: 0.75),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12312E).withValues(
                alpha: _isPressed ? 0.03 : 0.06,
              ),
              offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
              blurRadius: _isPressed ? 6 : 14,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(20),
            splashColor: (isLost ? AppColors.coral500 : const Color(0xFF17695D))
                .withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail 76x76 dengan nested continuous radius
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 76,
                      height: 76,
                      color: tileBg,
                      child: widget.imageAsset != null
                          ? Image.asset(
                              widget.imageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.inventory_2_outlined,
                                  color: iconColor,
                                  size: 30,
                                );
                              },
                            )
                          : Icon(
                              widget.icon ?? Icons.inventory_2_outlined,
                              size: 30,
                              color: iconColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris Chip Status + Waktu + Bookmark Button
                        Row(
                          children: [
                            StatusChip(status: widget.status),
                            const Spacer(),
                            Text(
                              widget.timeAgo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7D8E89),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Micro Bookmark Action
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (_) =>
                                  setState(() => _isBookmarkPressed = true),
                              onTapUp: (_) {
                                setState(() {
                                  _isBookmarkPressed = false;
                                  _isSaved = !_isSaved;
                                });
                                widget.onSaveChanged?.call(_isSaved);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isSaved
                                          ? 'Disimpan ke bookmark'
                                          : 'Dihapus dari bookmark',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              onTapCancel: () =>
                                  setState(() => _isBookmarkPressed = false),
                              child: AnimatedScale(
                                scale: _isBookmarkPressed ? 0.82 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOutCubic,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _isSaved
                                        ? const Color(0xFF17695D)
                                            .withValues(alpha: 0.12)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_outline_rounded,
                                    size: 17,
                                    color: _isSaved
                                        ? const Color(0xFF17695D)
                                        : const Color(0xFF8C9D98),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Judul Barang
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF12312E),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Lokasi dengan Apple Teal Location Pin Badge
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFF17695D),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4F625E),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Deskripsi Ringkas Cuplikan (Jika ada)
                        if (widget.snippet != null &&
                            widget.snippet!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.snippet!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF5E6E6A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
