// lib/home_page.dart

import 'package:amidehayimanot_zimare/list.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/category_data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onSearchTapped;

  const HomePage({
    Key? key,
    required this.onToggleTheme,
    required this.setLastActivity,
    required this.navigatorKey,
    required this.onSearchTapped,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  late final ScrollController _categoryScrollController;
  int _currentPageIndex = 0;
  Timer? _timer;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  final List<String> _imagePaths = [
    "assets/images/am-24.jpg", "assets/images/hitsanat.JPG", "assets/images/hibiret.jpg",
    "assets/images/IMG_7322.JPG", "assets/images/IMG_6612.JPG", "assets/images/wereb.JPG",
  ];
  final List<String> _categoryImagePaths = [
    "assets/images/am-1.jpg", "assets/images/am-2.png", "assets/images/am-3.png", "assets/images/am-4.jpeg",
    "assets/images/am-5.jpeg", "assets/images/am-6.png", "assets/images/am-7.jpeg", "assets/images/logo.jpeg",
    "assets/images/am-9.jpeg", "assets/images/am-10.png", "assets/images/logo.jpeg", "assets/images/am-1.jpg",
    "assets/images/am-2.png", "assets/images/am-3.png", "assets/images/am-4.jpeg", "assets/images/am-9.jpeg",
    "assets/images/am-10.png",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _categoryScrollController = ScrollController();
    _categoryScrollController.addListener(_updateScrollability);
    _startAutoSlide();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollability());
  }

  void _updateScrollability() {
    if (!mounted || !_categoryScrollController.hasClients) return;
    final canScrollLeft = _categoryScrollController.offset > 0;
    final canScrollRight = _categoryScrollController.offset < _categoryScrollController.position.maxScrollExtent;
    if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
    }
  }

  void _scrollCategories(bool forward) {
    if (!_categoryScrollController.hasClients) return;
    final double scrollAmount = MediaQuery.of(context).size.width * 0.7;
    final double newOffset = forward
        ? (_categoryScrollController.offset + scrollAmount).clamp(0.0, _categoryScrollController.position.maxScrollExtent)
        : (_categoryScrollController.offset - scrollAmount).clamp(0.0, _categoryScrollController.position.maxScrollExtent);
    _categoryScrollController.animateTo(newOffset, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted || !_pageController.hasClients) return;
      _currentPageIndex = (_currentPageIndex + 1) % _imagePaths.length;
      _pageController.animateToPage(_currentPageIndex, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _categoryScrollController.removeListener(_updateScrollability);
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildHeaderImage(screenSize, theme),
                const SizedBox(height: 20),
                _buildTitleText(screenSize, theme),
                const SizedBox(height: 24),
                _buildCategoryRow(screenSize, theme),
                const SizedBox(height: 24),
                _buildImageSlider(screenSize, theme),
                const SizedBox(height: 20),
                _buildFooterText(screenSize, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(Size screenSize, ThemeData theme) {
    return Container(
      height: screenSize.height * 0.2,
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: theme.brightness == Brightness.dark ? null : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset('assets/images/efrata.jpeg', width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTitleText(Size screenSize, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
      child: Text(
        'የጅማ ደብረ ኤፍራታ ቅድስት ድንግል ማርያም ካቴድራል ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: (screenSize.width * 0.04).clamp(16.0, 20.0),
          fontWeight: FontWeight.bold,
          // Use the correct theme color for text on the background
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(Size screenSize, ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: screenSize.height * 0.15,
          child: ListView.builder(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            itemCount: topLevelCategories.length,
            itemBuilder: (context, index) => _buildCategoryItem(index, screenSize, theme),
          ),
        ),
        _buildScrollArrow(isVisible: _canScrollLeft, isLeft: true, onTap: () => _scrollCategories(false)),
        _buildScrollArrow(isVisible: _canScrollRight, isLeft: false, onTap: () => _scrollCategories(true)),
      ],
    );
  }

  Widget _buildScrollArrow({required bool isVisible, required bool isLeft, required VoidCallback onTap}) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(isLeft ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
              onPressed: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index, Size screenSize, ThemeData theme) {
    final categoryId = topLevelCategories[index];
    final accentColor = theme.colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        widget.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ListScreen(
          categoryId, onToggleTheme: widget.onToggleTheme, setLastActivity: widget.setLastActivity, navigatorKey: widget.navigatorKey,
        )));
        widget.setLastActivity(categoryId);
      },
      child: Container(
        width: screenSize.width * 0.22,
        margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.015),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: theme.brightness == Brightness.dark ? null : [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: screenSize.width * 0.065,
                backgroundColor: theme.brightness == Brightness.dark ? theme.scaffoldBackgroundColor : Colors.grey.shade200,
                backgroundImage: AssetImage(_categoryImagePaths[index % _categoryImagePaths.length]),
              ),
            ),
            const Spacer(),
            Text(
              getCategoryTitle(categoryId),
              style: TextStyle(
                fontSize: (screenSize.width * 0.028).clamp(10.0, 12.0),
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(Size screenSize, ThemeData theme) {
    return Container(
      height: screenSize.height * 0.22,
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: theme.brightness == Brightness.dark ? null : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _imagePaths.length,
            onPageChanged: (int page) => setState(() => _currentPageIndex = page),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(_imagePaths[index], width: double.infinity, fit: BoxFit.cover),
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _imagePaths.length,
              effect: ExpandingDotsEffect(
                activeDotColor: theme.colorScheme.secondary,
                dotColor: Colors.white.withOpacity(0.6),
                dotHeight: 8, dotWidth: 8, spacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(Size screenSize, ThemeData theme) {
    return Text(
      'ሰንበት ትምህርት ቤቱ በአገልግሎት ላይ!!!',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: (screenSize.width * 0.035).clamp(12.0, 15.0),
        // Use the correct theme color for text on the background
        color: theme.colorScheme.onBackground.withOpacity(0.8),
      ),
    );
  }
}