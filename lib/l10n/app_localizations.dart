import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// Minimal manual localization scaffold (normally use flutter gen-l10n).
// Provides only English, extend by adding more ARB files and wiring lookups.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Trip Wizards',
      'settingsTitle': 'Settings',
      'settingsAccount': 'Account',
      'settingsAccountInfo': 'Account Information',
      'settingsLegal': 'Legal',
      'settingsTerms': 'Terms of Service',
      'settingsPrivacy': 'Privacy Policy',
      'settingsAppLicense': 'App License',
      'homeTrips': 'My Trips',
      'homeEmptyTitle': 'No trips yet',
      'homeEmptySubtitle': 'Start planning your next adventure!',
      'homeCreateFirstTrip': 'Create Your First Trip',
      'newTrip': 'New Trip',
      'licenseTitle': 'License',
      'creditsTitle': 'AI Credits',
      'creditsLow': 'Low credits! Consider upgrading your plan.',
    },
  };

  String _t(String key) => _localizedValues[locale.languageCode]?[key] ?? key;

  String get appTitle => _t('appTitle');
  String get settingsTitle => _t('settingsTitle');
  String get settingsAccount => _t('settingsAccount');
  String get settingsAccountInfo => _t('settingsAccountInfo');
  String get settingsLegal => _t('settingsLegal');
  String get settingsTerms => _t('settingsTerms');
  String get settingsPrivacy => _t('settingsPrivacy');
  String get settingsAppLicense => _t('settingsAppLicense');
  String get homeTrips => _t('homeTrips');
  String get homeEmptyTitle => _t('homeEmptyTitle');
  String get homeEmptySubtitle => _t('homeEmptySubtitle');
  String get homeCreateFirstTrip => _t('homeCreateFirstTrip');
  String get newTrip => _t('newTrip');
  String get licenseTitle => _t('licenseTitle');
  String get creditsTitle => _t('creditsTitle');
  String get creditsLow => _t('creditsLow');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
