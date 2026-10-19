import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glass_surface.dart';
import 'liquid_glass_style.dart';
import 'liquid_nav_item.dart';
import 'liquid_tabs.dart';

/// A floating Liquid Glass bottom navigation bar.
///
/// Works as `Scaffold.bottomNavigationBar`. Set `extendBody: true` on the
/// `Scaffold` so content scrolls behind the glass. For a bar that turns into
/// a rail on wide screens, use `LiquidGlassScaffold`.
class LiquidGlassNavBar extends StatelessWidget {
  /// Creates a floating glass bottom bar.
  LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.mode = LiquidGlassMode.auto,
    this.style,
    this.showLabels = true,
    this.enableHaptics = true,
  })  : assert(items.length >= 2, 'Needs at least two items'),
        assert(
          currentIndex >= 0 && currentIndex < items.length,
          'currentIndex is out of range',
        );

  /// The destinations, at least two.
  final List<LiquidNavItem> items;

  /// Index of the selected item.
  final int currentIndex;

  /// Called with the index of a tapped or drag-selected item.
  final ValueChanged<int> onTap;

  /// Glass or frosted rendering. Defaults to [LiquidGlassMode.auto].
  final LiquidGlassMode mode;

  /// Optional visual overrides.
  final LiquidGlassStyle? style;

  /// Whether to show labels under the icons when there's room.
  final bool showLabels;

  /// Whether selection changes play a selection click.
  final bool enableHaptics;

  @override
  Widget build(BuildContext context) {
    final resolved = ResolvedGlassStyle.of(context, mode, style);
    final safe = MediaQuery.paddingOf(context);
    final margin = resolved.margin;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        margin.left + safe.left,
        0,
        margin.right + safe.right,
        math.max(margin.bottom, safe.bottom),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: resolved.maxBarWidth),
          child: SizedBox(
            width: double.infinity,
            height: resolved.barHeight,
            child: GlassSurface(
              style: resolved,
              child: LiquidTabs(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap,
                axis: Axis.horizontal,
                style: resolved,
                showLabels: showLabels,
                enableHaptics: enableHaptics,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
