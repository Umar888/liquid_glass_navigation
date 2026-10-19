import 'package:flutter/material.dart';
import 'package:liquid_glass_nav_bar/liquid_glass_nav_bar.dart';

void main() => runApp(const DemoApp());

const _seed = Color(0xFF5B5BD6);

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  var _settings = const DemoSettings();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Glass',
      debugShowCheckedModeBanner: false,
      themeMode: _settings.dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeShell(
        settings: _settings,
        onSettingsChanged: (s) => setState(() => _settings = s),
      ),
    );
  }
}

@immutable
class DemoSettings {
  const DemoSettings({
    this.mode = LiquidGlassMode.auto,
    this.dark = false,
    this.showLabels = true,
    this.haptics = true,
  });

  final LiquidGlassMode mode;
  final bool dark;
  final bool showLabels;
  final bool haptics;

  DemoSettings copyWith({
    LiquidGlassMode? mode,
    bool? dark,
    bool? showLabels,
    bool? haptics,
  }) {
    return DemoSettings(
      mode: mode ?? this.mode,
      dark: dark ?? this.dark,
      showLabels: showLabels ?? this.showLabels,
      haptics: haptics ?? this.haptics,
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final DemoSettings settings;
  final ValueChanged<DemoSettings> onSettingsChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _items = [
    LiquidNavItem(
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny,
      label: 'Today',
    ),
    LiquidNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Explore',
    ),
    LiquidNavItem(
      icon: Icons.inbox_outlined,
      activeIcon: Icons.inbox,
      label: 'Inbox',
      badge: '3',
    ),
    LiquidNavItem(
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return LiquidGlassScaffold(
      items: _items,
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      mode: settings.mode,
      showLabels: settings.showLabels,
      enableHaptics: settings.haptics,
      body: IndexedStack(
        index: _index,
        children: [
          const TodayPage(),
          const ExplorePage(),
          const InboxPage(),
          SettingsPage(
            settings: settings,
            onChanged: widget.onSettingsChanged,
          ),
        ],
      ),
    );
  }
}

// Today

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  static const _cards = [
    _Story('Morning run', '5.2 km along the river', Icons.directions_run,
        [Color(0xFFFF7E5F), Color(0xFFFEB47B)]),
    _Story('Deep work', 'Two hours, no notifications', Icons.headphones,
        [Color(0xFF6A11CB), Color(0xFF2575FC)]),
    _Story('Lunch with Sam', 'The new ramen place', Icons.ramen_dining,
        [Color(0xFF11998E), Color(0xFF38EF7D)]),
    _Story('Design review', 'Glass nav, round two', Icons.palette_outlined,
        [Color(0xFFFC466B), Color(0xFF3F5EFB)]),
    _Story('Sunset walk', 'Golden hour at 19:42', Icons.wb_twilight,
        [Color(0xFFF7971E), Color(0xFFFFD200)]),
    _Story('Read', 'Chapter 7 of Piranesi', Icons.menu_book_outlined,
        [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
    _Story('Wind down', 'Lights off by 23:00', Icons.bedtime_outlined,
        [Color(0xFF0F2027), Color(0xFF2C5364)]),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Today')),
        // slivers don't pick up MediaQuery padding on their own
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.separated(
              itemCount: _cards.length,
              separatorBuilder: (context, i) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _StoryCard(story: _cards[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _Story {
  const _Story(this.title, this.subtitle, this.icon, this.colors);

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final _Story story;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: story.colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -12,
            child: Icon(
              story.icon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(story.icon, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                story.title,
                style: text.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                story.subtitle,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Explore

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const _icons = [
    Icons.landscape_outlined,
    Icons.local_cafe_outlined,
    Icons.music_note_outlined,
    Icons.camera_alt_outlined,
    Icons.park_outlined,
    Icons.sailing_outlined,
    Icons.museum_outlined,
    Icons.icecream_outlined,
    Icons.pedal_bike_outlined,
    Icons.nightlife_outlined,
    Icons.spa_outlined,
    Icons.hiking_outlined,
  ];

  static const _names = [
    'Mountains',
    'Coffee',
    'Live music',
    'Photo walks',
    'Parks',
    'Sailing',
    'Museums',
    'Desserts',
    'Cycling',
    'Nightlife',
    'Wellness',
    'Trails',
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Explore')),
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _icons.length * 2,
              itemBuilder: (context, i) {
                final hue = (i * 37) % 360.0;
                final a = HSLColor.fromAHSL(1, hue, 0.75, 0.6).toColor();
                final b =
                    HSLColor.fromAHSL(1, (hue + 50) % 360, 0.8, 0.45).toColor();
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [a, b],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _icons[i % _icons.length],
                          color: Colors.white,
                          size: 32,
                        ),
                        const Spacer(),
                        Text(
                          _names[i % _names.length],
                          style: text.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${12 + i * 3} places',
                          style: text.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Inbox

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  static const _messages = [
    ('Ava Chen', 'Loved the new nav bar, the drag feels great', true),
    ('Leo Martins', 'Can we ship the rail on tablets this week?', true),
    ('Maya Patel', 'Sending over the dark mode screenshots', true),
    ('Noah Kim', 'Lunch tomorrow?', false),
    ('Zara Ali', 'Re: release notes for 0.1.0', false),
    ('Oscar Diaz', 'The frosted mode looks sharp on my Pixel', false),
    ('Ivy Thompson', 'Quick question about haptics', false),
    ('Ethan Brooks', 'Pushed the fix, mind taking a look?', false),
    ('Sofia Rossi', 'Photos from the offsite', false),
    ('Liam Walsh', 'Thanks!', false),
    ('Hana Sato', 'Tickets are booked', false),
    ('Ben Okafor', 'See you at standup', false),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Inbox')),
        SliverSafeArea(
          top: false,
          sliver: SliverList.builder(
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final (name, preview, unread) = _messages[i];
              final color =
                  HSLColor.fromAHSL(1, (i * 53) % 360.0, 0.65, 0.55).toColor();
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Text(name.characters.first),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread
                    ? Icon(Icons.circle, size: 10, color: scheme.primary)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Settings

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final DemoSettings settings;
  final ValueChanged<DemoSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Settings')),
        SliverSafeArea(
          top: false,
          sliver: SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Glass', style: text.titleSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<LiquidGlassMode>(
                  segments: const [
                    ButtonSegment(
                      value: LiquidGlassMode.auto,
                      label: Text('Auto'),
                      icon: Icon(Icons.auto_awesome_outlined),
                    ),
                    ButtonSegment(
                      value: LiquidGlassMode.glass,
                      label: Text('Glass'),
                      icon: Icon(Icons.water_drop_outlined),
                    ),
                    ButtonSegment(
                      value: LiquidGlassMode.frosted,
                      label: Text('Frosted'),
                      icon: Icon(Icons.ac_unit),
                    ),
                  ],
                  selected: {settings.mode},
                  onSelectionChanged: (s) =>
                      onChanged(settings.copyWith(mode: s.first)),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: settings.dark,
                onChanged: (v) => onChanged(settings.copyWith(dark: v)),
              ),
              SwitchListTile(
                title: const Text('Show labels'),
                secondary: const Icon(Icons.label_outline),
                value: settings.showLabels,
                onChanged: (v) => onChanged(settings.copyWith(showLabels: v)),
              ),
              SwitchListTile(
                title: const Text('Haptics'),
                secondary: const Icon(Icons.vibration),
                value: settings.haptics,
                onChanged: (v) => onChanged(settings.copyWith(haptics: v)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tip: drag along the bar to scrub between tabs.',
                  style: text.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
