import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

/// Floating White Glassy Bottom Navigation Bar (Apple Frosted Glass style).
/// - White Translucent Frosted Glass (samar-samar dengan BackdropFilter blur 25px)
/// - Continuous Apple Squircle Corner Curvature (BorderRadius 32px)
/// - Specular Light Highlight Rim (Border putih semi-transparan 1.2px)
/// - Active Tab Expanded Pill ("Today" style) dengan smooth spring transition
/// - Inactive Tab Circular Icon dengan Apple touch-down halo feedback
/// - Center Action (+) Coral Pill terintegrasi secara harmonis
class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onPostTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onPostTap,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  double _fabScale = 1.0;
  bool _isFabPressed = false;
  int? _pressedTabIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12302E).withValues(alpha: 0.08),
                offset: const Offset(0, 10),
                blurRadius: 28,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF12302E).withValues(alpha: 0.03),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.78),
                      Colors.white.withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tab 0: Home
                    _buildTabItem(
                      index: 0,
                      label: 'Home',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                    ),

                    // Tab 1: Hilang
                    _buildTabItem(
                      index: 1,
                      label: 'Hilang',
                      icon: Icons.search_rounded,
                      activeIcon: Icons.search_rounded,
                    ),

                    // Center Action: Coral (+) Buat Laporan
                    _buildCenterPostButton(),

                    // Tab 2: Ditemukan
                    _buildTabItem(
                      index: 2,
                      label: 'Ditemukan',
                      icon: Icons.check_circle_outline_rounded,
                      activeIcon: Icons.check_circle_rounded,
                    ),

                    // Tab 3: Profil
                    _buildTabItem(
                      index: 3,
                      label: 'Profil',
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Center Action (+) Coral Pill Button
  Widget _buildCenterPostButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _fabScale = 0.88;
          _isFabPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _fabScale = 1.0;
          _isFabPressed = false;
        });
        widget.onPostTap();
      },
      onTapCancel: () {
        setState(() {
          _fabScale = 1.0;
          _isFabPressed = false;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _fabScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.coral500,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral500.withValues(
                  alpha: _isFabPressed ? 0.65 : 0.40,
                ),
                offset: const Offset(0, 4),
                blurRadius: _isFabPressed ? 6 : 14,
                spreadRadius: _isFabPressed ? 0 : 1,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  /// Tab Item: Expanded Pill saat aktif, Circular Icon saat tidak aktif
  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = widget.currentIndex == index;
    final isPressed = _pressedTabIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedTabIndex = index),
      onTapUp: (_) {
        setState(() => _pressedTabIndex = null);
        widget.onTabSelected(index);
      },
      onTapCancel: () => setState(() => _pressedTabIndex = null),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 44,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 0,
            vertical: 0,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF17695D).withValues(alpha: 0.12)
                : (isPressed
                    ? const Color(0xFF17695D).withValues(alpha: 0.08)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(22),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF17695D).withValues(alpha: 0.20),
                    width: 1.0,
                  )
                : (isPressed
                    ? Border.all(
                        color: const Color(0xFF17695D).withValues(alpha: 0.15),
                        width: 1.0,
                      )
                    : null),
          ),
          child: isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      activeIcon,
                      color: const Color(0xFF17695D),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17695D),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(
                      icon,
                      color: isPressed
                          ? const Color(0xFF17695D)
                          : const Color(0xFF5E6E6A),
                      size: 22,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
