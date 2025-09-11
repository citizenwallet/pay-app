import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:pay_app/state/locale_state.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late LocaleState _localeState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _localeState = context.read<LocaleState>();
    });
  }

  Future<void> _changeLanguage(Locale locale) async {
    await _localeState.setLocale(locale);

    // Show a success dialog
    if (mounted) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
          content: Text(AppLocalizations.of(context)?.languageChangedSuccessfully ?? 'Language changed successfully!'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.ok ?? 'OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context)?.language ?? 'Language',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => GoRouter.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: Color(0xFF09090B),
            size: 20,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.selectLanguage ??
                    'Select Language',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageOption(
                      const Locale('en'),
                      'English',
                      'English',
                    ),
                    _buildLanguageOption(
                      const Locale('fr', 'BE'),
                      'Français (Belgique)',
                      'French (Belgium)',
                    ),
                    _buildLanguageOption(
                      const Locale('nl', 'BE'),
                      'Nederlands (België)',
                      'Dutch (Belgium)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      Locale locale, String nativeName, String englishName) {
    final currentLocale =
        context.select<LocaleState, Locale?>((state) => state.currentLocale);
    final isSelected = currentLocale?.languageCode == locale.languageCode &&
        currentLocale?.countryCode == locale.countryCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF007AFF)
            : CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => _changeLanguage(locale),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? CupertinoColors.white.withOpacity(0.8)
                          : CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.check_mark,
                color: CupertinoColors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
