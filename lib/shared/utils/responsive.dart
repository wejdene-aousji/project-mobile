import 'package:flutter/material.dart';

/// Responsive Design Utility
/// Helps determine device type and provide responsive values
class ResponsiveUtils {
  /// Mobile breakpoint - screens smaller than this are considered mobile
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint - screens between mobile and this are tablets
  static const double tabletBreakpoint = 1024;

  /// Desktop breakpoint - screens larger than this are desktop
  static const double desktopBreakpoint = 1440;

  /// Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if device is tablet (width between 600 and 1024)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if device is desktop (width >= 1024)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get device width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get device height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    tablet ??= mobile * 1.1;
    desktop ??= mobile * 1.2;

    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive columns for grid
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// Get responsive width for content
  static double getContentWidth(BuildContext context) {
    final width = getWidth(context);
    if (isDesktop(context)) {
      // Limit max width on desktop
      return width > 1200 ? 1200 : width;
    }
    return width;
  }
}
