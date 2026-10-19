import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_navigation/liquid_glass_navigation.dart';

const _items = [
  LiquidNavItem(
      icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  LiquidNavItem(icon: Icons.search, label: 'Search'),
  LiquidNavItem(icon: Icons.inbox_outlined, label: 'Inbox', badge: '3'),
  LiquidNavItem(icon: Icons.settings_outlined, label: 'Settings'),
];

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// A scaffold that owns the index, like a real app would.
class _Host extends StatefulWidget {
  const _Host({this.items = _items, this.onTap});

  final List<LiquidNavItem> items;
  final ValueChanged<int>? onTap;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LiquidGlassScaffold(
        items: widget.items,
        currentIndex: _index,
        onTap: (i) {
          widget.onTap?.call(i);
          setState(() => _index = i);
        },
        body: Center(child: Text('page $_index')),
      ),
    );
  }
}

void main() {
  testWidgets('bar renders labels and taps report the right index',
      (tester) async {
    _setSize(tester, const Size(400, 800));
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: LiquidGlassNavBar(
            items: _items,
            currentIndex: 0,
            onTap: taps.add,
          ),
        ),
      ),
    );

    for (final item in _items) {
      expect(find.text(item.label), findsOneWidget);
    }
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.tap(find.text('Search'));
    expect(taps, [2, 1]);
  });

  testWidgets('scaffold shows the bar when narrow and the rail when wide',
      (tester) async {
    _setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const _Host());
    expect(find.byType(LiquidGlassNavBar), findsOneWidget);
    expect(find.byType(LiquidGlassNavRail), findsNothing);

    _setSize(tester, const Size(1000, 800));
    await tester.pumpAndSettle();
    expect(find.byType(LiquidGlassNavBar), findsNothing);
    expect(find.byType(LiquidGlassNavRail), findsOneWidget);
  });

  testWidgets('scaffold pads the body for the bar', (tester) async {
    _setSize(tester, const Size(400, 800));
    late EdgeInsets padding;
    await tester.pumpWidget(
      MaterialApp(
        home: LiquidGlassScaffold(
          items: _items,
          currentIndex: 0,
          onTap: (_) {},
          body: Builder(
            builder: (context) {
              padding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    // bar height 64 + bottom margin 12 + top margin 16
    expect(padding.bottom, 92);
  });

  testWidgets('tapping through the scaffold moves the selection',
      (tester) async {
    _setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const _Host());
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('page 3'), findsOneWidget);
  });

  testWidgets('dragging across the bar selects the last item', (tester) async {
    _setSize(tester, const Size(400, 800));
    final taps = <int>[];
    await tester.pumpWidget(_Host(onTap: taps.add));

    final start = tester.getCenter(find.text('Home'));
    final end = tester.getCenter(find.text('Settings'));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveTo(end + const Offset(40, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(taps, [3]);
    expect(find.text('page 3'), findsOneWidget);
  });

  testWidgets('labels hide when items are too narrow', (tester) async {
    _setSize(tester, const Size(320, 800));
    final many = [
      for (var i = 0; i < 6; i++)
        LiquidNavItem(icon: Icons.circle_outlined, label: 'Tab $i'),
    ];
    await tester.pumpWidget(_Host(items: many));
    expect(find.text('Tab 0'), findsNothing);
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(6));
  });

  testWidgets('labels hide when showLabels is false', (tester) async {
    _setSize(tester, const Size(400, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidGlassNavBar(
            items: _items,
            currentIndex: 0,
            onTap: (_) {},
            showLabels: false,
          ),
        ),
      ),
    );
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('the current item is marked selected for semantics',
      (tester) async {
    _setSize(tester, const Size(400, 800));
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const _Host());
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Search')),
      matchesSemantics(
        label: 'Search',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('frosted and glass modes both render', (tester) async {
    _setSize(tester, const Size(400, 800));
    for (final mode in LiquidGlassMode.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            bottomNavigationBar: LiquidGlassNavBar(
              items: _items,
              currentIndex: 1,
              onTap: (_) {},
              mode: mode,
              style: const LiquidGlassStyle(barHeight: 72),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BackdropFilter)).height, 72);
    }
  });
}
