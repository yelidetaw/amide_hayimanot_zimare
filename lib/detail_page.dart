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
      _allHymnItemIdsInCurrentCategory = hymnsInThisCategory.keys.toList();
      _allHymnItemIdsInCurrentCategory.sort();
    } else {
      _allHymnItemIdsInCurrentCategory = [];
    }

    _currentHymnIndex = _allHymnItemIdsInCurrentCategory.indexOf(widget.itemId);
    if (_currentHymnIndex == -1 &&
        _allHymnItemIdsInCurrentCategory.isNotEmpty) {
      _currentHymnIndex = 0;
    } else if (_currentHymnIndex == -1) {
      _currentHymnIndex = 0;
    }

    _updateDisplayedHymnDetails(_currentHymnIndex);
    _pageController = PageController(initialPage: _currentHymnIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _baseFontSize = MediaQuery.of(context).size.width * 0.035;
      });
    });

    widget.setLastActivity(widget.id, itemId: widget.itemId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleBackgroundImage() {
    setState(() {
      _showBackgroundImage = !_showBackgroundImage;
    });
  }

  void _updateDisplayedHymnDetails(int index) {
    if (index >= 0 && index < _allHymnItemIdsInCurrentCategory.length) {
      final newItemId = _allHymnItemIdsInCurrentCategory[index];
      final newTitle =
          hymnsDatabase[widget.id]![newItemId]?.split('\n').first.trim() ??
              'Untitled';
      setState(() {
        _currentDisplayedItemId = newItemId;
        _currentDisplayedTitle = newTitle;
      });
      widget.setLastActivity(widget.id, itemId: newItemId);
    }
  }

  String? _getBackgroundImage(int categoryId) {
    final Map<int, String> categoryImageMap = {
      1: 'assets/images/am-1.jpg',
      2: 'assets/images/am-2.jpg',
      3: 'assets/images/am-3.jpg',
      4: 'assets/images/am-4.jpg',
      5: 'assets/images/am-5.jpg',
      6: 'assets/images/am-6.jpg',
      7: 'assets/images/am-7.jpg',
      8: 'assets/images/am-8.jpg',
      9: 'assets/images/am-9.jpg',
      10: 'assets/images/am-10.jpg',
      11: 'assets/images/am-8.jpg',
      12: 'assets/images/am-1.jpg',
      13: 'assets/images/am-2.jpg',
      14: 'assets/images/am-3.jpg',
      15: 'assets/images/am-4.jpg',
      16: 'assets/images/am-16.jpg',
      17: 'assets/images/am-2.jpg',
      18: 'assets/images/am-2.jpg',
      19: 'assets/images/am-2.jpg',
      20: 'assets/images/am-4.jpg',
      21: 'assets/images/am-21.jpg',
      22: 'assets/images/am-22.jpg',
      23: 'assets/images/am-23.jpg',
      24: 'assets/images/IMG_7155.jpg',
      25: 'assets/images/image.png',
      26: 'assets/images/am-26.jpg',
      27: 'assets/images/am-27.jpg',
      28: 'assets/images/am-9.jpg',
      29: 'assets/images/am-10.jpg',
      30: 'assets/images/am-22.jpg',
      31: 'assets/images/am-23.jpg',
      32: 'assets/images/IMG_7155.jpg',
      33: 'assets/images/image.png',
      34: 'assets/images/am-26.jpg',
      35: 'assets/images/am-9.jpg',
      37: 'assets/images/am-2.jpg',
    };

    return categoryImageMap[categoryId];
  }

  void _zoomIn() {
    setState(() {
      if (_currentScale * _baseFontSize < _maxScale * _baseFontSize) {
        _currentScale = (_currentScale + (_fontSizeStep / _baseFontSize)).clamp(
          _minScale,
          _maxScale,
        );
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_currentScale * _baseFontSize > _minScale * _baseFontSize) {
        _currentScale = (_currentScale - (_fontSizeStep / _baseFontSize)).clamp(
          _minScale,
          _maxScale,
        );
      }
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImage = _getBackgroundImage(widget.id);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final normalFontSize = _baseFontSize * _currentScale;
    final largeFontSize = normalFontSize * 1.4;

    final primaryColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.grey[900];
    final appBarColor = isDarkMode
        ? const Color.fromARGB(255, 56, 30, 88).withOpacity(0.9)
        : Colors.white.withOpacity(0.85);
    final iconColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentDisplayedItemId}. $_currentDisplayedTitle',
          style: TextStyle(
            color: iconColor,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: iconColor),
        backgroundColor: appBarColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              _showBackgroundImage ? Icons.image_not_supported : Icons.image,
            ),
            tooltip:
                _showBackgroundImage ? 'Hide Background' : 'Show Background',
            onPressed: _toggleBackgroundImage,
            color: iconColor,
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            color: iconColor,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset zoom',
            onPressed: _resetZoom,
            color: iconColor,
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (details) {
          _initialPinchScale = _currentScale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _currentScale = (_initialPinchScale * details.scale).clamp(
              _minScale,
              _maxScale,
            );
          });
        },
        child: Stack(
          children: [
            if (_showBackgroundImage && backgroundImage != null)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: isDarkMode
                      ? ColorFilter.mode(
                          Colors.black.withOpacity(0.6),
                          BlendMode.dstATop,
                        )
                      : ColorFilter.mode(
                          Colors.white.withOpacity(0.4),
                          BlendMode.dstATop,
                        ),
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                    // Add an error builder to handle cases where an image might be missing
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: backgroundColor,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.withOpacity(0.5),
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (!_showBackgroundImage)
              Positioned.fill(child: Container(color: backgroundColor)),
            PageView.builder(
              controller: _pageController,
              itemCount: _allHymnItemIdsInCurrentCategory.length,
              onPageChanged: (index) {
                _currentHymnIndex = index;
                _updateDisplayedHymnDetails(index);
              },
              itemBuilder: (context, index) {
                final currentHymnId = _allHymnItemIdsInCurrentCategory[index];
                final hymnContent = hymnsDatabase[widget.id]?[currentHymnId] ??
                    "Content not found.";
                final lineCount = hymnContent.split('\n').length;
                final isShortHymn = lineCount <= 7;
                final currentFontSize =
                    isShortHymn ? largeFontSize : normalFontSize;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              isShortHymn ? constraints.maxHeight * 0.8 : 0,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: isShortHymn
                                ? screenHeight * 0.1
                                : screenWidth * 0.04,
                          ),
                          child: Center(
                            child: isShortHymn
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SelectableText(
                                      hymnContent,
                                      style: TextStyle(
                                        fontSize: currentFontSize,
                                        height: 1.6,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : SelectableText(
                                    hymnContent,
                                    style: TextStyle(
                                      fontSize: currentFontSize,
                                      height: 1.6,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                );
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
            child: const Icon(Icons.add),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoomOutBtn',
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
