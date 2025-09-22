// lib/add.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/mezmur_poem.dart';
import 'package:amidehayimanot_zimare/detail_page.dart';
import 'package:amidehayimanot_zimare/category_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AllMezmursScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final GlobalKey<NavigatorState> navigatorKey;

  const AllMezmursScreen({
    Key? key,
    required this.onToggleTheme,
    required this.setLastActivity,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _AllMezmursScreenState createState() => _AllMezmursScreenState();
}

class _AllMezmursScreenState extends State<AllMezmursScreen> {
  final List<dynamic> _displayList = [];
  final List<int> _sortedCategoryIds = [];
  final PageController _categoryPageController = PageController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int _currentCategoryPageIndex = 0;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _buildDisplayList();
    _itemPositionsListener.itemPositions.addListener(_onListScrolled);
  }

  @override
  void dispose() {
    _categoryPageController.dispose();
    super.dispose();
  }

  void _buildDisplayList() {
    _sortedCategoryIds.addAll(hymnsDatabase.keys.toSet().toList()..sort());
    
    for (int categoryId in _sortedCategoryIds) {
      final hymns = hymnsDatabase[categoryId] ?? {};
      if (hymns.isNotEmpty) {
        _displayList.add({'isHeader': true, 'categoryId': categoryId});
        hymns.forEach((itemId, content) {
          final title = content.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'Hymn $itemId');
          _displayList.add({'categoryId': categoryId, 'itemId': itemId, 'title': title, 'content': content});
        });
      }
    }
  }

  void _onListScrolled() {
    if (_isProgrammaticScroll) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisibleItemIndex = positions.where((p) => p.itemLeadingEdge < 1).reduce((v, e) => v.itemLeadingEdge < e.itemLeadingEdge ? v : e).index;
    final itemData = _displayList[firstVisibleItemIndex];
    final currentCategoryId = itemData['categoryId'];
    final newPageIndex = _sortedCategoryIds.indexOf(currentCategoryId);

    if (newPageIndex != -1 && newPageIndex != _currentCategoryPageIndex) {
      if (mounted) setState(() => _currentCategoryPageIndex = newPageIndex);
      _isProgrammaticScroll = true;
      _categoryPageController.animateToPage(newPageIndex, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut)
          .whenComplete(() => _isProgrammaticScroll = false);
    }
  }

  void _onPageChanged(int pageIndex) {
    if (_isProgrammaticScroll) return;
    setState(() => _currentCategoryPageIndex = pageIndex);
    final targetCategoryId = _sortedCategoryIds[pageIndex];
    final targetListIndex = _displayList.indexWhere((item) => item is Map && item['isHeader'] == true && item['categoryId'] == targetCategoryId);
    if (targetListIndex != -1) {
      _isProgrammaticScroll = true;
      _itemScrollController.scrollTo(index: targetListIndex, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut)
          .whenComplete(() => _isProgrammaticScroll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategorySelector(),
        Expanded(child: _buildScrollableList()),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    if (_sortedCategoryIds.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180,
      color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : theme.cardColor.withOpacity(0.3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _categoryPageController,
            itemCount: _sortedCategoryIds.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final categoryId = _sortedCategoryIds[index];
              return _buildCategoryPageItem(
                title: getCategoryTitle(categoryId),
                imagePath: _categoryImagePaths[categoryId] ?? 'assets/images/logo.jpeg',
              );
            },
          ),
          _buildArrowIndicator(isLeft: true),
          _buildArrowIndicator(isLeft: false),
          Positioned(
            bottom: 10,
            child: SmoothPageIndicator(
              controller: _categoryPageController,
              count: _sortedCategoryIds.length,
              effect: WormEffect(
                dotHeight: 8, dotWidth: 8,
                activeDotColor: accentColor,
                dotColor: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryPageItem({required String title, required String imagePath}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey)),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(color: Colors.black.withOpacity(0.1))),
            Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Text(
                title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArrowIndicator({required bool isLeft}) {
    bool isVisible = isLeft ? _currentCategoryPageIndex > 0 : _currentCategoryPageIndex < _sortedCategoryIds.length - 1;
    return Positioned(
      left: isLeft ? 0 : null, right: isLeft ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: IconButton(
            icon: Icon(isLeft ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), shadows: const [Shadow(color: Colors.black54, blurRadius: 4)]),
            onPressed: () {
              if (isLeft) {
                _categoryPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else {
                _categoryPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableList() {
    if (_displayList.isEmpty) {
      return const Center(child: Text("No hymns available."));
    }
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _displayList.length,
      itemBuilder: (context, index) {
        final item = _displayList[index];
        if (item is Map && item['isHeader'] == true) {
          return _buildCategoryHeader(getCategoryTitle(item['categoryId']));
        } else {
          return _buildAnimatedListItem(
            item: item,
            onTap: () {
              widget.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => DetailPage(
                title: item['title'] as String, id: item['categoryId'] as int, itemId: item['itemId'] as int,
                onToggleTheme: widget.onToggleTheme, setLastActivity: widget.setLastActivity, navigatorKey: widget.navigatorKey,
              )));
              widget.setLastActivity(item['categoryId'] as int, itemId: item['itemId'] as int);
            },
          );
        }
      },
    );
  }
  
  Widget _buildCategoryHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildAnimatedListItem({
    required Map<String, dynamic> item, required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final accentColor = theme.colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: theme.brightness == Brightness.dark ? null : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.15),
                  child: Text('${item['itemId']}', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Category: ${getCategoryTitle(item['categoryId'])}', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  final Map<int, String> _categoryImagePaths = {
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
}