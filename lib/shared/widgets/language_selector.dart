// Language selector — popup menu placed in the app bar actions.
// Persists the selected locale via LocaleNotifier → SharedPreferences.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../locale/locale_provider.dart';

/// Supported locales with their display names (always shown in the native script).
const _kLocales = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('fr'), label: 'Français'),
  (locale: Locale('de'), label: 'Deutsch'),
  (locale: Locale('ar'), label: 'العربية'),
];

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return PopupMenuButton<Locale>(
      key: const Key('languageSelector'),
      tooltip: 'Select language',
      icon: const Icon(Icons.language),
      onSelected: (locale) =>
          ref.read(localeProvider.notifier).setLocale(locale),
      itemBuilder: (_) => [
        for (final entry in _kLocales)
          PopupMenuItem<Locale>(
            value: entry.locale,
            child: Row(
              children: [
                if (currentLocale.languageCode == entry.locale.languageCode)
                  const Icon(Icons.check, size: 16)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(entry.label),
              ],
            ),
          ),
      ],
    );
  }
}
