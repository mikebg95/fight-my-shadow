import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Responsive utilities for consistent scaling across all device sizes.
///
/// Provides helpers for:
/// - Screen size detection (small phone, normal phone, tablet)
/// - Responsive font sizing with clamped values
/// - Responsive spacing that adapts to screen width
/// - Safe area calculations
class Responsive {
  // Private constructor - use static methods
  Responsive._();

  // Reference design width (iPhone 13/14/15 baseline)
  static const double _referenceWidth = 390.0;

  // Breakpoints
  static const double smallPhoneWidth = 360.0;  // iPhone SE, older small phones
  static const double normalPhoneWidth = 390.0; // iPhone 13/14/15
  static const double largePhoneWidth = 430.0;  // iPhone Pro Max
  static const double tabletWidth = 600.0;      // iPad and larger

  /// Returns the screen width from MediaQuery
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the screen height from MediaQuery
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns true if device is a small phone (width < 360)
  static bool isSmallPhone(BuildContext context) {
    return screenWidth(context) < smallPhoneWidth;
  }

  /// Returns true if device is a very small phone (width < 330, e.g., iPhone SE)
  static bool isVerySmallPhone(BuildContext context) {
    return screenWidth(context) < 330;
  }

  /// Returns true if device is a normal phone (360-430)
  static bool isPhone(BuildContext context) {
    final width = screenWidth(context);
    return width >= smallPhoneWidth && width < tabletWidth;
  }

  /// Returns true if device is a large phone (width >= 430)
  static bool isLargePhone(BuildContext context) {
    final width = screenWidth(context);
    return width >= largePhoneWidth && width < tabletWidth;
  }

  /// Returns true if device is a tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= tabletWidth;
  }

  /// Returns a scale factor based on screen width, clamped to prevent extremes.
  ///
  /// The scale factor is 1.0 at the reference width (390px).
  /// Clamped between [minScale] and [maxScale] to prevent tiny/huge UI.
  static double scaleFactor(
    BuildContext context, {
    double minScale = 0.85,
    double maxScale = 1.15,
  }) {
    final width = screenWidth(context);
    final rawScale = width / _referenceWidth;
    return rawScale.clamp(minScale, maxScale);
  }

  /// Returns a responsive font size.
  ///
  /// [baseSize] is the font size at reference width (390px).
  /// The font is scaled proportionally but clamped to prevent extremes.
  ///
  /// Example: rf(context, 16) returns ~14 on iPhone SE, ~16 on iPhone 14, ~17 on Pro Max
  static double rf(BuildContext context, double baseSize) {
    // Calculate a more gentle scale for fonts
    final scale = scaleFactor(context, minScale: 0.88, maxScale: 1.1);
    return baseSize * scale;
  }

  /// Returns a responsive spacing value.
  ///
  /// [baseSpacing] is the spacing at reference width (390px).
  /// Scaled proportionally with clamping.
  ///
  /// Example: rs(context, 20) returns ~17 on iPhone SE, ~20 on iPhone 14
  static double rs(BuildContext context, double baseSpacing) {
    final scale = scaleFactor(context, minScale: 0.85, maxScale: 1.12);
    return baseSpacing * scale;
  }

  /// Returns responsive horizontal padding.
  ///
  /// Standard padding is 20px. Reduced on small screens.
  static double horizontalPadding(BuildContext context) {
    if (isVerySmallPhone(context)) return 14;
    if (isSmallPhone(context)) return 16;
    return 20;
  }

  /// Returns responsive icon size.
  ///
  /// [baseSize] is the icon size at reference width.
  static double iconSize(BuildContext context, double baseSize) {
    final scale = scaleFactor(context, minScale: 0.9, maxScale: 1.1);
    return baseSize * scale;
  }

  /// Returns responsive button height.
  ///
  /// Standard button height is 64px. Slightly smaller on small screens.
  static double buttonHeight(BuildContext context) {
    if (isVerySmallPhone(context)) return 52;
    if (isSmallPhone(context)) return 56;
    return 64;
  }

  /// Returns responsive card padding.
  static EdgeInsets cardPadding(BuildContext context) {
    final base = rs(context, 16);
    return EdgeInsets.all(base);
  }

  /// Returns responsive section padding.
  static EdgeInsets sectionPadding(BuildContext context) {
    final horizontal = horizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  /// Returns a constrained max width for content (useful for tablets).
  static double maxContentWidth(BuildContext context) {
    if (isTablet(context)) {
      return 600; // Limit content width on tablets
    }
    return screenWidth(context);
  }

  /// Returns clamped font size that won't go below [min] or above [max].
  static double clampedFontSize(
    BuildContext context,
    double baseSize, {
    double? min,
    double? max,
  }) {
    final scaled = rf(context, baseSize);
    final minSize = min ?? baseSize * 0.75;
    final maxSize = max ?? baseSize * 1.25;
    return scaled.clamp(minSize, maxSize);
  }
}

/// Extension methods for responsive text styles.
extension ResponsiveTextStyle on TextStyle {
  /// Returns this text style with responsive font size.
  TextStyle responsive(BuildContext context) {
    if (fontSize == null) return this;
    return copyWith(fontSize: Responsive.rf(context, fontSize!));
  }

  /// Returns this text style with clamped responsive font size.
  TextStyle responsiveClamped(BuildContext context, {double? min, double? max}) {
    if (fontSize == null) return this;
    return copyWith(
      fontSize: Responsive.clampedFontSize(context, fontSize!, min: min, max: max),
    );
  }
}

/// Widget that wraps content with responsive constraints.
///
/// Use this to constrain content width on tablets while allowing
/// full width on phones.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A responsive text widget that automatically handles overflow.
///
/// Useful for titles that should stay on one line but shrink if needed.
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool useFittedBox;
  final double? minFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.useFittedBox = false,
    this.minFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: maxLines > 1,
    );

    if (useFittedBox) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: textAlign == TextAlign.center
            ? Alignment.center
            : Alignment.centerLeft,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
