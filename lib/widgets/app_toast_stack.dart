import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

/// Tipe Notifikasi Toast Stack
enum ToastType {
  success,
  info,
  warning,
  error,
}

/// Data Model Toast Item
class AppToastItem {
  final String id;
  final String message;
  final String? title;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;

  AppToastItem({
    required this.id,
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(milliseconds: 3600),
  });
}

/// Controller Global Toast Stack khas Motion.dev & Apple Design
class AppToast {
  static final AppToast _instance = AppToast._internal();
  factory AppToast() => _instance;
  AppToast._internal();

  static OverlayEntry? _overlayEntry;
  static final List<AppToastItem> _toasts = [];
  static void Function(VoidCallback)? _rebuildOverlay;

  /// Tampilkan Toast Stack Global dari halaman manapun
  static void show(
    BuildContext? context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3600),
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final item = AppToastItem(
      id: id,
      message: message,
      title: title,
      type: type,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );

    _addToast(context, item);
  }

  /// Shortcut Sukses (Aksen Teal Apple)
  static void success(
    BuildContext? context, {
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shortcut Informasi (Aksen Biru Langit Apple)
  static void info(
    BuildContext? context, {
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shortcut Peringatan (Aksen Amber)
  static void warning(
    BuildContext? context, {
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shortcut Error / Ditarik (Aksen Coral)
  static void error(
    BuildContext? context, {
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _addToast(BuildContext? context, AppToastItem item) {
    // Batasi stack maksimal 3 card (Motion.dev physical stack)
    if (_toasts.length >= 3) {
      _toasts.removeAt(0);
    }
    _toasts.add(item);

    _ensureOverlay(context);
    _rebuildOverlay?.call(() {});

    // Jadwalkan auto dismiss
    Timer(item.duration, () {
      _removeToast(item.id);
    });
  }

  static void _removeToast(String id) {
    _toasts.removeWhere((t) => t.id == id);
    if (_toasts.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _rebuildOverlay = null;
    } else {
      _rebuildOverlay?.call(() {});
    }
  }

  static void _ensureOverlay(BuildContext? context) {
    if (_overlayEntry != null) return;

    OverlayState? overlay;
    if (context != null && context.mounted) {
      try {
        overlay = Navigator.of(context, rootNavigator: true).overlay ??
            Overlay.maybeOf(context);
      } catch (_) {}
    }
    overlay ??= FindITCampusApp.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return StatefulBuilder(
          builder: (builderCtx, setState) {
            _rebuildOverlay = setState;
            if (_toasts.isEmpty) return const SizedBox.shrink();

            return _ToastStackLayer(
              toasts: List.unmodifiable(_toasts),
              onDismiss: (id) => _removeToast(id),
            );
          },
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }
}

/// Widget Layer Toast Stack Fisik Motion.dev
class _ToastStackLayer extends StatelessWidget {
  final List<AppToastItem> toasts;
  final ValueChanged<String> onDismiss;

  const _ToastStackLayer({
    required this.toasts,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    // Mengambang tepat di atas floating capsule bottom navigation (104px dari bawah)
    final bottomInset = media.padding.bottom + 104.0;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset, left: 16, right: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440, // Lebar proporsional pas di HP / Tablet
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Render dari toast terlama (paling belakang) ke terbaru (paling depan)
                for (int i = 0; i < toasts.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final toast = toasts[i];
                      // Depth: 0 untuk card paling depan (terbaru), 1 untuk tengah, 2 paling belakang
                      final depth = toasts.length - 1 - i;
                      final targetScale = 1.0 - (depth * 0.055);
                      final targetOpacity =
                          (1.0 - (depth * 0.16)).clamp(0.0, 1.0);

                      return AnimatedSlide(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        offset: Offset(0, -(depth * 0.22)),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          scale: targetScale,
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            opacity: targetOpacity,
                            child: _StackedToastCard(
                              key: ValueKey(toast.id),
                              toast: toast,
                              depth: depth,
                              onDismiss: () => onDismiss(toast.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu Toast Individual dengan Apple Glassy Blur & Motion Spring Physics
class _StackedToastCard extends StatelessWidget {
  final AppToastItem toast;
  final int depth;
  final VoidCallback onDismiss;

  const _StackedToastCard({
    super.key,
    required this.toast,
    required this.depth,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color iconBg;
    IconData iconData;

    switch (toast.type) {
      case ToastType.success:
        iconColor = const Color(0xFF2DD4BF);
        iconBg = const Color(0xFF0F766E).withValues(alpha: 0.35);
        iconData = Icons.check_circle_rounded;
        break;
      case ToastType.info:
        iconColor = const Color(0xFF38BDF8);
        iconBg = const Color(0xFF0369A1).withValues(alpha: 0.35);
        iconData = Icons.info_outline_rounded;
        break;
      case ToastType.warning:
        iconColor = const Color(0xFFFBBF24);
        iconBg = const Color(0xFFB45309).withValues(alpha: 0.35);
        iconData = Icons.warning_amber_rounded;
        break;
      case ToastType.error:
        iconColor = const Color(0xFFF87171);
        iconBg = const Color(0xFFB91C1C).withValues(alpha: 0.35);
        iconData = Icons.error_outline_rounded;
        break;
    }

    return Dismissible(
      key: ValueKey(toast.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF041412).withValues(
                  alpha: depth == 0 ? 0.32 : 0.16,
                ),
                offset: Offset(0, depth == 0 ? 10 : 4),
                blurRadius: depth == 0 ? 28 : 14,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132724).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Leading Squircle Icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text Content (Title & Message)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (toast.title != null) ...[
                            Text(
                              toast.title!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1.5),
                          ],
                          Text(
                            toast.message,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: toast.title != null
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: toast.title != null
                                  ? Colors.white.withValues(alpha: 0.88)
                                  : Colors.white,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Optional Tactile Action Button
                    if (toast.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          toast.onAction?.call();
                          onDismiss();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 5.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17695D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF17695D)
                                    .withValues(alpha: 0.40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            toast.actionLabel!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Close Dismiss Button
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
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
}
