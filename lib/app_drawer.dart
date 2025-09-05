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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final iconColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    final backgroundColor =
        isDarkMode ? const Color.fromARGB(255, 30, 15, 50) : Colors.white;
    final accentColor =
        isDarkMode ? const Color(0xFFF3BD46) : const Color(0xFF6A1B9A);

    void _navigateTo(Widget screen) {
      Navigator.of(context).pop();
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }

    return Drawer(
      backgroundColor: backgroundColor,
      width: screenSize.width * 0.75,
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.25,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: 0,
                    child: Image.asset(
                      'assets/images/am-8.jpg',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      color: Colors.black54,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: screenSize.width * 0.09,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/am-11.jpg',
                              fit: BoxFit.cover,
                              width: screenSize.width * 0.18,
                              height: screenSize.width * 0.18,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'የዝማሬ ማውጫ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.065,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 2, color: Colors.black)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: topLevelCategories.length,
              itemBuilder: (context, index) {
                final categoryId = topLevelCategories[index];
                final categoryName = getCategoryTitle(categoryId);
                final isActive = lastActivityCategoryId == categoryId;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.03,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? accentColor.withOpacity(0.2)
                            : accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.church_rounded,
                        color:
                            isActive ? accentColor : iconColor.withOpacity(0.8),
                        size: screenSize.width * 0.055,
                      ),
                    ),
                    title: Text(
                      categoryName,
                      style: TextStyle(
                        color: isActive ? accentColor : textColor,
                        fontSize: screenSize.width * 0.045,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setLastActivity(categoryId);
                      _navigateTo(
                        ListScreen(
                          categoryId,
                          onToggleTheme: onToggleTheme,
                          setLastActivity: setLastActivity,
                          navigatorKey: navigatorKey,
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                      color: accentColor,
                      size: screenSize.width * 0.06,
                    ),
                    SizedBox(width: screenSize.width * 0.03),
                    Text(
                      isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isDarkMode,
                    onChanged: (value) => onToggleTheme(),
                    activeColor: accentColor,
                    activeTrackColor: accentColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
