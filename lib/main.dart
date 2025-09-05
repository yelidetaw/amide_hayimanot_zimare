import 'package:amidehayimanot_zimare/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:amidehayimanot_zimare/app_drawer.dart';
import 'package:amidehayimanot_zimare/detail_page.dart';
import 'package:amidehayimanot_zimare/mezmur_poem.dart';
import 'package:amidehayimanot_zimare/category_data.dart';
import 'package:amidehayimanot_zimare/aboutus.dart';
import 'package:amidehayimanot_zimare/add.dart';

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
  ThemeMode themeMode = ThemeMode.system;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  List<Map<String, dynamic>> _searchResults = [];
  int? _lastActivityCategoryId;
  bool _isLoading = true;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadLastActivity();
    _searchController.addListener(_onSearchChanged);
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        themeMode = (prefs.getBool('isDarkMode') ?? false)
            ? ThemeMode.dark
            : ThemeMode.light;
      });
    }
  }

  void toggleTheme() {
    setState(() {
      themeMode =
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _saveThemeMode();
  }

  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
  }

  void setLastActivity(int categoryId, {int? itemId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastActivityCategoryId', categoryId);
    if (itemId != null) {
      await prefs.setInt('lastActivityItemId', itemId);
    } else {
      await prefs.remove('lastActivityItemId');
    }
    if (mounted) {
      setState(() {
        _lastActivityCategoryId = categoryId;
      });
    }
  }

  void _loadLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _lastActivityCategoryId = prefs.getInt('lastActivityCategoryId');
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _showSearchResults = false;
          _searchResults = [];
        });
      }
      return;
    }

    final List<Map<String, dynamic>> results = [];
    hymnsDatabase.forEach((categoryId, hymns) {
      hymns.forEach((itemId, content) {
        final title = content
            .split('\n')
            .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
        if (title.toLowerCase().contains(query.toLowerCase()) ||
            content.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'categoryId': categoryId,
            'itemId': itemId,
            'title': title,
          });
        }
      });
    });

    if (mounted) {
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
      });
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        _showSearchResults = false;
        _searchController.clear();
      });
    }

    // Close the drawer if it's open when switching tabs
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
        primaryColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1E1E),
          primary: const Color(0xFF1E1E1E),
          secondary: const Color(0xFFF3BD46),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 56, 30, 88),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 56, 30, 88),
          primary: const Color.fromARGB(255, 56, 30, 88),
          secondary: const Color(0xFFF3BD46),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 56, 30, 88),
          foregroundColor: Color(0xFFF3BD46),
          titleTextStyle: TextStyle(
            color: Color(0xFFF3BD46),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFF3BD46)),
        ),
      ),
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      home: _isLoading
          ? const AnimatedSplashScreen()
          : Scaffold(
              appBar: AppBar(
                title: _selectedIndex == 0
                    ? _showSearchResults
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search hymns...',
                              hintStyle: TextStyle(
                                color: themeMode == ThemeMode.dark
                                    ? Colors.grey[400]
                                    : Colors.white70,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: themeMode == ThemeMode.dark
                                  ? const Color(0xFFF3BD46)
                                  : Colors.white,
                            ),
                          )
                        : Text(
                            'Amde Hayimanot',
                            style: TextStyle(
                              color: themeMode == ThemeMode.dark
                                  ? const Color(0xFFF3BD46)
                                  : Colors.white,
                            ),
                          )
                    : Text(
                        _getPageTitle(_selectedIndex),
                        style: TextStyle(
                          color: themeMode == ThemeMode.dark
                              ? const Color(0xFFF3BD46)
                              : Colors.white,
                        ),
                      ),
                actions: [
                  if (_selectedIndex == 0)
                    IconButton(
                      icon: Icon(
                        _showSearchResults ? Icons.close : Icons.search,
                        color: themeMode == ThemeMode.dark
                            ? const Color(0xFFF3BD46)
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSearchResults = !_showSearchResults;
                          if (!_showSearchResults) {
                            _searchController.clear();
                          }
                        });
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.wb_sunny
                          : Icons.mode_night,
                      color: themeMode == ThemeMode.dark
                          ? const Color(0xFFF3BD46)
                          : Colors.white,
                    ),
                    onPressed: toggleTheme,
                  ),
                ],
              ),
              body: _showSearchResults
                  ? _buildSearchResults()
                  : _getScreenContent(_selectedIndex),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: 'Add',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    label: 'About Us',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: themeMode == ThemeMode.dark
                    ? const Color(0xFFF3BD46)
                    : Theme.of(context).primaryColor,
                unselectedItemColor:
                    themeMode == ThemeMode.dark ? Colors.grey : Colors.black54,
                backgroundColor: themeMode == ThemeMode.dark
                    ? const Color.fromARGB(255, 56, 30, 88)
                    : Colors.white,
                onTap: _onItemTapped,
              ),
              drawer: AppDrawer(
                onToggleTheme: toggleTheme,
                setLastActivity: setLastActivity,
                navigatorKey: navigatorKey,
                lastActivityCategoryId: _lastActivityCategoryId,
              ),
            ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Amde Hayimanot';
      case 1:
        return 'Add Content';
      case 2:
        return 'About Us';
      default:
        return 'Amde Hayimanot';
    }
  }

  Widget _getScreenContent(int index) {
    switch (index) {
      case 0:
        return HomePage(
          onToggleTheme: toggleTheme,
          setLastActivity: setLastActivity,
          lastActivityCategoryId: _lastActivityCategoryId,
          navigatorKey: navigatorKey,
        );
      case 1:
        return const Add();
      case 2:
        return const AboutUsBody();
      default:
        return HomePage(
          onToggleTheme: toggleTheme,
          setLastActivity: setLastActivity,
          lastActivityCategoryId: _lastActivityCategoryId,
          navigatorKey: navigatorKey,
        );
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final theme = Theme.of(context);
        return ListTile(
          title: Text(result['title'],
              style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          subtitle: Text('Category: ${getCategoryTitle(result['categoryId'])}',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          onTap: () {
            setState(() {
              _showSearchResults = false;
              _searchController.clear();
            });
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  title: result['title'],
                  id: result['categoryId'],
                  itemId: result['itemId'],
                  onToggleTheme: toggleTheme,
                  setLastActivity: setLastActivity,
                  navigatorKey: navigatorKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color backgroundColor =
        isDarkMode ? const Color(0xFF1E1E2D) : const Color(0xFF1E1E1E);
    final Color textColor = isDarkMode ? const Color(0xFFF3BD46) : Colors.white;
    final Color highlightColor =
        isDarkMode ? Colors.white : const Color(0xFFF3BD46).withOpacity(0.8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: Image.asset(
                  'assets/images/amide.png',
                  width: 180,
                  height: 180,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Shimmer.fromColors(
                baseColor: textColor,
                highlightColor: highlightColor,
                period: const Duration(milliseconds: 2500),
                child: Text(
                  'ጅማ ዓምደ ሃይማኖት ዝማሬ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
