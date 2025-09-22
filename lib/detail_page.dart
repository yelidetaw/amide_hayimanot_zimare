// lib/detail_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/mezmur_poem.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final int id;
  final int itemId;
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final GlobalKey<NavigatorState> navigatorKey;

  const DetailPage({
    Key? key,
    required this.title,
    required this.id,
    required this.itemId,
    required this.onToggleTheme,
    required this.setLastActivity,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double _baseFontSize = 14.0;
  double _currentScale = 1.0;
  double _initialPinchScale = 1.0;
  static const double _minScale = 0.8;
  static const double _maxScale = 3.0;
  static const double _fontSizeStep = 2.0;

  late PageController _pageController;
  late List<int> _allHymnItemIdsInCurrentCategory;
  late int _currentHymnIndex;

  String _currentDisplayedTitle = '';
  int _currentDisplayedItemId = 0;
  bool _showBackgroundImage = true;

  @override
  void initState() {
    super.initState();
    final hymnsInThisCategory = hymnsDatabase[widget.id];
    if (hymnsInThisCategory != null) {
      _allHymnItemIdsInCurrentCategory = hymnsInThisCategory.keys.toList()..sort();
    } else {
      _allHymnItemIdsInCurrentCategory = [];
    }
    _currentHymnIndex = _allHymnItemIdsInCurrentCategory.indexOf(widget.itemId);
    if (_currentHymnIndex == -1) _currentHymnIndex = 0;
    _updateDisplayedHymnDetails(_currentHymnIndex);
    _pageController = PageController(initialPage: _currentHymnIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _baseFontSize = MediaQuery.of(context).size.width * 0.035);
    });
    widget.setLastActivity(widget.id, itemId: widget.itemId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleBackgroundImage() => setState(() => _showBackgroundImage = !_showBackgroundImage);

  void _updateDisplayedHymnDetails(int index) {
    if (index >= 0 && index < _allHymnItemIdsInCurrentCategory.length) {
      final newItemId = _allHymnItemIdsInCurrentCategory[index];
      final newTitle = hymnsDatabase[widget.id]![newItemId]?.split('\n').first.trim() ?? 'Untitled';
      setState(() {
        _currentDisplayedItemId = newItemId;
        _currentDisplayedTitle = newTitle;
      });
      widget.setLastActivity(widget.id, itemId: newItemId);
    }
  }

  String? _getBackgroundImage(int categoryId) {
    final Map<int, String> categoryImageMap = {
      1: 'assets/images/am-1.jpg', 2: 'assets/images/am-2.png', 3: 'assets/images/am-3.png',
      4: 'assets/images/am-4.jpeg', 5: 'assets/images/am-5.jpeg', 6: 'assets/images/am-6.png',
      7: 'assets/images/am-7.jpeg', 8: 'assets/images/logo.jpeg', 9: 'assets/images/am-9.jpeg',
      10: 'assets/images/am-10.png', 11: 'assets/images/hibiret.jpg', 12: 'assets/images/am-1.jpg',
      13: 'assets/images/am-2.png', 14: 'assets/images/am-3.png', 15: 'assets/images/am-4.jpeg',
      16: 'assets/images/am-1.jpg', 17: 'assets/images/am-2.png', 18: 'assets/images/am-2.png',
      19: 'assets/images/am-2.png', 20: 'assets/images/am-4.jpeg', 21: 'assets/images/am-21.png',
      22: 'assets/images/am-22.jpeg', 23: 'assets/images/am-23.png', 24: 'assets/images/am-24.jpg',
      25: 'assets/images/hosaina.jpeg', 26: 'assets/images/am-26.png', 27: 'assets/images/am-27.png',
      28: 'assets/images/am-9.jpeg', 29: 'assets/images/am-10.png', 30: 'assets/images/am-22.jpeg',
      31: 'assets/images/am-23.png', 32: 'assets/images/am-24.jpg', 33: 'assets/images/hosaina.jpeg',
      34: 'assets/images/am-26.png', 35: 'assets/images/am-9.jpeg', 37: 'assets/images/am-2.png',
      38: 'assets/images/am-3.png', 39: 'assets/images/19.jpg', 40: 'assets/images/am-2.png', 
      41: 'assets/images/3.jpg', 42: 'assets/images/30.jpg', 43: 'assets/images/17.jpg',
      44: 'assets/images/am-6.png',


    };
    return categoryImageMap[categoryId];
  }

  void _zoomIn() => setState(() => _currentScale = (_currentScale + (_fontSizeStep / _baseFontSize)).clamp(_minScale, _maxScale));
  void _zoomOut() => setState(() => _currentScale = (_currentScale - (_fontSizeStep / _baseFontSize)).clamp(_minScale, _maxScale));
  void _resetZoom() => setState(() => _currentScale = 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBrandedTheme = theme.brightness == Brightness.light;
    final accentColor = theme.colorScheme.secondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundImage = _getBackgroundImage(widget.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentDisplayedItemId}. $_currentDisplayedTitle',
          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w700),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_showBackgroundImage ? Icons.image_not_supported : Icons.image),
            tooltip: _showBackgroundImage ? 'Hide Background' : 'Show Background',
            onPressed: _toggleBackgroundImage,
          ),
          IconButton(
            icon: Icon(isBrandedTheme ? Icons.mode_night : Icons.wb_sunny),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset zoom',
            onPressed: _resetZoom,
          ),
        ],
      ),
      // --- THE FIX IS HERE ---
      // The GestureDetector now wraps the entire body of the Scaffold.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures the detector catches gestures on empty space
        onScaleStart: (details) => _initialPinchScale = _currentScale,
        onScaleUpdate: (details) => setState(() => _currentScale = (_initialPinchScale * details.scale).clamp(_minScale, _maxScale)),
        child: Stack(
          children: [
            _buildBackground(theme, isBrandedTheme, backgroundImage),
            PageView.builder(
              controller: _pageController,
              itemCount: _allHymnItemIdsInCurrentCategory.length,
              onPageChanged: (index) {
                _currentHymnIndex = index;
                _updateDisplayedHymnDetails(index);
              },
              itemBuilder: (context, index) {
                final currentHymnId = _allHymnItemIdsInCurrentCategory[index];
                final hymnContent = hymnsDatabase[widget.id]?[currentHymnId] ?? "Content not found.";
                return _buildHymnContent(theme, isBrandedTheme, hymnContent);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomInBtn',
            onPressed: _zoomIn,
            backgroundColor: accentColor,
            foregroundColor: isBrandedTheme ? theme.colorScheme.primary : Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoomOutBtn',
            onPressed: _zoomOut,
            backgroundColor: accentColor,
            foregroundColor: isBrandedTheme ? theme.colorScheme.primary : Colors.white,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, bool isBrandedTheme, String? backgroundImage) {
    if (_showBackgroundImage && backgroundImage != null) {
      return Positioned.fill(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          child: Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: theme.scaffoldBackgroundColor,
              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.withOpacity(0.5), size: 50),
            ),
          ),
        ),
      );
    } else {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            gradient: isBrandedTheme
                ? LinearGradient(
                    colors: [theme.scaffoldBackgroundColor, theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
        ),
      );
    }
  }

  Widget _buildHymnContent(ThemeData theme, bool isBrandedTheme, String hymnContent) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final lineCount = hymnContent.split('\n').length;
    final isShortHymn = lineCount <= 7;
    final currentFontSize = (_baseFontSize * _currentScale) * (isShortHymn ? 1.4 : 1.0);

    final textWidget = SelectableText(
      hymnContent,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: currentFontSize,
        height: 1.6,
        fontWeight: FontWeight.w800,
        color: theme.textTheme.bodyLarge?.color,
        letterSpacing: 0.3,
        shadows: isBrandedTheme ? null : const [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))],
      ),
    );

    return SingleChildScrollView(
      // Important: Prevents this scroll view from interfering with the GestureDetector
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.05,
        ),
        child: Center(
          child: isBrandedTheme
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: textWidget,
                    ),
                  ),
                )
              : (isShortHymn
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: textWidget,
                    )
                  : textWidget),
        ),
      ),
    );
  }
}