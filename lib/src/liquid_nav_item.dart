import 'package:flutter/widgets.dart';

/// A single destination in a `LiquidGlassNavBar` or `LiquidGlassNavRail`.
@immutable
class LiquidNavItem {
  /// Creates a navigation destination.
  const LiquidNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });

  /// Icon shown when the item is not selected.
  final IconData icon;

  /// Icon shown when the item is selected. Falls back to [icon].
  final IconData? activeIcon;

  /// Text label, also used for semantics.
  final String label;

  /// Badge on the icon. `null` hides it, an empty string shows a dot,
  /// anything else is shown as text.
  final String? badge;

  @override
  bool operator ==(Object other) =>
      other is LiquidNavItem &&
      other.icon == icon &&
      other.activeIcon == activeIcon &&
      other.label == label &&
      other.badge == badge;

  @override
  int get hashCode => Object.hash(icon, activeIcon, label, badge);
}
