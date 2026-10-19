# liquid_glass_nav_bar

<p align="center">
  <img src="https://raw.githubusercontent.com/umar-ghaffar/liquid_glass_nav_bar/main/doc/demo.gif" alt="Liquid Glass navigation bar demo" width="320">
</p>

iOS 26 style **Liquid Glass** navigation for Flutter, on iOS and Android.
A floating glass bottom bar on phones, a glass side rail on tablets and
desktop, and a scaffold that switches between them for you.

## Features

- Floating capsule bar with backdrop blur, a bright rim and a soft sheen
- Stretchy selection pill that leads, overshoots a little and catches up
- Drag along the bar to scrub between tabs, with a selection haptic per item
- Side rail for wide screens, same look and the same pill
- `LiquidGlassScaffold` switches bar and rail at a breakpoint and lets content scroll behind the glass
- `glass`, `frosted` or `auto` (glass on Apple platforms, frosted elsewhere)
- Picks up your `ColorScheme` in light and dark, every value can be overridden
- Badges, active icons, labels that hide when there isn't room, semantics
- No dependencies besides Flutter

## Getting started

```yaml
dependencies:
  liquid_glass_nav_bar: ^0.1.0
```

```dart
import 'package:liquid_glass_nav_bar/liquid_glass_nav_bar.dart';
```

## Usage

### Adaptive scaffold

The easiest way. Bar below 600px wide, rail above.

```dart
int _index = 0;

@override
Widget build(BuildContext context) {
  return LiquidGlassScaffold(
    currentIndex: _index,
    onTap: (i) => setState(() => _index = i),
    items: const [
      LiquidNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      LiquidNavItem(icon: Icons.search, label: 'Search'),
      LiquidNavItem(icon: Icons.inbox_outlined, label: 'Inbox', badge: '3'),
      LiquidNavItem(icon: Icons.person_outline, label: 'Profile'),
    ],
    body: IndexedStack(
      index: _index,
      children: const [HomePage(), SearchPage(), InboxPage(), ProfilePage()],
    ),
  );
}
```

The body's `MediaQuery` bottom padding includes the bar, so `ListView`,
`SafeArea` and friends keep their last item clear of the glass while still
scrolling behind it. Slivers don't apply that padding on their own, so wrap
them in `SliverSafeArea(top: false, ...)`.

The keyboard covers the bar like it does on iOS. Pages with their own
`Scaffold` still resize for it.

### Just the bar

Use it as `bottomNavigationBar` and set `extendBody: true`, otherwise the
content stops above the bar and there's nothing to blur.

```dart
Scaffold(
  extendBody: true,
  body: ...,
  bottomNavigationBar: LiquidGlassNavBar(
    items: items,
    currentIndex: _index,
    onTap: (i) => setState(() => _index = i),
  ),
);
```

### Just the rail

```dart
Row(
  children: [
    LiquidGlassNavRail(items: items, currentIndex: _index, onTap: _select),
    Expanded(child: content),
  ],
);
```

### go_router

Pass a `StatefulNavigationShell` as the body:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => LiquidGlassScaffold(
    body: shell,
    currentIndex: shell.currentIndex,
    onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
    items: items,
  ),
  branches: [...],
);
```

## Customising

```dart
LiquidGlassScaffold(
  mode: LiquidGlassMode.glass,
  style: const LiquidGlassStyle(
    activeColor: Colors.pink,
    blurSigma: 24,
    barHeight: 68,
    margin: EdgeInsets.fromLTRB(24, 16, 24, 16),
    animationDuration: Duration(milliseconds: 420),
  ),
  ...
);
```

| Mode | Look |
| --- | --- |
| `auto` | `glass` on iOS and macOS, `frosted` elsewhere (default) |
| `glass` | clear, light blur, bright rim and sheen |
| `frosted` | denser Material tinted blur, cheaper on low-end Android |

`LiquidGlassStyle` fields: `tintColor`, `blurSigma`, `activeColor`,
`inactiveColor`, `indicatorColor`, `rimColor`, `shadows`, `labelStyle`,
`barHeight`, `railWidth`, `itemExtent`, `margin`, `maxBarWidth`,
`animationDuration`. Anything left `null` comes from the theme.

Other options: `showLabels`, `enableHaptics`, and `railBreakpoint` on the
scaffold.

`badge` on `LiquidNavItem`: `null` hides it, `''` shows a dot, any other
string is shown as text.

## Behaviour

The widgets are controlled. Tapping an item calls `onTap`, and the pill
moves when you pass the new `currentIndex`. If you ignore a drag selection,
the pill slides back.

## Roadmap

- 0.2.0: real lens refraction with a fragment shader on Impeller, blur fallback on Skia and web
- 0.3.0: collapse on scroll, and a separate glass action button that merges with the bar

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/umar-ghaffar/liquid_glass_nav_bar).
