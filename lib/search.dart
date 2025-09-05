// lib/home_page.dart
import 'package:amidehayimanot_zimare/list.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/category_data.dart'; // New import for centralized data
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final int? lastActivityCategoryId;
  final GlobalKey<NavigatorState> navigatorKey;

  const HomePage({
    Key? key,
    required this.onToggleTheme,
    required this.setLastActivity,
    this.lastActivityCategoryId,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  Timer? _timer;

  // This list is for the main image slider at the bottom
  final List<String> _imagePaths = [
    "assets/images/photo_2025-06-16_15-58-14.jpg",
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/am-8.jpg',
    'assets/images/3.jpg',
    'assets/images/5.jpg',
    'assets/images/image1.png',
    'assets/images/IMG_1446.jpg',
    'assets/images/IMG_6612.jpg',
    'assets/images/IMG_6688.jpg',
    'assets/images/IMG_7551.jpg',
    'assets/images/IMG_8279.jpg',
    'assets/images/am-19.jpg',
  ];

  // This list should ideally have the same number of items as `topLevelCategories`
  final List<String> _categoryImagePaths = [
    "assets/images/am-1.jpg",
    "assets/images/am-2.jpg",
    "assets/images/am-3.jpg",
    "assets/images/am-4.jpg",
    "assets/images/am-5.jpg",
    "assets/images/am-6.jpg",
    "assets/images/am-7.jpg",
    "assets/images/am-8.jpg",
    "assets/images/am-9.jpg",
    "assets/images/am-10.jpg",
    "assets/images/am-11.jpg",
    "assets/images/am-1.jpg",
    "assets/images/am-2.jpg",
    "assets/images/am-3.jpg",
    "assets/images/am-4.jpg",
    "assets/images/am-9.jpg",
    "assets/images/am-10.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      _currentPageIndex = (_currentPageIndex + 1) % _imagePaths.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // NOTE: The two methods below are no longer needed because we use `category_data.dart`
  // int _getContentIdFromIndex(int index) => index + 1;
  // String _getCategoryName(int index) { ... }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- Color Definitions ---
    const Color lightModeAccent = Color(0xFFC58940);
    const Color lightModeBg = Color(0xFFF8F5F1);
    const Color lightModeCardBg = Colors.white;
    const Color lightModePrimaryText = Color(0xFF404040);
    final Color lightModeSecondaryText = Colors.grey.shade600;

    const Color darkModeAccent = Colors.amber;
    final Color darkModeBg = Theme.of(context).scaffoldBackgroundColor;
    final Color darkModeCardBg = Theme.of(context).cardColor; // Use theme color
    final Color darkModePrimaryText = Colors.white.withOpacity(0.9);
    const Color darkModeSecondaryText = Colors.white70;

    // --- Applied Colors ---
    final Color accentColor = isDarkMode ? darkModeAccent : lightModeAccent;
    final Color bgColor = isDarkMode ? darkModeBg : lightModeBg;
    final Color cardBgColor = isDarkMode ? darkModeCardBg : lightModeCardBg;
    final Color primaryTextColor =
        isDarkMode ? darkModePrimaryText : lightModePrimaryText;
    final Color secondaryTextColor =
        isDarkMode ? darkModeSecondaryText : lightModeSecondaryText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildHeaderImage(screenSize, cardBgColor),
                const SizedBox(height: 20),
                _buildTitleText(screenSize, primaryTextColor),
                const SizedBox(height: 24),
                _buildCategoryRow(
                  screenSize,
                  accentColor,
                  cardBgColor,
                  primaryTextColor,
                ),
                const SizedBox(height: 24),
                _buildImageSlider(screenSize, accentColor, cardBgColor),
                const SizedBox(height: 20),
                _buildFooterText(screenSize, secondaryTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeaderImage(Size screenSize, Color cardBgColor) {
    return Container(
      height: screenSize.height * 0.2,
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          'assets/images/amide.jpg',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitleText(Size screenSize, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
      child: Text(
        'የጅማ ደብረ ኤፍራታ ቅድስት ድንግል ማርያም ካቴድራል ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: (screenSize.width * 0.04).clamp(16.0, 20.0),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    Size screenSize,
    Color accentColor,
    Color cardBgColor,
    Color textColor,
  ) {
    return SizedBox(
      height: screenSize.height * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        // *** CHANGE 1: Use the length of the central category list ***
        itemCount: topLevelCategories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(
            index,
            screenSize,
            accentColor,
            cardBgColor,
            textColor,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    int index,
    Size screenSize,
    Color accentColor,
    Color cardBgColor,
    Color textColor,
  ) {
    // *** CHANGE 2: Get the correct category ID from our central list ***
    final categoryId = topLevelCategories[index];

    return GestureDetector(
      onTap: () {
        // *** CHANGE 3: Use the correct categoryId for navigation ***
        widget.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ListScreen(
              categoryId, // Use the real ID
              onToggleTheme: widget.onToggleTheme,
              setLastActivity: widget.setLastActivity,
              navigatorKey: widget.navigatorKey,
            ),
          ),
        );
        widget.setLastActivity(categoryId); // Use the real ID
      },
      child: Container(
        width: screenSize.width * 0.22,
        margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.015),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: screenSize.width * 0.065,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage(
                  // Ensure this list has enough images for all categories
                  _categoryImagePaths[index % _categoryImagePaths.length],
                ),
              ),
            ),
            const Spacer(),
            Text(
              // *** CHANGE 4: Get the title from our central function ***
              getCategoryTitle(categoryId),
              style: TextStyle(
                fontSize: (screenSize.width * 0.028).clamp(10.0, 12.0),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(
    Size screenSize,
    Color accentColor,
    Color cardBgColor,
  ) {
    return Container(
      height: screenSize.height * 0.22,
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _imagePaths.length,
            onPageChanged: (int page) {
              setState(() => _currentPageIndex = page);
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  _imagePaths[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _imagePaths.length,
              effect: ExpandingDotsEffect(
                activeDotColor: accentColor,
                dotColor: Colors.grey.withOpacity(0.5),
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(Size screenSize, Color textColor) {
    return Text(
      'ሰንበት ትምህርት ቤቱ በአገልግሎት ላይ!!!',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: (screenSize.width * 0.035).clamp(12.0, 15.0),
        color: textColor,
      ),
    );
  }
}
