import 'dart:ui';

import 'package:flutter/material.dart';

/// Foreground colors tuned for readability on [GreenGlassCard] in light and dark mode.
abstract final class GreenGlassCardColors {
  /// Headings and primary copy.
  static Color primaryOnCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF4FAF6)
        : const Color(0xFF1A2520);
  }

  /// Subtitles and secondary copy.
  static Color secondaryOnCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD4E5DA)
        : const Color(0xFF2A3830);
  }

  /// Meta lines, captions, hints.
  static Color tertiaryOnCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFADC2B6)
        : const Color(0xFF3D5246);
  }
}

/// Full-screen background image with a scrim so photos read softer behind UI.
class MindBloomBackdrop extends StatelessWidget {
  const MindBloomBackdrop({
    super.key,
    required this.assetPath,
    required this.child,
  });

  final String assetPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> overlayColors = isDark
        ? [
            const Color(0xFF121814).withValues(alpha: 0.68),
            const Color(0xFF121814).withValues(alpha: 0.78),
            const Color(0xFF121814).withValues(alpha: 0.86),
          ]
        : [
            const Color(0xFFF7F3EC).withValues(alpha: 0.52),
            const Color(0xFFF7F3EC).withValues(alpha: 0.68),
            const Color(0xFFF7F3EC).withValues(alpha: 0.82),
          ];

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: overlayColors,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Green-tinted glass surface; adapts slightly for dark mode.
class GreenGlassCard extends StatelessWidget {
  const GreenGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  static const Color _brandGreen = Color(0xFF6E8B74);
  static const Color _sage = Color(0xFFEAF1E7);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> gradientColors = isDark
        ? [
            const Color(0xFF3D4A44).withValues(alpha: 0.82),
            const Color(0xFF323E38).withValues(alpha: 0.86),
            const Color(0xFF36423C).withValues(alpha: 0.80),
            _brandGreen.withValues(alpha: 0.32),
          ]
        : [
            Colors.white.withValues(alpha: 0.80),
            _sage.withValues(alpha: 0.76),
            Colors.white.withValues(alpha: 0.72),
            _brandGreen.withValues(alpha: 0.15),
          ];

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.34)
        : Colors.white.withValues(alpha: 0.82);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: borderColor,
              width: 1.25,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF1E2A22))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _brandGreen.withValues(alpha: isDark ? 0.12 : 0.14),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
