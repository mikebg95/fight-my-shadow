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
/// Provides a premium, modern toast overlay that replaces default SnackBar.
/// Features smooth animations, glassmorphic design, and tap-to-dismiss.
class AppToast {
  static OverlayEntry? _currentOverlay;

  /// Shows a premium toast notification.
  ///
  /// [context] - Build context
  /// [message] - Message to display
  /// [type] - Toast type (error, success, info, warning)
  /// [duration] - How long to show before auto-dismiss (default 2000ms)
  /// [actionLabel] - Optional action button label
  /// [onAction] - Optional action button callback
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.error,
    Duration duration = const Duration(milliseconds: 2000),
    String? actionLabel,
    VoidCallback? onAction,
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
        actionLabel: actionLabel,
        onAction: onAction,
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
  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message, type: ToastType.error, actionLabel: actionLabel, onAction: onAction);
  }

  /// Convenience method for success toast
  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message, type: ToastType.success, actionLabel: actionLabel, onAction: onAction);
  }

  /// Convenience method for info toast
  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message, type: ToastType.info, actionLabel: actionLabel, onAction: onAction);
  }

  /// Convenience method for warning toast
  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message, type: ToastType.warning, actionLabel: actionLabel, onAction: onAction);
  }
}

/// Modern toast overlay widget with animations
class _AppToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _AppToastOverlay({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

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
        return Icons.error_rounded;
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
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
              // Dismiss on tap
              _controller.reverse().then((_) => widget.onDismiss());
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Message text
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Action button or close icon
                    if (widget.actionLabel != null && widget.onAction != null)
                      GestureDetector(
                        onTap: () {
                          widget.onAction!();
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
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
