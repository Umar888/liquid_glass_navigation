import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// How the glass surface is rendered.
enum LiquidGlassMode {
  /// [glass] on iOS and macOS, [frosted] everywhere else.
  auto,

  /// Clear, light blur with a bright rim and sheen, like iOS 26.
  glass,

  /// Denser Material tinted blur. Cheaper and calmer on low-end Android.
  frosted,
}

/// Visual overrides for the bar and the rail.
///
/// Every field is optional. Anything left `null` is derived from the ambient
/// [Theme] and the resolved [LiquidGlassMode].
@immutable
class LiquidGlassStyle {
  /// Creates a style. All values are optional.
  const LiquidGlassStyle({
    this.tintColor,
    this.blurSigma,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.rimColor,
    this.shadows,
    this.labelStyle,
    this.barHeight,
    this.railWidth,
    this.itemExtent,
    this.margin,
    this.maxBarWidth,
    this.animationDuration,
  });

  /// Fill colour of the glass, usually translucent.
  final Color? tintColor;

  /// Sigma of the backdrop blur.
  final double? blurSigma;

  /// Colour of the selected icon and label.
  final Color? activeColor;

  /// Colour of unselected icons and labels.
  final Color? inactiveColor;

  /// Fill colour of the selection pill.
  final Color? indicatorColor;

  /// Colour of the thin highlight around the edge.
  final Color? rimColor;

  /// Shadows drawn outside the capsule only, so they never darken the glass.
  final List<BoxShadow>? shadows;

  /// Merged on top of the default label style.
  final TextStyle? labelStyle;

  /// Height of the bottom bar. Defaults to 64.
  final double? barHeight;

  /// Width of the side rail. Defaults to 76.
  final double? railWidth;

  /// Height of each rail item. Defaults to 64.
  final double? itemExtent;

  /// Gap around the floating surface. The bar uses left, right and bottom,
  /// the rail uses left, top and bottom. Defaults to `EdgeInsets.fromLTRB(16, 16, 16, 12)`.
  final EdgeInsets? margin;

  /// Maximum width of the bottom bar. Defaults to 520.
  final double? maxBarWidth;

  /// Duration of the pill animation. Defaults to 520ms.
  final Duration? animationDuration;

  /// Returns a copy with the given fields replaced.
  LiquidGlassStyle copyWith({
    Color? tintColor,
    double? blurSigma,
    Color? activeColor,
    Color? inactiveColor,
    Color? indicatorColor,
    Color? rimColor,
    List<BoxShadow>? shadows,
    TextStyle? labelStyle,
    double? barHeight,
    double? railWidth,
    double? itemExtent,
    EdgeInsets? margin,
    double? maxBarWidth,
    Duration? animationDuration,
  }) {
    return LiquidGlassStyle(
      tintColor: tintColor ?? this.tintColor,
      blurSigma: blurSigma ?? this.blurSigma,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      rimColor: rimColor ?? this.rimColor,
      shadows: shadows ?? this.shadows,
      labelStyle: labelStyle ?? this.labelStyle,
      barHeight: barHeight ?? this.barHeight,
      railWidth: railWidth ?? this.railWidth,
      itemExtent: itemExtent ?? this.itemExtent,
      margin: margin ?? this.margin,
      maxBarWidth: maxBarWidth ?? this.maxBarWidth,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiquidGlassStyle &&
      other.tintColor == tintColor &&
      other.blurSigma == blurSigma &&
      other.activeColor == activeColor &&
      other.inactiveColor == inactiveColor &&
      other.indicatorColor == indicatorColor &&
      other.rimColor == rimColor &&
      listEquals(other.shadows, shadows) &&
      other.labelStyle == labelStyle &&
      other.barHeight == barHeight &&
      other.railWidth == railWidth &&
      other.itemExtent == itemExtent &&
      other.margin == margin &&
      other.maxBarWidth == maxBarWidth &&
      other.animationDuration == animationDuration;

  @override
  int get hashCode => Object.hash(
        tintColor,
        blurSigma,
        activeColor,
        inactiveColor,
        indicatorColor,
        rimColor,
        shadows == null ? null : Object.hashAll(shadows!),
        labelStyle,
        barHeight,
        railWidth,
        itemExtent,
        margin,
        maxBarWidth,
        animationDuration,
      );
}

/// A [LiquidGlassStyle] with every value filled in. Internal.
@immutable
class ResolvedGlassStyle {
  const ResolvedGlassStyle({
    required this.isGlass,
    required this.tintColor,
    required this.blurSigma,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    required this.rimColor,
    required this.shadows,
    required this.labelStyle,
    required this.barHeight,
    required this.railWidth,
    required this.itemExtent,
    required this.margin,
    required this.maxBarWidth,
    required this.animationDuration,
  });

  static const double defaultBarHeight = 64;
  static const double defaultRailWidth = 76;
  static const double defaultItemExtent = 64;
  static const EdgeInsets defaultMargin = EdgeInsets.fromLTRB(16, 16, 16, 12);
  static const double defaultMaxBarWidth = 520;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 520);

  static const double _glassBlur = 18;
  static const double _frostedBlur = 12;
  static const double _labelFontSize = 11;
  static const double _shadowBlur = 30;
  static const Offset _shadowOffset = Offset(0, 10);
  static const Color _darkGlassBase = Color(0xFF1C1C1E);

  /// True when the clear glass look is used, false for frosted.
  final bool isGlass;
  final Color tintColor;
  final double blurSigma;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final Color rimColor;
  final List<BoxShadow> shadows;
  final TextStyle labelStyle;
  final double barHeight;
  final double railWidth;
  final double itemExtent;
  final EdgeInsets margin;
  final double maxBarWidth;
  final Duration animationDuration;

  /// Picks glass or frosted for [mode] on the current platform.
  static bool resolveIsGlass(BuildContext context, LiquidGlassMode mode) {
    switch (mode) {
      case LiquidGlassMode.glass:
        return true;
      case LiquidGlassMode.frosted:
        return false;
      case LiquidGlassMode.auto:
        final platform = Theme.of(context).platform;
        return platform == TargetPlatform.iOS ||
            platform == TargetPlatform.macOS;
    }
  }

  /// Fills every null in [style] from the ambient theme.
  static ResolvedGlassStyle of(
    BuildContext context,
    LiquidGlassMode mode,
    LiquidGlassStyle? style,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final glass = resolveIsGlass(context, mode);
    final s = style ?? const LiquidGlassStyle();

    final Color tint;
    final Color indicator;
    final Color rim;
    if (glass) {
      tint = dark
          ? _darkGlassBase.withValues(alpha: 0.42)
          : Colors.white.withValues(alpha: 0.5);
      indicator = dark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.black.withValues(alpha: 0.06);
      rim = Colors.white.withValues(alpha: dark ? 0.28 : 0.85);
    } else {
      tint = scheme.surfaceContainer.withValues(alpha: 0.86);
      indicator = scheme.secondaryContainer;
      rim = scheme.outlineVariant.withValues(alpha: 0.6);
    }

    final baseLabel = (theme.textTheme.labelSmall ?? const TextStyle())
        .copyWith(fontSize: _labelFontSize, fontWeight: FontWeight.w600);

    return ResolvedGlassStyle(
      isGlass: glass,
      tintColor: s.tintColor ?? tint,
      blurSigma: s.blurSigma ?? (glass ? _glassBlur : _frostedBlur),
      activeColor: s.activeColor ?? scheme.primary,
      inactiveColor: s.inactiveColor ??
          scheme.onSurface.withValues(alpha: glass ? 0.62 : 0.7),
      indicatorColor: s.indicatorColor ?? indicator,
      rimColor: s.rimColor ?? rim,
      shadows: s.shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.4 : 0.12),
              blurRadius: _shadowBlur,
              offset: _shadowOffset,
            ),
          ],
      labelStyle: baseLabel.merge(s.labelStyle),
      barHeight: s.barHeight ?? defaultBarHeight,
      railWidth: s.railWidth ?? defaultRailWidth,
      itemExtent: s.itemExtent ?? defaultItemExtent,
      margin: s.margin ?? defaultMargin,
      maxBarWidth: s.maxBarWidth ?? defaultMaxBarWidth,
      animationDuration: s.animationDuration ?? defaultAnimationDuration,
    );
  }
}
