import 'dart:async';
import 'package:f0rest/f0rest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../config/bus_stars.dart';
import '../../config/home_prefs.dart';
import '../../config/teacher_stars.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../auth/auth_screen.dart';
import 'models/home_day.dart';
import 'utils/home_helpers.dart';
import 'utils/home_typography.dart';
import 'widgets/animations/boot_splash.dart';
import 'widgets/auth/mini_login_card.dart';
import 'widgets/buses/bus_card.dart';
import 'widgets/buses/mobile_buses_view.dart';
import 'widgets/calendar/calendar_card.dart';
import 'widgets/calendar/mobile_events_view.dart';
import 'widgets/header/home_header.dart';
import 'widgets/lunch/lunch_card.dart';
import 'widgets/lunch/mobile_lunch_view.dart';
import 'widgets/mobile_home_view.dart';
import 'widgets/navigation/floating_nav_bar.dart';
import 'widgets/schedule/schedule_card.dart';
import 'widgets/settings/mobile_settings_view.dart';
import 'widgets/settings/settings_drawer.dart';
import 'widgets/teachers/mobile_teachers_view.dart';
import 'widgets/teachers/teachers_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ScaffoldState>();
  final _prefs = HomePrefs.instance;
  final _ds = DataService.instance;
  final _stars = BusStars.instance;
  final _tStars = TeacherStars.instance;

  Spr0utUser? get _user => AuthService.instance.currentUser;
  String get _slug => _prefs.accent.name.toLowerCase();

  late Future<HomeDay> _day;
  late Future<List<Absence>> _abs;
  late Future<List<BusSpot>> _buses;
  late Future<List<LunchEntry>> _lunch;

  late Events _events;
  final _dots = <String, Set<int>>{};
  late DateTime _month;
  late DateTime _sel;

  Timer? _poll;
  bool _mobile = false;
  int _mobileTab = 0;

  bool _bootReady = false;
  bool _booted = false;

  String get _logoUrl =>
      '$arb0rBaseUrl/$_slug/${_prefs.dark ? 'dark' : 'light'}/$_slug.svg';
  String get _sideUrl => '$arb0rBaseUrl/$_slug/side.svg';

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _sel = DateTime(n.year, n.month, n.day);
    _month = DateTime(n.year, n.month);
    _prefs.addListener(_onPrefs);
    _stars.addListener(_onPrefs);
    _stars.load();
    _tStars.addListener(_onPrefs);
    _tStars.load();
    AuthService.instance.userNotifier.addListener(_onPrefs);
    _prefs.load(AuthService.instance.currentUser?.theme);
    unawaited(_syncThemeFromDb());
    _loadEvents();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(_loadBuses);
    });
    unawaited(_boot());
  }

  Future<void> _loadEvents() async {
    try {
      final loaded = await Events.bca();
      if (mounted) setState(() => _events = loaded);
    } catch (e) {
      if (kDebugMode) debugPrint('Events failed: $e');
    }
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefs);
    _stars.removeListener(_onPrefs);
    _tStars.removeListener(_onPrefs);
    AuthService.instance.userNotifier.removeListener(_onPrefs);
    _poll?.cancel();
    super.dispose();
  }

  void _onLoggedIn() {
    _ds.reset();
    _load();
    _stars.load();
    _tStars.load();
    _prefs.load(AuthService.instance.currentUser?.theme);
    unawaited(_syncThemeFromDb());
    if (mounted) setState(() {});
  }

  void _onPrefs() {
    if (mounted) setState(() {});
  }

  void _setAccent(Spr0utTheme t) {
    if (_prefs.accent == t) return;
    final previous = _prefs.accent;
    _prefs.setAccent(t);
    final uid = _user?.uid;
    if (uid == null) return;
    Spr0ut.setTheme(uid, t).catchError((Object e) {
      if (kDebugMode) debugPrint('Theme save failed: $e');
      if (mounted && _prefs.accent == t) _prefs.setAccent(previous);
    });
  }

  Future<void> _syncThemeFromDb() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final profile = await Spr0ut.fetchProfile(uid);
      if (profile == null || !mounted) return;
      if (_prefs.accent != profile.theme) _prefs.setAccent(profile.theme);
    } catch (e) {
      if (kDebugMode) debugPrint('Theme sync failed: $e');
    }
  }

  void _setDark(bool d) {
    if (_prefs.dark != d) _prefs.setDark(d);
  }

  Future<void> _settle(Future<Object?> f) => f
      .then<void>((_) {}, onError: (Object _) {})
      .timeout(const Duration(seconds: 12), onTimeout: () {});

  Future<void> _boot() async {
    final fonts = GoogleFonts.pendingFonts([
      for (final w in const [
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
        FontWeight.w800,
      ])
        GoogleFonts.inter(fontWeight: w),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800),
      brandStyle(40, Colors.black),
    ]);

    Future<void> assets() async {
      for (var i = 0; i < 3; i++) {
        final sig = '$_slug-${_prefs.dark}';
        await _settle(
          Future.wait<Object?>([
            for (final u in [_logoUrl, _sideUrl])
              SvgNetworkLoader(u).loadBytes(null),
          ]),
        );
        if (sig == '$_slug-${_prefs.dark}') return;
      }
    }

    await Future.wait<void>([
      _settle(fonts),
      assets(),
      _settle(_day),
      _settle(_abs),
      _settle(_buses),
      _settle(_lunch),
    ]);
    if (mounted) setState(() => _bootReady = true);
    unawaited(_warmThemes());
  }

  Future<void> _warmThemes() async {
    for (final t in HomePrefs.accents.keys) {
      final slug = t.name.toLowerCase();
      for (final u in [
        '$arb0rBaseUrl/$slug/light/$slug.svg',
        '$arb0rBaseUrl/$slug/dark/$slug.svg',
        '$arb0rBaseUrl/$slug/side.svg',
      ]) {
        await _settle(SvgNetworkLoader(u).loadBytes(null));
      }
    }
  }

  void _load() {
    _day = _findDay();
    final signedIn = _user != null;
    _abs = signedIn
        ? _ds.absences.today().catchError((e) {
            if (kDebugMode) debugPrint('$e');
            return const <Absence>[];
          })
        : Future.value(const <Absence>[]);
    _lunch = signedIn
        ? _ds.lunch.fetchToday().catchError((e) {
            if (kDebugMode) debugPrint('$e');
            return const <LunchEntry>[];
          })
        : Future.value(const <LunchEntry>[]);
    _loadBuses();
  }

  void _loadBuses() {
    _buses = _ds.buses.all();
  }

  void _reload() {
    _ds.reset();
    setState(_load);
  }

  Future<HomeDay> _findDay() async {
    final now = DateTime.now();
    for (var i = 0; i < 14; i++) {
      final d = now.add(Duration(days: i));
      final periods = await _ds.scheduleOn(d);
      if (periods.isEmpty) continue;
      final lastEnd = periods.values
          .map((p) => p.end)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (i == 0 && !now.isBefore(lastEnd)) continue;
      return (day: d, today: i == 0, periods: periods);
    }
    return (day: now, today: true, periods: const <String, SchedulePeriod>{});
  }

  Future<void> _signOut() async {
    _key.currentState?.closeEndDrawer();
    _stars.clear();
    _tStars.clear();
    await AuthService.instance.signOut();
    _ds.reset();
    _load();
    if (mounted) {
      setState(() {
        _mobileTab = 0;
      });
    }
  }

  Set<int> _dotDays(DateTime m) =>
      _dots.putIfAbsent('${m.year}-${m.month}', () {
        final last = DateTime(m.year, m.month + 1, 0).day;
        return {
          for (var d = 1; d <= last; d++)
            if (_events.query(date: DateTime(m.year, m.month, d)).isNotEmpty) d,
        };
      });

  void _shift(int d) => setState(() {
    _month = DateTime(_month.year, _month.month + d);
    final n = DateTime.now();
    _sel = (n.year == _month.year && n.month == _month.month)
        ? DateTime(n.year, n.month, n.day)
        : _month;
  });

  @override
  Widget build(BuildContext context) {
    final p = _prefs.p;
    final user = _user;
    final signedIn = user != null;
    final first = signedIn && user.displayName.isNotEmpty
        ? user.getFirstName()
        : 'GR0VE';

    return Stack(
      fit: StackFit.expand,
      children: [
        _scaffold(p, user, first, signedIn),
        if (!_booted)
          Positioned.fill(
            child: BootSplash(
              p: p,
              sideUrl: _sideUrl,
              ready: _bootReady,
              onDone: () {
                if (mounted) setState(() => _booted = true);
              },
            ),
          ),
      ],
    );
  }

  Widget _scaffold(Palette p, Spr0utUser? user, String first, bool signedIn) {
    return Scaffold(
      key: _key,
      backgroundColor: p.bg,
      endDrawer: signedIn
          ? Builder(
              builder: (_) => SettingsDrawer(
                p: p,
                user: user,
                name: first,
                sideUrl: _sideUrl,
                slug: _slug,
                prefs: _prefs,
                onSetAccent: _setAccent,
                onSetDark: _setDark,
                onReload: _reload,
                onSignOut: _signOut,
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 1180 && c.maxHeight >= 640;
            _mobile = !wide;
            if (!signedIn && _mobile) {
              return AuthScreen(onLoggedIn: _onLoggedIn);
            }

            final short = wide ? c.maxHeight < 820 : c.maxHeight < 520;
            final pad = wide ? 40.0 : (c.maxWidth < 360 ? 14.0 : 20.0);
            const vgap = SizedBox(height: homeGap);

            if (wide) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeHeader(
                          p: p,
                          firstName: signedIn ? first : 'GR0VE',
                          wide: true,
                          short: short,
                          slug: _slug,
                          dark: _prefs.dark,
                          onOpenSettings: signedIn
                              ? () => _key.currentState?.openEndDrawer()
                              : null,
                        ),
                        SizedBox(height: short ? 20 : 32),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 8,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  child: signedIn
                                      ? TeachersCard(
                                          key: const ValueKey('teachers_card'),
                                          p: p,
                                          absencesFuture: _abs,
                                          stars: _tStars,
                                          fill: true,
                                          mobile: false,
                                          onRetry: _reload,
                                        )
                                      : MiniLoginCard(
                                          key: const ValueKey(
                                            'mini_login_card',
                                          ),
                                          p: p,
                                          fill: true,
                                          mobile: false,
                                          onLoggedIn: _onLoggedIn,
                                        ),
                                ),
                              ),
                              const SizedBox(width: homeGap),
                              Expanded(
                                flex: signedIn ? 11 : 7,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  child: signedIn
                                      ? Column(
                                          key: const ValueKey(
                                            'signed_in_buses_calendar',
                                          ),
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: BusCard(
                                                p: p,
                                                busesFuture: _buses,
                                                stars: _stars,
                                                fill: true,
                                                mobile: false,
                                                onRetry: _reload,
                                                showStar: true,
                                              ),
                                            ),
                                            vgap,
                                            Expanded(
                                              flex: 6,
                                              child: CalendarCard(
                                                p: p,
                                                events: _events,
                                                month: _month,
                                                selectedDate: _sel,
                                                dots: _dotDays(_month),
                                                fill: true,
                                                mobile: false,
                                                onSelectDate: (d) =>
                                                    setState(() => _sel = d),
                                                onShiftMonth: _shift,
                                              ),
                                            ),
                                          ],
                                        )
                                      : BusCard(
                                          key: const ValueKey(
                                            'signed_out_bus_full',
                                          ),
                                          p: p,
                                          busesFuture: _buses,
                                          stars: _stars,
                                          fill: true,
                                          mobile: false,
                                          onRetry: _reload,
                                          showStar: false,
                                        ),
                                ),
                              ),
                              const SizedBox(width: homeGap),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ScheduleCard(
                                      p: p,
                                      dayFuture: _day,
                                      lunchPeriod: userLunchPeriod(_user),
                                      mobile: false,
                                      onRetry: _reload,
                                    ),
                                    vgap,
                                    Expanded(
                                      child: LunchCard(
                                        p: p,
                                        lunchFuture: _lunch,
                                        dayFuture: _day,
                                        lunchPeriod: userLunchPeriod(_user),
                                        fill: true,
                                        mobile: false,
                                        onRetry: _reload,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_mobileTab),
                      child: switch (_mobileTab) {
                        1 => MobileTeachersView(
                          p: p,
                          pad: pad,
                          absencesFuture: _abs,
                          stars: _tStars,
                          onRetry: _reload,
                        ),
                        2 => MobileBusesView(
                          p: p,
                          pad: pad,
                          busesFuture: _buses,
                          stars: _stars,
                          onRetry: _reload,
                        ),
                        3 => MobileEventsView(
                          p: p,
                          pad: pad,
                          events: _events,
                          month: _month,
                          selectedDate: _sel,
                          dots: _dotDays(_month),
                          onSelectDate: (d) => setState(() => _sel = d),
                          onShiftMonth: _shift,
                        ),
                        4 => MobileLunchView(
                          p: p,
                          pad: pad,
                          lunchFuture: _lunch,
                          dayFuture: _day,
                          lunchPeriod: userLunchPeriod(_user),
                          onRetry: _reload,
                        ),
                        5 => MobileSettingsView(
                          p: p,
                          pad: pad,
                          user: user,
                          name: first,
                          prefs: _prefs,
                          onSetAccent: _setAccent,
                          onSetDark: _setDark,
                          onReload: _reload,
                          onSignOut: _signOut,
                        ),
                        _ => MobileHomeView(
                          p: p,
                          firstName: first,
                          short: short,
                          pad: pad,
                          slug: _slug,
                          dark: _prefs.dark,
                          dayFuture: _day,
                          lunchPeriod: userLunchPeriod(_user),
                          absencesFuture: _abs,
                          tStars: _tStars,
                          busesFuture: _buses,
                          stars: _stars,
                          events: _events,
                          lunchFuture: _lunch,
                          onSwitchToTab: (tab) =>
                              setState(() => _mobileTab = tab),
                          onOpenSettings: () => setState(() => _mobileTab = 5),
                          onRetry: _reload,
                        ),
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 140,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            p.bg.withAlpha(0),
                            p.bg.withAlpha(235),
                            p.bg,
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: pad + 8,
                  right: pad + 8,
                  bottom: 16,
                  child: FloatingNavBar(
                    p: p,
                    currentTab: _mobileTab,
                    onSelectTab: (tab) => setState(() => _mobileTab = tab),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
