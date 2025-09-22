// lib/aboutus.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class _Constants {
  static const String bibleVerse = '"ለሰው ሳይሆን ለጌታ እንደምታደርጉ የምታደርጉትን ሁሉ ከልብ አድርጉት !!!"';
  static const String bibleReference = 'የሐዋርያው የቅዱስ ጳዉሎስ መልእክት ወደ ቆላስይስ ሰዎች 3:23';
  static const String acknowledgements =
      'ከሁሉ አስቀድሞ ዓለሙን ሁሉ ለያዘ ለአብ ዓለምን ላዳነ ለወልድ ላፀናን እና ለሚያነፃን ለመንፈስ ቅዱስ ከእረኛው ጓዳ ከንጉሱ መንበር ምስጋናን የምትቀበል፤ ከባርነት ቀንበር ከባዕድ ሀገር ግፍ ከመቶ ዓመታት ስቃይ ባህር ከፍለህ ከአለት አፍልቀህ ከሰማይ አዝንበህ ባሻገርክ ጊዜ ንሴብሆ ከማለት በስተቀር ቃላት ላጡልህ ላንተ ለዝምታቸው ትርጉም፤ ኢትዮጵያዊው አባት የሚያሳርፍ ምስጋና ምግብ የሚሆን ዝማሬን ቅዱስ ዳዊት እንዳለ የመላዕክት እንጀራ ለእኛ ለሰዎች ልንመገብ ሊቁ ቅዱስ ያሬድ እንዳቀረበልን ምንም እንኳ ከአባቶቻችን ምግባር ከግብራቸው የራቅን ደካሞች ብንሆን ለረዳኸን፤ በአባቶቻችን ወዝ ዘመኑን በዋጀ መልኩ ምስጋናን ለትውልድ እናቀርብ ዘንድ ለፈቀድክልን ላንተ ለልዑል እግዚአብሔር ልቦናችን ምሥጋናን ታፈልቃለች !\n\n'
      'የአበው ብዕር ጌጥ፤ ሥሮችሽ በምድር ጫፎችሽ በሰማይ ደርሰው በምልጃሽ የተጠለልንብሽ ታላቅ የወይን ቅርንጫፍ ፍሬሽን የመገብሽን መሶበ ወርቃችን፤ በሥላሴ መንበር የሚፈሰውን የምስጋና ዜማ በማህፀንሽ ያደመጥሽ፤ የዝማሬያችን ቋንቋ፤ የእናት ሰንበት ትምህርት ቤታችን ሞገስ፤ እናቱ እናታችን ቅድስት ድንግል ማርያም እንደ ቅድስት ኤልሳቤጥ የጌታችን እናት እያልን እናመሠግንሻለን !\n\n'
      'ለዚህ ስራ እውን መሆን የድርሻችሁን ለተወጣችሁ እና ላበረታታችሁን የሰንበት ትምህርት ቤታችን ስራ አስፈፃሚዎች እንዲሁም የሰንበት ትምህርት ቤታችን መዝሙር ክፍል ተጠሪ እና ንዑሳን በሙሉ እግዚአብሔር የሰማዩን ዋጋ ያድላቹ !\n\n'
      'ለዚህ ስራ እውን መሆን በጽሑፍ የተራዳችሁ:';
  static const List<List<String>> contributors = [
    ['• ለአቤል መብራቱ', '• ለፋሲካ ገበየሁ'], ['• ለሳሮን ቴሜሳ', '• ለአይዳ ያቦነህ'],
    ['• ለበረከት ታደሰ', '• ለእዮብ ዘውዱ'], ['• ለልደት ዳዊት', '• ለኑሐሚን ወንድወሰን'],
    ['• ለእንየው ወንድማገኝ', '• ለመምህር ምናልባት ደስታ'], ['• ለዮዲት አማኑኤል', '• ለሜላት አምሳሉ'],
  ];
  static const String closingAcknowledgement =
      'እንዲሁም በዚህ ስራ ላይ በግልፅም ሆነ በህቡዕ ለተሳተፋችሁ ሁሉ ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት ምስጋናዋን ታቀርባለች!\n'
      'እግዚአብሔር አምላክ አገልግሎታችሁን ይባርክላቹህ!';
  static const String specialThanks =
      '° ለዲ/ን ዳዊት ተመስገን(ዘልደታ) : በጅማ ዩኒቨርስቲ (JIT) የኮምፒውተር ሳይንስ ተማሪ, ይህን አኘልኬሽን በመስራት ከፍፃሜ እንዲደርስ ላበረከትከው የላቀ አስተዋፅኦ እግዚአብሔር የሰማዩን ዋጋ ያድልህ ! ላደረከዉ አስተዋጽኦ እናት ሰንበት ት/ቤትህ ምስጋናዋን ታቀርባለች \n\n'
      '° ለእንየው ወንድማገኝ : ለሳሮን ቴሜሳ : ያለመታከት በመታዘዝ ፍፁም በሆነ ክርስቲያናዊ ፍቅር ስለተራዳችሁ እግዚአብሔር የሰማዩን ዋጋ ያድላችሁ!\n\n'
      '° እንዲሁም ለእዮብ ዘውዱ እና ለቢኒያም መኮንን ፍፁም በሆነ ወንድማዊ ፍቅር ለሰጣችሁት የሚያቀኑ እና የሚያበረታቱ ሃሳቦቻችሁ እግዚአብሔር የሰማዩን ዋጋ ያድላችሁ!';
  static const String developerInfo = 'Developed by: ዲ/ን ዳዊት ተመስገን(ዘአትናጎ ልደታ)';
  static const String appVersion = 'Version: 1.0.0';
  static const String copyrightNotice = 'ጅማ ዓምደ ሃይማኖት ሰንበት ትምህርት ቤት. All Rights Reserved.';
  static const String instagramUrl = 'https://instagram.com/@amedehayemanot';
  static const String facebookUrl = 'https://www.facebook.com/amdehymanot';
  static const String telegramUrl = 'https://t.me/amdehaymanotmedia';
  static const String youtubeUrl = 'https://www.youtube.com/@JimmaAmdehaymanot';
  static const String tiktokUrl = 'https://www.tiktok.com/@jimaamdehaymanotsunday?_t=ZM-8xGyYrCWeOe&_r=1';
}

class AboutUsBody extends StatelessWidget {
  const AboutUsBody({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open the link. Please try again later.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This screen's background is determined by the global scaffoldBackgroundColor
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          const _BibleVerseCard(),
          const SizedBox(height: 30),
          _SocialMediaSection(onLaunch: (url) => _launchUrl(context, url)),
          const SizedBox(height: 30),
          _AcknowledgementsCard(),
          const SizedBox(height: 20),
          const _SpecialThanksCard(),
          const SizedBox(height: 20),
          const _AppInfoFooter(),
        ],
      ),
    );
  }
}

class _BibleVerseCard extends StatelessWidget {
  const _BibleVerseCard();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accentColor = theme.colorScheme.secondary;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      // The card color is now correctly inherited from the global theme
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.format_quote, color: accentColor, size: 30),
            const SizedBox(height: 12),
            Text(
              _Constants.bibleVerse,
              textAlign: TextAlign.center,
              // Text color is correctly inherited from the theme's textTheme
              style: textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 12),
            Text(
              _Constants.bibleReference,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialMediaSection extends StatelessWidget {
  const _SocialMediaSection({required this.onLaunch});
  final ValueChanged<String> onLaunch;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'እኛን ለማግኘት  ',
          // Use onBackground color for text on the main scaffold
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onBackground),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(icon: FontAwesomeIcons.instagram, color: const Color(0xFFE4405F), url: _Constants.instagramUrl, onPressed: onLaunch),
              const SizedBox(width: 12),
              _SocialButton(icon: FontAwesomeIcons.facebook, color: const Color(0xFF1877F2), url: _Constants.facebookUrl, onPressed: onLaunch),
              const SizedBox(width: 12),
              _SocialButton(icon: FontAwesomeIcons.telegram, color: const Color(0xFF26A5E4), url: _Constants.telegramUrl, onPressed: onLaunch),
              const SizedBox(width: 12),
              _SocialButton(icon: FontAwesomeIcons.youtube, color: const Color(0xFFFF0000), url: _Constants.youtubeUrl, onPressed: onLaunch),
              const SizedBox(width: 12),
              _SocialButton(
                icon: FontAwesomeIcons.tiktok,
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                url: _Constants.tiktokUrl, onPressed: onLaunch,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.color, required this.url, required this.onPressed});
  final IconData icon; final Color color; final String url; final ValueChanged<String> onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(icon), iconSize: 32, color: color,
      onPressed: () => onPressed(url), splashRadius: 28, tooltip: 'Visit our social media',
    );
  }
}

class _AcknowledgementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, color: theme.colorScheme.secondary),
                const SizedBox(width: 10),
                Text('ምስጋና', style: textTheme.titleLarge),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Text(_Constants.acknowledgements, style: textTheme.bodyMedium?.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Column(
                  children: _Constants.contributors.map((pair) {
                    return Row(
                      children: [
                        Expanded(child: Text(pair[0], style: textTheme.bodyMedium)),
                        if (isWide || pair.length > 1) ...[
                          const SizedBox(width: 16),
                          Expanded(child: pair.length > 1 ? Text(pair[1], style: textTheme.bodyMedium) : const SizedBox()),
                        ],
                      ],
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(_Constants.closingAcknowledgement, style: textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _SpecialThanksCard extends StatelessWidget {
  const _SpecialThanksCard();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accentColor = theme.colorScheme.secondary;
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: accentColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: accentColor),
                const SizedBox(width: 8),
                Text('ልዩ ምስጋና', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(Icons.star, color: accentColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(_Constants.specialThanks, textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _AppInfoFooter extends StatelessWidget {
  const _AppInfoFooter();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        '${_Constants.developerInfo}\n${_Constants.appVersion}\n\n© ${DateTime.now().year} ${_Constants.copyrightNotice}\n\nአምላከ ቅዱስ ያሬድ አይለየን!',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7), height: 1.5),
      ),
    );
  }
}