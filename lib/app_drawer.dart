// lib/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:amidehayimanot_zimare/list.dart';
import 'package:amidehayimanot_zimare/category_data.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final Function(int, {int? itemId}) setLastActivity;
  final GlobalKey<NavigatorState> navigatorKey;
  final int? lastActivityCategoryId;

  const AppDrawer({
    Key? key,
    required this.onToggleTheme,
    required this.setLastActivity,
    required this.navigatorKey,
    this.lastActivityCategoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Drawer(
      child: Theme(
        data: theme.copyWith(canvasColor: theme.scaffoldBackgroundColor),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDrawerHeader(context),
              Expanded(
                child: _buildCategoryList(context),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
      width: screenSize.width * 0.8,
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isBrandedTheme = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBrandedTheme
              ? [theme.colorScheme.primary, theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary]
              : [theme.cardColor, theme.appBarTheme.backgroundColor ?? theme.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: theme.colorScheme.secondary, width: 2.5),
            ),
            child: CircleAvatar(
              radius: screenSize.width * 0.09,
              backgroundColor: Colors.transparent,
              backgroundImage: const AssetImage('assets/images/logo.jpeg'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'ዓምደ ሃይማኖት',
            style: TextStyle(
              color: isBrandedTheme ? Colors.white : theme.colorScheme.secondary,
              fontSize: screenSize.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ሰንበት ትምህርት ቤት',
            style: TextStyle(
              color: isBrandedTheme ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.7),
              fontSize: screenSize.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final accentColor = theme.colorScheme.secondary;

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: topLevelCategories.length,
      itemBuilder: (context, index) {
        final categoryId = topLevelCategories[index];
        final categoryName = getCategoryTitle(categoryId);
        final isActive = lastActivityCategoryId == categoryId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.church_rounded, size: screenSize.width * 0.055),
            title: Text(
              categoryName,
              style: TextStyle(fontSize: screenSize.width * 0.042, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            ),
            selected: isActive,
            selectedTileColor: accentColor.withOpacity(0.15),
            selectedColor: accentColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              setLastActivity(categoryId);
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ListScreen(
                  categoryId, onToggleTheme: onToggleTheme, setLastActivity: setLastActivity, navigatorKey: navigatorKey,
                )));
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isBrandedTheme = theme.brightness == Brightness.light;
    final accentColor = theme.colorScheme.secondary;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(
                isBrandedTheme ? Icons.mode_night_rounded : Icons.wb_sunny_rounded,
                color: accentColor,
                size: screenSize.width * 0.06,
              ),
              title: Text(
                isBrandedTheme ? 'light Mode' : 'Dark Mode',
                style: TextStyle(fontSize: screenSize.width * 0.042),
              ),
              trailing: Switch(
                value: !isBrandedTheme, // Switch is "on" for dark mode
                onChanged: (value) => onToggleTheme(),
                activeColor: accentColor,
                activeTrackColor: accentColor.withOpacity(0.3),
              ),
              onTap: onToggleTheme,
            ),
          ),
        ],
      ),
    );
  }
}