import 'package:flutter/material.dart';

/// Breakpoint constants for responsive design.
class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
}

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobileMax;

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobileMax &&
        width < ResponsiveBreakpoints.tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tabletMax;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobileMax;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= ResponsiveBreakpoints.tabletMax) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.mobileMax) {
      return tablet ?? desktop ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// A wrapper widget that centers its child and constrains its max width
/// for optimal readability on desktop and tablet screens.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
