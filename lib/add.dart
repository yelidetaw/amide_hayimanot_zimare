import 'package:flutter/material.dart';

class Add extends StatelessWidget {
  const Add({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor =
        isDarkMode ? const Color(0xFFF3BD46) : Theme.of(context).primaryColor;
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor =
        isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction_rounded,
                    size: 80,
                    color: accentColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'በቅርብ ቀን ይጠብቁን',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ዝማሬን ለማከል እንዲያስችል እየሰራንበት እንገኛለን ",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
