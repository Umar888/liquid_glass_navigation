import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glass_surface.dart';
import 'liquid_glass_style.dart';
import 'liquid_nav_item.dart';
import 'liquid_tabs.dart';

/// A floating Liquid Glass navigation rail for tablets and desktop.
///
/// A vertical capsule on the left edge, centred vertically. Place it in a
/// [Row] or [Stack] next to your content, or let `LiquidGlassScaffold` do it.
class LiquidGlassNavRail extends StatelessWidget {
  /// Creates a floating glass side rail.
  LiquidGlassNavRail({
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
    final naturalHeight =
        items.length * resolved.itemExtent + liquidTabsInset * 2;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        margin.left + safe.left,
        margin.top + safe.top,
        0,
        math.max(margin.bottom, safe.bottom),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          widthFactor: 1,
          child: SizedBox(
            width: resolved.railWidth,
            height: math.min(naturalHeight, constraints.maxHeight),
            child: GlassSurface(
              style: resolved,
              child: LiquidTabs(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap,
                axis: Axis.vertical,
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
