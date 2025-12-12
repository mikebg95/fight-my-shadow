import 'package:flutter/material.dart';

/// Toast type determines the color scheme and icon
enum ToastType {
  error,
  success,
  info,
  warning,
}

/// Centralized toast/snackbar utility for the app.
///
/// Provides a clean, minimal, purely informational toast notification.
/// Features smooth slide-up animation and subtle tinted background.
/// No action buttons - just calm, non-intrusive messaging.
class AppToast {
  static OverlayEntry? _currentOverlay;

  /// Shows a purely informational toast notification.
  ///
  /// [context] - Build context
  /// [message] - Message to display (sentence case, single sentence)
  /// [type] - Toast type (error, success, info, warning)
  /// [duration] - How long to show before auto-dismiss (default 2500ms)
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    // Remove existing overlay if present
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Create new overlay entry
    late OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        message: message,
        type: type,
        onDismiss: () {
          overlay.remove();
          _currentOverlay = null;
        },
      ),
    );

    // Store reference and insert
    _currentOverlay = overlay;
    Overlay.of(context).insert(overlay);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_currentOverlay == overlay) {
        overlay.remove();
        _currentOverlay = null;
      }
    });
  }

  /// Convenience method for error toast
  static void error(BuildContext context, String message) {
    show(context, message, type: ToastType.error);
  }

  /// Convenience method for success toast
  static void success(BuildContext context, String message) {
    show(context, message, type: ToastType.success);
  }

  /// Convenience method for info toast
  static void info(BuildContext context, String message) {
    show(context, message, type: ToastType.info);
  }

  /// Convenience method for warning toast
  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastType.warning);
  }
}

/// Minimal informational toast overlay with slide-up animation
class _AppToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _AppToastOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Slide up from below
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case ToastType.error:
        return const Color(0xFFD32F2F); // Red
      case ToastType.success:
        return const Color(0xFF388E3C); // Green
      case ToastType.info:
        return const Color(0xFF1976D2); // Blue
      case ToastType.warning:
        return const Color(0xFFF57C00); // Orange
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.error:
        return Icons.info_outline_rounded;
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
      case ToastType.warning:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: RepaintBoundary(
                child: child!,
              ),
            );
          },
          child: GestureDetector(
            onTap: () {
              // Tap to dismiss
              _controller.reverse().then((_) => widget.onDismiss());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                // Subtle tinted background (10-15% opacity)
                color: isDark
                    ? themeColor.withValues(alpha: 0.15)
                    : themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Small muted icon
                  Icon(
                    _getIcon(),
                    color: themeColor.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  // Message text
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.black.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        height: 1.4,
                      ),
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
