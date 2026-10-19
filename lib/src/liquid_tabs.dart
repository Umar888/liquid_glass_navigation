import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_surface.dart';
import 'liquid_glass_style.dart';
import 'liquid_nav_item.dart';

/// Gap between the glass edge and the pill.
const double liquidTabsInset = 4;

const double _minLabelExtent = 56;
const double _minLabelCrossExtent = 52;
const double _maxLabelTextScale = 1.3;
const double _squash = 0.14;
const double _dragLift = 1.06;
const double _selectedIconScale = 1.08;
const double _iconSize = 24;
const double _labelGap = 2;
const Duration _liftDuration = Duration(milliseconds: 180);
const Duration _itemColorDuration = Duration(milliseconds: 220);
const Duration _iconScaleDuration = Duration(milliseconds: 320);
const Curve _leadCurve = Curves.easeOutBack;
const Curve _lagCurve = Interval(0.15, 1, curve: Curves.easeOutCubic);

/// Row or column of items with the stretchy, draggable selection pill.
class LiquidTabs extends StatefulWidget {
  const LiquidTabs({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.axis,
    required this.style,
    required this.showLabels,
    required this.enableHaptics,
  });

  final List<LiquidNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Axis axis;
  final ResolvedGlassStyle style;
  final bool showLabels;
  final bool enableHaptics;

  @override
  State<LiquidTabs> createState() => _LiquidTabsState();
}

class _LiquidTabsState extends State<LiquidTabs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.style.animationDuration,
    value: 1,
  );

  // pill position in item units while a drag is in progress
  final ValueNotifier<double?> _dragPosition = ValueNotifier<double?>(null);

  late (double, double) _from = (
    widget.currentIndex.toDouble(),
    widget.currentIndex.toDouble(),
  );
  late int _target = widget.currentIndex;
  int? _lastDragItem;
  double _itemExtent = 0;

  bool get _horizontal => widget.axis == Axis.horizontal;
  int get _lastIndex => widget.items.length - 1;

  @override
  void didUpdateWidget(LiquidTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.style.animationDuration;
    if (widget.items.length != oldWidget.items.length) {
      _from = (
        _from.$1.clamp(0, _lastIndex).toDouble(),
        _from.$2.clamp(0, _lastIndex).toDouble(),
      );
    }
    if (widget.currentIndex != oldWidget.currentIndex &&
        _dragPosition.value == null) {
      _moveTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragPosition.dispose();
    super.dispose();
  }

  /// Current pill span as `(min, max)` in item units.
  (double, double) get _extent {
    final drag = _dragPosition.value;
    if (drag != null) return (drag, drag);

    final t = _controller.value;
    final target = _target.toDouble();
    final (fromStart, fromEnd) = _from;
    final lead = _leadCurve.transform(t);
    final lag = _lagCurve.transform(t);

    // the edge facing the direction of travel leads, the other one catches up
    final double start;
    final double end;
    if (target >= fromStart) {
      end = _lerp(fromEnd, target, lead);
      start = _lerp(fromStart, target, lag);
    } else {
      start = _lerp(fromStart, target, lead);
      end = _lerp(fromEnd, target, lag);
    }
    final a = start.clamp(0, _lastIndex).toDouble();
    final b = end.clamp(0, _lastIndex).toDouble();
    return (math.min(a, b), math.max(a, b));
  }

  void _moveTo(int index) {
    if (index == _target && _controller.isAnimating) return;
    _from = _extent;
    _target = index;
    _controller.forward(from: 0);
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex && widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    widget.onTap(index);
  }

  double _dragUnits(Offset local) {
    if (_itemExtent <= 0) return widget.currentIndex.toDouble();
    final main = (_horizontal ? local.dx : local.dy) - liquidTabsInset;
    return (main / _itemExtent - 0.5).clamp(0, _lastIndex).toDouble();
  }

  void _onDragStart(DragStartDetails details) {
    _controller.stop();
    final position = _dragUnits(details.localPosition);
    _lastDragItem = position.round();
    setState(() => _dragPosition.value = position);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final position = _dragUnits(details.localPosition);
    _dragPosition.value = position;
    final item = position.round();
    if (item != _lastDragItem) {
      _lastDragItem = item;
      if (widget.enableHaptics) HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd([Object? _]) {
    final position = _dragPosition.value;
    if (position == null) return;
    final nearest = position.round();
    setState(() {
      _dragPosition.value = null;
      _lastDragItem = null;
    });
    // head back to the current item, if the parent accepts the new index
    // didUpdateWidget redirects the pill from wherever it is by then
    _from = (position, position);
    _target = widget.currentIndex;
    _controller.forward(from: 0);
    if (nearest != widget.currentIndex) widget.onTap(nearest);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return LayoutBuilder(
      builder: (context, constraints) {
        final mainSize =
            _horizontal ? constraints.maxWidth : constraints.maxHeight;
        final crossSize =
            _horizontal ? constraints.maxHeight : constraints.maxWidth;
        final inner = math.max(0.0, mainSize - liquidTabsInset * 2);
        final cross = math.max(0.0, crossSize - liquidTabsInset * 2);
        final itemExtent = inner / widget.items.length;
        _itemExtent = itemExtent;
        final labels = widget.showLabels &&
            itemExtent >= _minLabelExtent &&
            cross >= _minLabelCrossExtent;

        final pill = AnimatedScale(
          scale: _dragPosition.value != null ? _dragLift : 1,
          duration: _liftDuration,
          curve: Curves.easeOut,
          child: CustomPaint(
            painter: CapsulePainter(
              fill: style.indicatorColor,
              rim: style.isGlass
                  ? style.rimColor.withValues(alpha: style.rimColor.a * 0.7)
                  : null,
            ),
          ),
        );

        final items = Padding(
          padding: const EdgeInsets.all(liquidTabsInset),
          child: Flex(
            direction: widget.axis,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                Expanded(
                  child: _LiquidTabItem(
                    item: widget.items[i],
                    selected: i == widget.currentIndex,
                    showLabel: labels,
                    style: style,
                    onTap: () => _handleTap(i),
                  ),
                ),
            ],
          ),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _horizontal ? _onDragStart : null,
          onHorizontalDragUpdate: _horizontal ? _onDragUpdate : null,
          onHorizontalDragEnd: _horizontal ? _onDragEnd : null,
          onHorizontalDragCancel: _horizontal ? _onDragEnd : null,
          onVerticalDragStart: _horizontal ? null : _onDragStart,
          onVerticalDragUpdate: _horizontal ? null : _onDragUpdate,
          onVerticalDragEnd: _horizontal ? null : _onDragEnd,
          onVerticalDragCancel: _horizontal ? null : _onDragEnd,
          child: Stack(
            children: [
              // only the pill rebuilds per frame
              AnimatedBuilder(
                animation: Listenable.merge([_controller, _dragPosition]),
                child: pill,
                builder: (context, child) {
                  final (lo, hi) = _extent;
                  final stretch = (hi - lo).clamp(0.0, 1.0);
                  final thickness = cross * (1 - _squash * stretch);
                  final start = liquidTabsInset + lo * itemExtent;
                  final length = (hi - lo + 1) * itemExtent;
                  final crossStart = liquidTabsInset + (cross - thickness) / 2;
                  return Positioned(
                    left: _horizontal ? start : crossStart,
                    top: _horizontal ? crossStart : start,
                    width: _horizontal ? length : thickness,
                    height: _horizontal ? thickness : length,
                    child: child!,
                  );
                },
              ),
              Positioned.fill(child: items),
            ],
          ),
        );
      },
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

class _LiquidTabItem extends StatelessWidget {
  const _LiquidTabItem({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.style,
    required this.onTap,
  });

  final LiquidNavItem item;
  final bool selected;
  final bool showLabel;
  final ResolvedGlassStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = item.badge;
    Widget icon = Icon(
      selected ? (item.activeIcon ?? item.icon) : item.icon,
      size: _iconSize,
    );
    if (badge != null) {
      icon = Badge(
        label: badge.isEmpty ? null : Text(badge),
        child: icon,
      );
    }
    icon = AnimatedScale(
      scale: selected ? _selectedIconScale : 1,
      duration: _iconScaleDuration,
      curve: Curves.easeOutBack,
      child: icon,
    );

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: selected ? style.activeColor : style.inactiveColor,
              ),
              duration: _itemColorDuration,
              builder: (context, color, child) => IconTheme.merge(
                data: IconThemeData(color: color),
                child: DefaultTextStyle(
                  style: style.labelStyle.copyWith(color: color),
                  child: child!,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    if (showLabel) ...[
                      const SizedBox(height: _labelGap),
                      MediaQuery.withClampedTextScaling(
                        maxScaleFactor: _maxLabelTextScale,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
