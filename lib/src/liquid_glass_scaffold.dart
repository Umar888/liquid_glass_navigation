import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'liquid_glass_nav_bar.dart';
import 'liquid_glass_nav_rail.dart';
import 'liquid_glass_style.dart';
import 'liquid_nav_item.dart';

/// An adaptive scaffold with Liquid Glass navigation.
///
/// Below [railBreakpoint] it shows a floating [LiquidGlassNavBar] with the
/// body scrolling behind it. At or above it, a [LiquidGlassNavRail] sits on
/// the left and the body is laid out next to it.
///
/// The body's `MediaQuery` bottom padding includes the bar, so scroll views
/// and `SafeArea` keep their last items clear of the glass.
class LiquidGlassScaffold extends StatelessWidget {
  /// Creates an adaptive glass scaffold.
  LiquidGlassScaffold({
    super.key,
    required this.body,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.mode = LiquidGlassMode.auto,
    this.style,
    this.showLabels = true,
    this.enableHaptics = true,
    this.railBreakpoint = 600,
    this.backgroundColor,
  })  : assert(items.length >= 2, 'Needs at least two items'),
        assert(
          currentIndex >= 0 && currentIndex < items.length,
          'currentIndex is out of range',
        );

  /// The page content. Works with an `IndexedStack` or a go_router
  /// `StatefulNavigationShell`.
  final Widget body;

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

  /// Width at which the bottom bar turns into a side rail. Defaults to 600.
  final double railBreakpoint;

  /// Background colour behind the body. Defaults to the theme's.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final resolved = ResolvedGlassStyle.of(context, mode, style);

    return Scaffold(
      backgroundColor: backgroundColor,
      // let the keyboard cover the bar like on iOS, inner scaffolds still resize
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          final margin = resolved.margin;
          final useRail = constraints.maxWidth >= railBreakpoint;

          final double bodyLeft;
          final MediaQueryData bodyMedia;
          final Widget navigation;
          if (useRail) {
            bodyLeft = margin.left + media.padding.left + resolved.railWidth;
            bodyMedia = media.copyWith(
              padding: media.padding.copyWith(left: 0),
              viewPadding: media.viewPadding.copyWith(left: 0),
            );
            navigation = Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: LiquidGlassNavRail(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap,
                mode: mode,
                style: style,
                showLabels: showLabels,
                enableHaptics: enableHaptics,
              ),
            );
          } else {
            final bottomGap = math.max(margin.bottom, media.padding.bottom);
            final bottomInset = resolved.barHeight + bottomGap + margin.top;
            bodyLeft = 0;
            bodyMedia = media.copyWith(
              padding: media.padding.copyWith(bottom: bottomInset),
              viewPadding: media.viewPadding.copyWith(bottom: bottomInset),
            );
            navigation = Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LiquidGlassNavBar(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap,
                mode: mode,
                style: style,
                showLabels: showLabels,
                enableHaptics: enableHaptics,
              ),
            );
          }

          // same tree shape in both layouts so the body keeps its state on resize
          return Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: bodyLeft),
                  child: MediaQuery(data: bodyMedia, child: body),
                ),
              ),
              navigation,
            ],
          );
        },
      ),
    );
  }
}
