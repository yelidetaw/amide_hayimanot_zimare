// lib/list_screen.dart

import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/mezmur_poem.dart';
import 'package:amidehayimanot_zimare/detail_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:amidehayimanot_zimare/category_data.dart';

class ListScreen extends StatefulWidget {
  final int categoryId;
  final int? itemId;
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final GlobalKey<NavigatorState> navigatorKey;

  const ListScreen(
    this.categoryId, {
    this.itemId,
    required this.onToggleTheme,
    required this.setLastActivity,
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  late final PageController _pageController;
  int _currentPageIndex = 0;
  bool _isSwipeable = false;

  @override
  void initState() {
    super.initState();
    _isSwipeable = topLevelCategories.contains(widget.categoryId);

    if (_isSwipeable) {
      _currentPageIndex = topLevelCategories.indexOf(widget.categoryId);
      _pageController = PageController(initialPage: _currentPageIndex);
    }

    if (widget.itemId != null) {
      _navigateToDetailDirectly();
    }
  }

  void _navigateToDetailDirectly() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hymns = hymnsDatabase[widget.categoryId] ?? {};
      final itemIdToNavigate = widget.itemId!;

      if (hymns.containsKey(itemIdToNavigate)) {
        final content = hymns[itemIdToNavigate]!;
        final title = content.split('\n').firstWhere(
              (line) => line.trim().isNotEmpty,
              orElse: () => 'Hymn $itemIdToNavigate',
            );

        widget.navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: title,
              id: widget.categoryId,
              itemId: itemIdToNavigate,
              onToggleTheme: widget.onToggleTheme,
              setLastActivity: widget.setLastActivity,
              navigatorKey: widget.navigatorKey,
            ),
          ),
        );
      } else {
        print(
          "Error: itemId $itemIdToNavigate not found in category ${widget.categoryId}",
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_isSwipeable) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = [];
      if (query.isNotEmpty) {
        hymnsDatabase.forEach((categoryId, hymns) {
          hymns.forEach((itemId, content) {
            final title = content
                .split('\n')
                .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
            if (title.toLowerCase().contains(query.toLowerCase()) ||
                content.toLowerCase().contains(query.toLowerCase())) {
              _searchResults.add({
                'categoryId': categoryId,
                'itemId': itemId,
                'title': title,
              });
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);
    final Color appBarColor1 = isDarkMode
        ? const Color.fromARGB(255, 45, 25, 70)
        : const Color(0xFF6A1B9A);
    final Color appBarColor2 = isDarkMode
        ? const Color.fromARGB(255, 56, 30, 88)
        : const Color(0xFF8E24AA);
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    final int currentCategoryId = _isSwipeable
        ? topLevelCategories[_currentPageIndex]
        : widget.categoryId;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(
          context, accentColor, appBarColor1, appBarColor2, currentCategoryId),
      body: _isSearching
          ? _buildSearchResults()
          : _isSwipeable
              ? _buildPageView()
              : _buildPageForCategory(widget.categoryId),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: topLevelCategories.length,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
          widget.setLastActivity(topLevelCategories[index]);
        });
      },
      itemBuilder: (context, index) {
        final categoryId = topLevelCategories[index];
        return _buildPageForCategory(categoryId);
      },
    );
  }

  Widget _buildPageForCategory(int categoryId) {
    if (subCategoryMap.containsKey(categoryId)) {
      return _buildSubCategoryList(subCategoryMap[categoryId]!);
    }
    return _buildHymnList(categoryId);
  }

  AppBar _buildAppBar(
    BuildContext context,
    Color accentColor,
    Color color1,
    Color color2,
    int categoryIdForTitle,
  ) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search hymns...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: _onSearchChanged,
            )
          : Text(
              getCategoryTitle(categoryIdForTitle),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchController.clear();
                _searchResults = [];
                FocusScope.of(context).unfocus();
              } else {
                _isSearching = true;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedListItem({
    required BuildContext context,
    required int index,
    required int itemId,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final double titleFontSize = (screenSize.width * 0.045).clamp(16, 20);
    final double subtitleFontSize = (screenSize.width * 0.035).clamp(12, 16);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);
    final primaryTextColor =
        isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87;
    final secondaryTextColor =
        isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54;

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.width * 0.02,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: accentColor.withOpacity(0.15),
                          child: Text(
                            '$itemId',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                  color: primaryTextColor,
                                ),
                              ),
                              if (subtitle != null && subtitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: secondaryTextColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildHymnList(int categoryId) {
    final hymns = hymnsDatabase[categoryId] ?? {};

    if (hymns.isEmpty) {
      return const Center(child: Text("No hymns available in this category."));
    }

    return _buildList(
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final itemId = hymns.keys.elementAt(index);
        final content = hymns[itemId]!;
        final title = content.split('\n').firstWhere(
              (line) => line.trim().isNotEmpty,
              orElse: () => 'Hymn $itemId',
            );
        final subtitle = content.split('\n').length > 1 &&
                content.split('\n')[1].trim().isNotEmpty
            ? content.split('\n')[1]
            : 'Tap to read more...';

        return _buildAnimatedListItem(
          context: context,
          index: index,
          itemId: itemId,
          title: title,
          subtitle: subtitle,
          onTap: () {
            widget.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  title: title,
                  id: categoryId,
                  itemId: itemId,
                  onToggleTheme: widget.onToggleTheme,
                  setLastActivity: widget.setLastActivity,
                  navigatorKey: widget.navigatorKey,
                ),
              ),
            );
            widget.setLastActivity(categoryId, itemId: itemId);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Search for a hymn by title or content.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hymns found for "${_searchController.text}"',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _buildList(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final categoryId = result['categoryId'] as int;
        final itemId = result['itemId'] as int;
        final title = result['title'] as String;

        return _buildAnimatedListItem(
          context: context,
          index: index,
          itemId: itemId,
          title: title,
          subtitle: 'Category: ${getCategoryTitle(categoryId)}',
          onTap: () {
            widget.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  title: title,
                  id: categoryId,
                  itemId: itemId,
                  onToggleTheme: widget.onToggleTheme,
                  setLastActivity: widget.setLastActivity,
                  navigatorKey: widget.navigatorKey,
                ),
              ),
            );
            widget.setLastActivity(categoryId, itemId: itemId);
          },
        );
      },
    );
  }

  Widget _buildSubCategoryList(List<int> subCategoryIds) {
    return _buildList(
      itemCount: subCategoryIds.length,
      itemBuilder: (context, index) {
        final subCategoryId = subCategoryIds[index];
        return _buildAnimatedListItem(
          context: context,
          index: index,
          itemId: subCategoryId,
          title: getCategoryTitle(subCategoryId),
          subtitle: 'Tap to view hymns',
          onTap: () {
            widget.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ListScreen(
                  subCategoryId,
                  onToggleTheme: widget.onToggleTheme,
                  setLastActivity: widget.setLastActivity,
                  navigatorKey: widget.navigatorKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
