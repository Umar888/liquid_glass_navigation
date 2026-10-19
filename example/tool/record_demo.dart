// Plays a scripted walkthrough of the demo for recording the README GIF.
//   flutter run -t tool/record_demo.dart
// Touches go through the normal gesture pipeline, so nothing extra is drawn.
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_navigation_example/main.dart';

void main() {
  runApp(const DemoApp());
  unawaited(_play());
}

final _clock = Stopwatch()..start();
int _pointer = 100;

Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void _send(PointerEvent event) =>
    GestureBinding.instance.handlePointerEvent(event);

Duration get _now => _clock.elapsed;

/// Center of the lowest on-screen [Text] showing [label], so nav labels win
/// over app bar titles.
Offset _find(String label) {
  Offset? best;
  void visit(Element element) {
    final widget = element.widget;
    if (widget is Text && widget.data == label) {
      final box = element.renderObject;
      if (box is RenderBox && box.attached && box.hasSize) {
        final center = box.localToGlobal(box.size.center(Offset.zero));
        if (best == null || center.dy > best!.dy) best = center;
      }
    }
    element.visitChildElements(visit);
  }

  WidgetsBinding.instance.rootElement!.visitChildElements(visit);
  return best!;
}

Future<void> _tap(String label) async {
  final at = _find(label);
  final p = _pointer++;
  _send(PointerDownEvent(pointer: p, position: at, timeStamp: _now));
  await _wait(70);
  _send(PointerUpEvent(pointer: p, position: at, timeStamp: _now));
}

Future<void> _swipe(Offset from, Offset to, int ms, {int holdMs = 0}) async {
  const frame = 16;
  final p = _pointer++;
  var last = from;
  _send(PointerDownEvent(pointer: p, position: from, timeStamp: _now));
  await _wait(holdMs);
  final steps = ms ~/ frame;
  for (var i = 1; i <= steps; i++) {
    final next = Offset.lerp(from, to, Curves.easeInOut.transform(i / steps))!;
    _send(PointerMoveEvent(
      pointer: p,
      position: next,
      delta: next - last,
      timeStamp: _now,
    ));
    last = next;
    await _wait(frame);
  }
  _send(PointerUpEvent(pointer: p, position: to, timeStamp: _now));
}

Future<void> _play() async {
  await _wait(2500);
  final size = WidgetsBinding.instance.platformDispatcher.views.first;
  final screen = size.physicalSize / size.devicePixelRatio;
  final high = Offset(screen.width / 2, screen.height * 0.3);
  final low = Offset(screen.width / 2, screen.height * 0.7);

  // scroll so the cards slide under the glass
  await _swipe(low, high, 900);
  await _wait(1000);
  await _swipe(high, low, 700);
  await _wait(800);

  await _tap('Explore');
  await _wait(1100);
  await _swipe(low, high, 900);
  await _wait(900);

  await _tap('Inbox');
  await _wait(1200);

  // scrub along the bar
  await _swipe(_find('Inbox'), _find('Today'), 900, holdMs: 120);
  await _wait(1000);
  await _swipe(_find('Today'), _find('Settings'), 1100, holdMs: 120);
  await _wait(1200);

  await _tap('Dark mode');
  await _wait(1300);

  await _tap('Explore');
  await _wait(1000);
  await _tap('Today');
  await _wait(1000);
  await _swipe(low, high, 900);
  await _wait(1800);
  debugPrint('DEMO_DONE');
}
