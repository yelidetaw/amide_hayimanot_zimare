// lib/main.dart

import 'dart:async';
import 'dart:math';
import 'package:amidehayimanot_zimare/add.dart';
import 'package:amidehayimanot_zimare/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:amidehayimanot_zimare/app_drawer.dart';
import 'package:amidehayimanot_zimare/detail_page.dart';
import 'package:amidehayimanot_zimare/mezmur_poem.dart';
import 'package:amidehayimanot_zimare/category_data.dart';
import 'package:amidehayimanot_zimare/aboutus.dart';

// --- Theme colors ---
const Color kBrandedPrimary = Color(0xFF013b6d);
const Color kBrandedAccent = Color(0xFFf5b916);
const Color kBrandedCard =    Color(0xFF024b8f);

const Color kDarkPrimary = Color(0xFF121212);
const Color kDarkAccent = Color(0xFFF3BD46);
const Color kDarkCard = Color.fromARGB(255, 28, 28, 40);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  List<Map<String, dynamic>> _searchResults = [];
  int? _lastActivityCategoryId;
  bool _isLoading = true;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<Widget>? _pages;
  Timer? _debounce;
  final List<Map<String, dynamic>> _allHymnsForSearch = [];

  @override
  void initState() {
    super.initState();
    _prepareSearchData();
    _pages = [
      HomePage(onToggleTheme: toggleTheme, setLastActivity: setLastActivity, navigatorKey: navigatorKey, onSearchTapped: () => setState(() => _isSearchActive = true)),
      AllMezmursScreen(onToggleTheme: toggleTheme, setLastActivity: setLastActivity, navigatorKey: navigatorKey),
      const AboutUsBody(),
    ];
    _loadThemeMode();
    _loadLastActivity();
    _searchController.addListener(_onSearchChanged);
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _prepareSearchData() {
    hymnsDatabase.forEach((categoryId, hymns) {
      hymns.forEach((itemId, content) {
        final title = content.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'Hymn $itemId');
        _allHymnsForSearch.add({'categoryId': categoryId, 'itemId': itemId, 'title': title, 'content': content});
      });
    });
  }
  
  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    List<int> v0 = List.generate(s2.length + 1, (i) => i);
    List<int> v1 = List.generate(s2.length + 1, (i) => 0);
    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      v0 = List.from(v1);
    }
    return v1[s2.length];
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _performSearch();
        });
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }

    final Set<int> addedHymnIds = {};
    final List<Map<String, dynamic>> results = [];

    for (final mezmur in _allHymnsForSearch) {
      final title = mezmur['title'].toString().toLowerCase();
      final content = mezmur['content'].toString().toLowerCase();
      final uniqueId = mezmur['categoryId'] * 10000 + mezmur['itemId'];

      if (title.contains(query)) {
        if (addedHymnIds.add(uniqueId)) results.add(mezmur);
        continue;
      }

      final titleWords = title.split(RegExp(r'\s+'));
      for (final word in titleWords) {
        final distance = _levenshtein(word, query);
        final similarity = 1 - (distance / max(word.length, query.length));
        if (similarity >= 0.8) {
          if (addedHymnIds.add(uniqueId)) results.add(mezmur);
          break;
        }
      }
      if (addedHymnIds.contains(uniqueId)) continue;
      
      if (content.contains(query)) {
        if (addedHymnIds.add(uniqueId)) results.add(mezmur);
      }
    }
    if (mounted) setState(() => _searchResults = results);
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void toggleTheme() {
    setState(() => themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    _saveThemeMode();
  }

  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
  }

  void setLastActivity(int categoryId, {int? itemId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastActivityCategoryId', categoryId);
    if (itemId != null) await prefs.setInt('lastActivityItemId', itemId);
    else await prefs.remove('lastActivityItemId');
    if (mounted) setState(() => _lastActivityCategoryId = categoryId);
  }

  void _loadLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _lastActivityCategoryId = prefs.getInt('lastActivityCategoryId'));
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        _isSearchActive = false;
        _searchController.clear();
      });
    }
    if (navigatorKey.currentState?.canPop() ?? false) {
      Navigator.of(navigatorKey.currentContext!).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amde Hayimanot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kBrandedPrimary,
        scaffoldBackgroundColor: kBrandedPrimary,
        fontFamily: 'NotoSansEthiopic',
        colorScheme: const ColorScheme.light(
          primary: kBrandedPrimary,
          secondary: kBrandedAccent,
          background: kBrandedPrimary,
          onBackground: Colors.white,
          surface: kBrandedCard,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF024b8f),
          foregroundColor: kBrandedAccent,
          titleTextStyle: TextStyle(color: kBrandedAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'NotoSansEthiopic'),
          iconTheme: IconThemeData(color: kBrandedAccent),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF024b8f),
          selectedItemColor: kBrandedAccent,
          unselectedItemColor: Colors.white70,
        ),
        cardColor: kBrandedCard,
        textTheme: Typography.material2021().black.apply(fontFamily: 'NotoSansEthiopic'),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kDarkPrimary,
        scaffoldBackgroundColor: kDarkPrimary,
        fontFamily: 'NotoSansEthiopic',
        colorScheme: const ColorScheme.dark(
          primary: kDarkPrimary,
          secondary: kDarkAccent,
          background: kDarkPrimary,
          onBackground: Colors.white,
          surface: kDarkCard,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkCard,
          foregroundColor: kDarkAccent,
          titleTextStyle: TextStyle(color: kDarkAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'NotoSansEthiopic'),
          iconTheme: IconThemeData(color: kDarkAccent),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kDarkCard,
          selectedItemColor: kDarkAccent,
          unselectedItemColor: Colors.grey,
        ),
        cardColor: kDarkCard,
        textTheme: Typography.material2021().white.apply(fontFamily: 'NotoSansEthiopic'),
      ),
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      home: _isLoading || _pages == null ? const AnimatedSplashScreen() : _buildMainScaffold(),
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages!),
          if (_isSearchActive) _buildSearchResultsOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'All Hymns'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      drawer: AppDrawer(
          onToggleTheme: toggleTheme,
          setLastActivity: setLastActivity,
          navigatorKey: navigatorKey,
          lastActivityCategoryId: _lastActivityCategoryId),
    );
  }

  AppBar _buildAppBar() {
    final theme = Theme.of(context);
    Widget titleWidget;

    if (_isSearchActive) {
      titleWidget = _buildSearchField(theme);
    } else {
      titleWidget = Text(
        _selectedIndex == 0 ? 'Amde Hayimanot' : (_selectedIndex == 1 ? 'All Hymns' : 'About Us'),
      );
    }

    return AppBar(
      title: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: titleWidget),
      actions: [
        IconButton(
          icon: Icon(_isSearchActive ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _isSearchActive = !_isSearchActive;
            if (!_isSearchActive) _searchController.clear();
          }),
        ),
        IconButton(
          icon: Icon(theme.brightness == Brightness.dark ? Icons.wb_sunny : Icons.mode_night),
          onPressed: toggleTheme,
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      key: const ValueKey('searchField'),
      height: 40,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: theme.appBarTheme.foregroundColor, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: theme.appBarTheme.foregroundColor?.withOpacity(0.7)),
          hintText: 'Search hymns...',
          hintStyle: TextStyle(color: theme.appBarTheme.foregroundColor?.withOpacity(0.7)),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  color: theme.appBarTheme.foregroundColor?.withOpacity(0.7),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay() {
    final theme = Theme.of(context);
    final query = _searchController.text;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: _searchResults.isEmpty && query.isNotEmpty
          ? _buildEmptyState()
          : AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildResultListItem(result, query, theme),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
  
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Opacity(
        opacity: 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 100, color: theme.colorScheme.onBackground.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('No Results Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground.withOpacity(0.8))),
            const SizedBox(height: 8),
            Text('Try a different spelling or search term.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultListItem(Map<String, dynamic> result, String query, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: _highlightText(result['title'], query, theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text('Category: ${getCategoryTitle(result['categoryId'])}', style: theme.textTheme.bodyMedium),
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() { _isSearchActive = false; _searchController.clear(); });
            navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => DetailPage(
              title: result['title'], id: result['categoryId'], itemId: result['itemId'],
              onToggleTheme: toggleTheme, setLastActivity: setLastActivity, navigatorKey: navigatorKey,
            )));
          },
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query, TextStyle style) {
    if (query.isEmpty) {
      return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: style);
    }
    
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery = textLower.indexOf(queryLower, start)) != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfQuery, indexOfQuery + query.length),
        style: style.copyWith(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
      ));
      start = indexOfQuery + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});
  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade, _logoScale, _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _controller.forward();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandedPrimary,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset('assets/images/amide.jpeg', width: 180, height: 180),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _textFade,
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: kBrandedAccent,
                  period: const Duration(milliseconds: 2500),
                  child: const Text(
                    'ጅማ ዓምደ ሃይማኖት ዝማሬ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}