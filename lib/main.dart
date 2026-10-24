import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineverse/data/demo_catalog.dart';

const _key = String.fromEnvironment('TMDB_API_KEY');
const _token = String.fromEnvironment('TMDB_READ_ACCESS_TOKEN');
const _red = Color(0xFFE50914);
const _languages = {
  'en': 'English',
  'te': 'Telugu',
  'hi': 'Hindi',
  'ta': 'Tamil',
  'kn': 'Kannada',
  'ml': 'Malayalam',
  'es': 'Spanish',
  'ko': 'Korean',
  'ja': 'Japanese',
  'fr': 'French'
};

void main() => runApp(const CineVerseApp());

class CineVerseApp extends StatefulWidget {
  const CineVerseApp({super.key});
  @override
  State<CineVerseApp> createState() => _CineVerseAppState();
}

class _CineVerseAppState extends State<CineVerseApp> {
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _ready = false;
  bool _entered = false;
  bool _signedIn = false;
  String _name = 'Guest';
  String _language = 'en';
  List<String> _contentLanguages = ['en'];
  List<int> _watchlist = [];
  List<Map<String, dynamic>> _savedItems = [];
  int _tab = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _prefs;
    if (!mounted) return;
    setState(() {
      _ready = true;
      _entered = p.getBool('entered') ?? false;
      _signedIn = p.getBool('signedIn') ?? false;
      _name = p.getString('name') ?? 'Guest';
      _language = p.getString('language') ?? 'en';
      _contentLanguages = p.getStringList('contentLanguages') ?? ['en'];
      _savedItems = (jsonDecode(p.getString('savedItems') ?? '[]') as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _watchlist = _savedItems.map((e) => e['id']).whereType<int>().toList();
    });
  }

  Future<void> _persist() async {
    final p = await _prefs;
    await p.setBool('entered', _entered);
    await p.setBool('signedIn', _signedIn);
    await p.setString('name', _name);
    await p.setString('language', _language);
    await p.setStringList('contentLanguages', _contentLanguages);
    await p.setString('savedItems', jsonEncode(_savedItems));
  }

  void _toggle(Map movie) {
    final id = movie['id'] as int?;
    if (id == null) return;
    setState(() {
      if (_watchlist.contains(id)) {
        _watchlist.remove(id);
        _savedItems.removeWhere((item) => item['id'] == id);
      } else {
        _watchlist.add(id);
        _savedItems.add(Map<String, dynamic>.from(movie));
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineVerse',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff08090b),
        colorScheme: const ColorScheme.dark(
          primary: _red,
          secondary: Color(0xffe5b85c),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff08090b),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: !_ready
          ? const _LoadingPage()
          : (!_entered
              ? WelcomePage(
                  onGuest: () {
                    setState(() {
                      _entered = true;
                      _name = 'Guest';
                    });
                    _persist();
                  },
                  onLogin: (name) {
                    setState(() {
                      _entered = true;
                      _signedIn = true;
                      _name = name;
                    });
                    _persist();
                  },
                  onSignup: (name) {
                    setState(() {
                      _entered = true;
                      _signedIn = true;
                      _name = name;
                    });
                    _persist();
                  },
                )
              : _tab == 4
                  ? SettingsPage(
                      name: _name,
                      language: _language,
                      contentLanguages: _contentLanguages,
                      onSave: (language, contentLanguages) {
                        setState(() {
                          _language = language;
                          _contentLanguages = contentLanguages;
                        });
                        _persist();
                      },
                      onLogout: () {
                        setState(() {
                          _signedIn = false;
                          _entered = false;
                          _name = 'Guest';
                          _tab = 0;
                        });
                        _persist();
                      },
                    )
                  : MainShell(
                      tab: _tab,
                      onTab: (value) => setState(() => _tab = value),
                      watchlist: _watchlist,
                      items: _savedItems,
                      toggle: _toggle,
                      name: _name,
                      language: _language,
                      contentLanguages: _contentLanguages,
                      onSettings: () => setState(() => _tab = 4),
                    )),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: CircularProgressIndicator(color: _red)));
}

class WelcomePage extends StatefulWidget {
  final VoidCallback onGuest;
  final ValueChanged<String> onLogin, onSignup;
  const WelcomePage(
      {super.key,
      required this.onGuest,
      required this.onLogin,
      required this.onSignup});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _pass = TextEditingController(),
      _confirm = TextEditingController();
  bool _signup = false, _show = false;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Stack(fit: StackFit.expand, children: [
        Image.network(
            'https://image.tmdb.org/t/p/original/8bcoRX3hQRHufLPSDREdvr3Ydx1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xff171719))),
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Color(0xff08090b)],
                    stops: [.12, .9]))),
        Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 410),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Brand(),
                          const SizedBox(height: 28),
                          Text(
                              _signup
                                  ? 'Create your account'
                                  : 'Stories worth staying in for.',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('Discover your next favorite film.',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 26),
                          Form(
                              key: _form,
                              child: Column(children: [
                                if (_signup)
                                  _field(_name, 'Name', Icons.person_outline,
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Enter your name'
                                              : null),
                                _field(_email, 'Email', Icons.mail_outline,
                                    validator: (v) =>
                                        v == null || !v.contains('@')
                                            ? 'Enter a valid email'
                                            : null),
                                _field(_pass, 'Password', Icons.lock_outline,
                                    secret: !_show,
                                    validator: (v) => v == null || v.length < 6
                                        ? 'Use at least 6 characters'
                                        : null,
                                    suffix: IconButton(
                                        onPressed: () =>
                                            setState(() => _show = !_show),
                                        icon: Icon(_show
                                            ? Icons.visibility_off
                                            : Icons.visibility))),
                                if (_signup)
                                  _field(_confirm, 'Confirm password',
                                      Icons.lock_outline,
                                      secret: true,
                                      validator: (v) => v != _pass.text
                                          ? 'Passwords do not match'
                                          : null)
                              ])),
                          const SizedBox(height: 18),
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: _red),
                                  onPressed: () {
                                    if (_form.currentState!.validate()) {
                                      (_signup
                                              ? widget.onSignup
                                              : widget.onLogin)(
                                          _signup
                                              ? _name.text.trim()
                                              : (_name.text.trim().isEmpty
                                                  ? 'Guest'
                                                  : _name.text.trim()));
                                    }
                                  },
                                  child: Text(
                                      _signup ? 'Create account' : 'Sign in',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)))),
                          TextButton(
                              onPressed: () =>
                                  setState(() => _signup = !_signup),
                              child: Text(_signup
                                  ? 'Already have an account? Sign in'
                                  : 'New to CineVerse? Create an account')),
                          if (!_signup)
                            TextButton(
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Password recovery requires an authentication provider. Demo mode stores no password.'))),
                                child: const Text('Forgot password?')),
                          const Divider(color: Colors.white24),
                          Center(
                              child: TextButton.icon(
                                  onPressed: widget.onGuest,
                                  icon: const Icon(Icons.explore_outlined),
                                  label: const Text(
                                      'Continue browsing as guest'))),
                          const SizedBox(height: 16),
                          const Text(
                              'DEMO MODE - No account provider is configured. Form details are not authenticated or stored.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11))
                        ]))))
      ]));
  Widget _field(TextEditingController ctl, String label, IconData icon,
          {String? Function(String?)? validator,
          bool secret = false,
          Widget? suffix}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: ctl,
              validator: validator,
              obscureText: secret,
              decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  suffixIcon: suffix,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xdd151619))));
}

class MainShell extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final List<int> watchlist;
  final List<Map<String, dynamic>> items;
  final void Function(Map) toggle;
  final String name, language;
  final List<String> contentLanguages;
  final VoidCallback onSettings;
  const MainShell(
      {super.key,
      required this.tab,
      required this.onTab,
      required this.watchlist,
      required this.items,
      required this.toggle,
      required this.name,
      required this.language,
      required this.contentLanguages,
      required this.onSettings});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const _Brand(), actions: [
          IconButton(
              tooltip: 'Search',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SearchPage(
                          language: language,
                          toggle: toggle,
                          watchlist: watchlist))),
              icon: const Icon(Icons.search)),
          IconButton(
              tooltip: 'Profile and settings',
              onPressed: onSettings,
              icon: const Icon(Icons.account_circle_outlined))
        ]),
        body: IndexedStack(index: tab, children: [
          HomePage(
              language: language,
              contentLanguages: contentLanguages,
              toggle: toggle,
              watchlist: watchlist),
          BrowsePage(
              kind: 'movie',
              language: language,
              toggle: toggle,
              watchlist: watchlist),
          BrowsePage(
              kind: 'tv',
              language: language,
              toggle: toggle,
              watchlist: watchlist),
          WatchlistPage(items: items, toggle: toggle)
        ]),
        bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: onTab,
            backgroundColor: const Color(0xff101114),
            indicatorColor: _red.withValues(alpha: .2),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.movie_outlined), label: 'Movies'),
              NavigationDestination(
                  icon: Icon(Icons.tv_outlined), label: 'TV Shows'),
              NavigationDestination(
                  icon: Icon(Icons.bookmark_outline), label: 'My List')
            ]));
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) =>
      const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_fill, color: _red, size: 29),
        SizedBox(width: 8),
        Text('CINEVERSE',
            style: TextStyle(
                letterSpacing: 2.5, fontWeight: FontWeight.w900, fontSize: 17))
      ]);
}

class Tmdb {
  static bool get hasCredentials =>
      _key.trim().isNotEmpty || _token.trim().isNotEmpty;
  static bool get demoMode => !hasCredentials;

  static Future<List<Map<String, dynamic>>> list(String path,
      {Map<String, String> query = const {}}) async {
    final apiKey = _key.trim();
    final accessToken = _token.trim();
    if (apiKey.isEmpty && accessToken.isEmpty) {
      throw Exception(
          'TMDB credentials are missing. Set TMDB_API_KEY or TMDB_READ_ACCESS_TOKEN in tmdb.secrets.json, then restart with --dart-define-from-file=tmdb.secrets.json.');
    }
    final uri = Uri.https('api.themoviedb.org', '/3/$path', {
      if (apiKey.isNotEmpty && accessToken.isEmpty) 'api_key': apiKey,
      ...query,
    });
    late final http.Response r;
    try {
      r = await http
          .get(
            uri,
            headers: accessToken.isNotEmpty
                ? {'Authorization': 'Bearer $accessToken'}
                : const {},
          )
          .timeout(const Duration(seconds: 18));
    } on TimeoutException {
      throw Exception(
          'TMDB request timed out. Check your connection and retry.');
    } on http.ClientException catch (error) {
      throw Exception(
          'Could not reach TMDB. Check your internet connection and retry. Details: ${error.message}');
    }
    if (r.statusCode == 401) {
      throw Exception(
          'TMDB rejected the configured credential (401). Check that the API key or read access token in tmdb.secrets.json is valid.');
    }
    if (r.statusCode == 403) {
      throw Exception(
          'TMDB denied this request (403). Check that your TMDB credential is active and authorized.');
    }
    if (r.statusCode == 429) {
      throw Exception('TMDB rate limit reached. Try again shortly.');
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('TMDB request failed (${r.statusCode}).');
    }
    late final Object? decoded;
    try {
      decoded = jsonDecode(r.body);
    } on FormatException {
      throw Exception('TMDB returned invalid JSON for $path. Please retry.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('TMDB returned an unexpected response. Please retry.');
    }
    final results = decoded['results'];
    if (results is! List) {
      throw Exception(
          'TMDB response did not contain a results list for $path.');
    }
    return results
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

class HomePage extends StatefulWidget {
  final String language;
  final List<String> contentLanguages;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const HomePage(
      {super.key,
      required this.language,
      required this.contentLanguages,
      required this.toggle,
      required this.watchlist});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, List<Map<String, dynamic>>>> future;
  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  void didUpdateWidget(covariant HomePage old) {
    super.didUpdateWidget(old);
    if (old.contentLanguages.join() != widget.contentLanguages.join()) {
      future = _load();
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    if (Tmdb.demoMode) return DemoCatalog.homeSections;

    final lang =
        widget.contentLanguages.isEmpty ? 'en' : widget.contentLanguages.first;
    final results = await Future.wait([
      Tmdb.list('trending/all/week', query: {'language': widget.language}),
      Tmdb.list('movie/popular',
          query: {'language': widget.language, 'with_original_language': lang}),
      Tmdb.list('movie/top_rated', query: {'language': widget.language}),
      Tmdb.list('tv/popular', query: {'language': widget.language}),
      Tmdb.list('movie/upcoming', query: {'language': widget.language})
    ]);
    return {
      'Trending Now': results[0],
      'Popular Movies': results[1],
      'Top Rated Movies': results[2],
      'Popular TV Shows': results[3],
      'Coming Soon': results[4]
    };
  }

  Future<void> _retry() async {
    setState(() => future = _load());
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
          future: future,
          builder: (context, s) {
            if (s.hasError) {
              return _ErrorState(message: s.error.toString(), retry: _retry);
            }
            if (!s.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _red));
            }
            final data = s.data!;
            final allTitles = data.values.expand((items) => items).toList();
            final feature =
                allTitles.isEmpty ? <String, dynamic>{} : allTitles.first;
            return RefreshIndicator(
                onRefresh: _retry,
                child: CustomScrollView(slivers: [
                  if (Tmdb.demoMode)
                    const SliverToBoxAdapter(child: _DemoBadge()),
                  if (feature.isNotEmpty)
                    SliverToBoxAdapter(
                        child: _Hero(
                            movie: feature,
                            onTap: () => _details(
                                context,
                                feature,
                                (feature['media_type'] ?? 'movie').toString(),
                                widget.toggle,
                                widget.watchlist))),
                  for (final entry in data.entries)
                    SliverToBoxAdapter(
                        child: MovieRail(
                            title: entry.key,
                            items: entry.value,
                            toggle: widget.toggle,
                            watchlist: widget.watchlist,
                            language: widget.language)),
                  const SliverToBoxAdapter(child: SizedBox(height: 30))
                ]));
          });
}

class _Hero extends StatelessWidget {
  final Map movie;
  final VoidCallback onTap;
  const _Hero({required this.movie, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final title = (movie['title'] ?? movie['name'] ?? 'Featured').toString();
    return SizedBox(
        height: MediaQuery.of(context).size.width < 600 ? 440 : 520,
        child: Stack(fit: StackFit.expand, children: [
          _poster(movie['backdrop_path'],
              wide: true, title: title, seed: movie['id'] as int?),
          const DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.transparent, Color(0xff08090b)],
                      stops: [.1, .98]))),
          const DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xff08090b)],
                      stops: [.52, 1]))),
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                Tmdb.demoMode
                                    ? 'DEMO CATALOG · SAMPLE DATA'
                                    : 'FEATURED TONIGHT',
                                style: const TextStyle(
                                    color: Color(0xffe5b85c),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                            const SizedBox(height: 10),
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.w900)),
                            Text(
                                'Rating ${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? 'N/A'} | ${(movie['release_date'] ?? movie['first_air_date'] ?? '').toString().split('-').first}',
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                                (movie['overview'] ??
                                        'Discover a story picked for your next movie night.')
                                    .toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, height: 1.45)),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: _red),
                                onPressed: onTap,
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Explore title'))
                          ]))))
        ]));
  }
}

class MovieRail extends StatelessWidget {
  final String title, language;
  final List<Map<String, dynamic>> items;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const MovieRail(
      {super.key,
      required this.title,
      required this.items,
      required this.toggle,
      required this.watchlist,
      required this.language});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 20))),
        if (items.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('No titles available right now.',
                  style: TextStyle(color: Colors.white54)))
        else
          SizedBox(
              height: 252,
              child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, i) => _PosterCard(
                      movie: items[i],
                      toggle: toggle,
                      watchlist: watchlist,
                      language: language),
                  separatorBuilder: (_, __) => const SizedBox(width: 12)))
      ]));
}

class _PosterCard extends StatelessWidget {
  final Map movie;
  final void Function(Map) toggle;
  final List<int> watchlist;
  final String language;
  const _PosterCard(
      {required this.movie,
      required this.toggle,
      required this.watchlist,
      required this.language});
  @override
  Widget build(BuildContext context) {
    final id = movie['id'];
    final title = (movie['title'] ?? movie['name'] ?? 'Untitled').toString();
    return SizedBox(
        width: 148,
        child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _details(
                context,
                movie,
                (movie['media_type'] ??
                        (movie.containsKey('first_air_date') ? 'tv' : 'movie'))
                    .toString(),
                toggle,
                watchlist),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _poster(movie['poster_path'],
                        title: title, seed: movie['id'] as int?)),
                Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton.filledTonal(
                        tooltip: watchlist.contains(id)
                            ? 'Remove from My List'
                            : 'Add to My List',
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.black87,
                            minimumSize: const Size(36, 36)),
                        onPressed: () => toggle(Map.from(movie)),
                        icon: Icon(
                            watchlist.contains(id)
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            size: 19,
                            color: Colors.white)))
              ])),
              const SizedBox(height: 8),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                  'Rating ${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? 'N/A'} | ${(movie['release_date'] ?? movie['first_air_date'] ?? '').toString().split('-').first}',
                  style: const TextStyle(fontSize: 11, color: Colors.white60))
            ])));
  }
}

Widget _poster(dynamic path,
    {bool wide = false, String title = 'CineVerse', int? seed}) {
  final p = path?.toString() ?? '';
  return p.isEmpty
      ? _LocalPoster(title: title, seed: seed ?? title.hashCode, wide: wide)
      : Image.network(
          p.startsWith('http')
              ? p
              : 'https://image.tmdb.org/t/p/${wide ? 'w1280' : 'w500'}$p',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : _LocalPoster(
                  title: title, seed: seed ?? title.hashCode, wide: wide),
          errorBuilder: (_, __, ___) => _LocalPoster(
              title: title, seed: seed ?? title.hashCode, wide: wide));
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            const Icon(Icons.offline_bolt, color: Color(0xffe5b85c), size: 18),
            const SizedBox(width: 8),
            Text(
              'OFFLINE DEMO · ORIGINAL SAMPLE TITLES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xffe5b85c),
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
}

class _LocalPoster extends StatelessWidget {
  final String title;
  final int seed;
  final bool wide;

  const _LocalPoster(
      {required this.title, required this.seed, this.wide = false});

  static const _palettes = [
    [Color(0xff102a43), Color(0xff5b2333)],
    [Color(0xff153b38), Color(0xffbf6b3b)],
    [Color(0xff29234a), Color(0xffa54852)],
    [Color(0xff283845), Color(0xffcf9c51)],
    [Color(0xff17324d), Color(0xff327a83)],
    [Color(0xff452d42), Color(0xffb46b4b)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[seed.abs() % _palettes.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
        CustomPaint(painter: _PosterPattern(seed: seed)),
        Align(
          alignment:
              wide ? const Alignment(-.65, -.15) : const Alignment(0, -.2),
          child: Text(
            title.trim().isEmpty ? 'C' : title.trim()[0].toUpperCase(),
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: wide ? 220 : 108,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: .14),
              height: 1,
            ),
          ),
        ),
        if (!wide)
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Text(
              title.toUpperCase(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
      ],
    );
  }
}

class _PosterPattern extends CustomPainter {
  final int seed;
  const _PosterPattern({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .08);
    final offset = (seed.abs() % 25).toDouble();
    canvas.drawCircle(
      Offset(size.width * (.7 + offset / 100), size.height * .28),
      size.shortestSide * .38,
      paint,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (.56 + i * .045);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PosterPattern oldDelegate) =>
      seed != oldDelegate.seed;
}

void _details(BuildContext context, Map movie, String type,
        void Function(Map) toggle, List<int> watchlist) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailsPage(
                movie: movie,
                type: type,
                toggle: toggle,
                watchlist: watchlist)));

class DetailsPage extends StatefulWidget {
  final Map movie;
  final String type;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const DetailsPage(
      {super.key,
      required this.movie,
      required this.type,
      required this.toggle,
      required this.watchlist});
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<List<Map<String, dynamic>>> similar;
  late bool saved;
  @override
  void initState() {
    super.initState();
    saved = widget.watchlist.contains(widget.movie['id']);
    final id = widget.movie['id'];
    similar = Tmdb.demoMode
        ? Future.value(DemoCatalog.similar(widget.movie, widget.type))
        : Tmdb.list('${widget.type}/$id/similar');
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;
    final title = (m['title'] ?? m['name'] ?? 'Title').toString();
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
          pinned: true,
          expandedHeight: 300,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back)),
          actions: [
            IconButton(
                tooltip: 'Share',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Share this title from your device menu.'))),
                icon: const Icon(Icons.share_outlined))
          ],
          flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
            _poster(m['backdrop_path'],
                wide: true, title: title, seed: m['id'] as int?),
            const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xff08090b)])))
          ]))),
      SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(
                        'Rating ${(m['vote_average'] as num?)?.toStringAsFixed(1) ?? 'N/A'} | ${(m['release_date'] ?? m['first_air_date'] ?? 'Date unavailable')} | ${(m['original_language'] ?? '').toString().toUpperCase()}',
                        style: const TextStyle(color: Colors.white70)),
                    if (Tmdb.demoMode)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text('DEMO SAMPLE · NOT TMDB DATA',
                            style: TextStyle(
                                color: Color(0xffe5b85c),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final genre in (m['genres'] as List?) ?? const [])
                          Chip(label: Text(genre.toString())),
                      ],
                    ),
                    if (m['runtime'] != null) Text('Runtime · ${m['runtime']}'),
                    if (m['number_of_seasons'] != null)
                      Text(
                          '${m['number_of_seasons']} seasons · ${m['number_of_episodes']} episodes'),
                    const SizedBox(height: 18),
                    Wrap(spacing: 12, children: [
                      FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: _red),
                          onPressed: () {
                            widget.toggle(Map.from(m));
                            setState(() => saved = !saved);
                          },
                          icon: Icon(saved
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined),
                          label: Text(saved ? 'In My List' : 'Add to My List')),
                      OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                                      'No trailer player is configured in this build.'))),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Trailer'))
                    ]),
                    const SizedBox(height: 20),
                    Text(
                        (m['overview'] ?? 'No synopsis is available.')
                            .toString(),
                        style: const TextStyle(
                            height: 1.6, color: Colors.white70)),
                    const SizedBox(height: 25),
                    const Text('More like this',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                  ]))),
      SliverToBoxAdapter(
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: similar,
              builder: (context, s) => s.hasError
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Similar titles are unavailable right now.',
                          style: TextStyle(color: Colors.white54)))
                  : !s.hasData
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: _red))
                      : SizedBox(
                          height: 250,
                          child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: s.data!.length,
                              itemBuilder: (context, i) => _PosterCard(
                                  movie: s.data![i],
                                  toggle: widget.toggle,
                                  watchlist: widget.watchlist,
                                  language: 'en'),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12)))))
    ]));
  }
}

class BrowsePage extends StatelessWidget {
  final String kind, language;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const BrowsePage(
      {super.key,
      required this.kind,
      required this.language,
      required this.toggle,
      required this.watchlist});
  @override
  Widget build(BuildContext context) => SearchResultsPage(
      kind: kind, language: language, toggle: toggle, watchlist: watchlist);
}

class SearchPage extends StatefulWidget {
  final String language;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const SearchPage(
      {super.key,
      required this.language,
      required this.toggle,
      required this.watchlist});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ctl = TextEditingController();
  Timer? timer;
  String query = '';
  String filter = 'multi';

  @override
  void dispose() {
    timer?.cancel();
    ctl.dispose();
    super.dispose();
  }

  void change(String value) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 450), () {
      setState(() => query = value.trim());
      if (value.trim().isNotEmpty) {
        SharedPreferences.getInstance().then((prefs) {
          final recent = prefs.getStringList('recent') ?? [];
          recent.remove(value.trim());
          recent.insert(0, value.trim());
          prefs.setStringList('recent', recent.take(8).toList());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: ctl,
          onChanged: change,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search movies, shows, people',
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: () {
                ctl.clear();
                setState(() => query = '');
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: ['multi', 'movie', 'tv', 'person'].map((value) {
              return ChoiceChip(
                label: Text(
                  value == 'multi'
                      ? 'All'
                      : value[0].toUpperCase() + value.substring(1),
                ),
                selected: filter == value,
                onSelected: (_) => setState(() => filter = value),
              );
            }).toList(),
          ),
          Expanded(
            child: query.isEmpty
                ? FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) {
                      final recent =
                          snapshot.data?.getStringList('recent') ?? [];
                      return ListView(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'Recent searches',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          for (final item in recent)
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(item),
                              onTap: () {
                                ctl.text = item;
                                setState(() => query = item);
                              },
                            ),
                        ],
                      );
                    },
                  )
                : SearchResultsPage(
                    query: query,
                    kind: filter,
                    language: widget.language,
                    toggle: widget.toggle,
                    watchlist: widget.watchlist,
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchResultsPage extends StatelessWidget {
  final String? query;
  final String kind, language;
  final void Function(Map) toggle;
  final List<int> watchlist;
  const SearchResultsPage(
      {super.key,
      this.query,
      required this.kind,
      required this.language,
      required this.toggle,
      required this.watchlist});
  Future<List<Map<String, dynamic>>> _fetch() async {
    if (Tmdb.demoMode) {
      return query == null
          ? DemoCatalog.browse(kind)
          : DemoCatalog.search(query!, kind);
    }
    if (query == null) {
      final p = kind == 'tv' ? 'tv/popular' : 'movie/popular';
      return Tmdb.list(p, query: {'language': language});
    }
    final path = 'search/$kind';
    return Tmdb.list(path, query: {
      'query': query!,
      'language': language,
      'include_adult': 'false'
    });
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetch(),
          builder: (context, s) {
            if (s.hasError) {
              return _ErrorState(
                  message: s.error.toString(),
                  retry: () => (context as Element).markNeedsBuild());
            }
            if (!s.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _red));
            }
            if (s.data!.isEmpty) {
              return const Center(
                  child: Text('No titles found. Try another search.'));
            }
            return LayoutBuilder(builder: (context, c) {
              final count = c.maxWidth > 1000
                  ? 6
                  : c.maxWidth > 700
                      ? 4
                      : c.maxWidth > 480
                          ? 3
                          : 2;
              return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      childAspectRatio: .59,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14),
                  itemCount: s.data!.length,
                  itemBuilder: (context, i) => _PosterCard(
                      movie: s.data![i],
                      toggle: toggle,
                      watchlist: watchlist,
                      language: language));
            });
          });
}

class WatchlistPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map) toggle;
  const WatchlistPage({super.key, required this.items, required this.toggle});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child: Text(
              'Your list is empty. Save movies and shows to find them here.'));
    }
    return LayoutBuilder(builder: (context, c) {
      final count = c.maxWidth > 1000
          ? 6
          : c.maxWidth > 700
              ? 4
              : c.maxWidth > 480
                  ? 3
                  : 2;
      return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: .59,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14),
          itemCount: items.length,
          itemBuilder: (context, i) => _PosterCard(
              movie: items[i],
              toggle: toggle,
              watchlist: items.map((e) => e['id'] as int).toList(),
              language: 'en'));
    });
  }
}

class SettingsPage extends StatefulWidget {
  final String name, language;
  final List<String> contentLanguages;
  final void Function(String, List<String>) onSave;
  final VoidCallback onLogout;
  const SettingsPage(
      {super.key,
      required this.name,
      required this.language,
      required this.contentLanguages,
      required this.onSave,
      required this.onLogout});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String lang;
  late List<String> content;
  @override
  void initState() {
    super.initState();
    lang = widget.language;
    content = [...widget.contentLanguages];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Profile & settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(
            radius: 32,
            backgroundColor: _red.withValues(alpha: .25),
            child: Text(
                widget.name.isEmpty ? 'G' : widget.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 26))),
        const SizedBox(height: 10),
        Center(
            child: Text(widget.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold))),
        const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 5),
            child: Text('Interface language',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DropdownButtonFormField<String>(
            initialValue: lang,
            items: _languages.entries
                .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => lang = v);
              }
            }),
        const Padding(
            padding: EdgeInsets.only(top: 22, bottom: 8),
            child: Text('Preferred content languages',
                style: TextStyle(fontWeight: FontWeight.bold))),
        ..._languages.entries.map((e) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.value),
            value: content.contains(e.key),
            onChanged: (v) => setState(
                () => v == true ? content.add(e.key) : content.remove(e.key)))),
        const Text(
            'Content language filters affect discovery where supported. They do not guarantee dubbed audio or subtitles.',
            style: TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: () {
              widget.onSave(lang, content);
              Navigator.pop(context);
            },
            child: const Text('Save preferences')),
        const SizedBox(height: 18),
        OutlinedButton.icon(
            onPressed: () {
              SharedPreferences.getInstance().then((p) => p.remove('recent'));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared.')));
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear search history')),
        const SizedBox(height: 8),
        TextButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'))
      ]));
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _ErrorState({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined,
                size: 44, color: Colors.white54),
            const SizedBox(height: 14),
            const Text("We couldn't load titles",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'))
          ])));
}
