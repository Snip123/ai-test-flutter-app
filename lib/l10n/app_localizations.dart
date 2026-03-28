import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appBarTitleAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get appBarTitleAssets;

  /// No description provided for @tooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get tooltipRefresh;

  /// No description provided for @labelRegisterAsset.
  ///
  /// In en, this message translates to:
  /// **'Register Asset'**
  String get labelRegisterAsset;

  /// No description provided for @emptyStateAssets.
  ///
  /// In en, this message translates to:
  /// **'No Assets registered yet.'**
  String get emptyStateAssets;

  /// No description provided for @errorLoadAssets.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Assets. Please try again.'**
  String get errorLoadAssets;

  /// No description provided for @errorLoadAsset.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Asset. Please try again.'**
  String get errorLoadAsset;

  /// No description provided for @labelTraceId.
  ///
  /// In en, this message translates to:
  /// **'Trace ID: {traceId}'**
  String labelTraceId(String traceId);

  /// No description provided for @appBarTitleAssetDetail.
  ///
  /// In en, this message translates to:
  /// **'Asset Detail'**
  String get appBarTitleAssetDetail;

  /// No description provided for @tooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// No description provided for @dialogTitleDecommission.
  ///
  /// In en, this message translates to:
  /// **'Decommission Asset'**
  String get dialogTitleDecommission;

  /// No description provided for @dialogBodyDecommission.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decommission \"{assetName}\"?'**
  String dialogBodyDecommission(String assetName);

  /// No description provided for @labelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get labelReason;

  /// No description provided for @hintReason.
  ///
  /// In en, this message translates to:
  /// **'e.g. End of service life'**
  String get hintReason;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDecommission.
  ///
  /// In en, this message translates to:
  /// **'Decommission'**
  String get buttonDecommission;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelAssetType.
  ///
  /// In en, this message translates to:
  /// **'Asset Type'**
  String get labelAssetType;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelFacility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get labelFacility;

  /// No description provided for @labelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get labelLocation;

  /// No description provided for @labelSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get labelSerialNumber;

  /// No description provided for @buttonSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get buttonSetLocation;

  /// No description provided for @buttonUpdateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get buttonUpdateLocation;

  /// No description provided for @appBarTitleRegisterAsset.
  ///
  /// In en, this message translates to:
  /// **'Register Asset'**
  String get appBarTitleRegisterAsset;

  /// No description provided for @hintAssetName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rooftop HVAC-3'**
  String get hintAssetName;

  /// No description provided for @hintAssetType.
  ///
  /// In en, this message translates to:
  /// **'e.g. HVAC'**
  String get hintAssetType;

  /// No description provided for @hintFacilityId.
  ///
  /// In en, this message translates to:
  /// **'e.g. facility-001'**
  String get hintFacilityId;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @validationAssetTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Asset Type is required'**
  String get validationAssetTypeRequired;

  /// No description provided for @validationFacilityRequired.
  ///
  /// In en, this message translates to:
  /// **'Facility is required'**
  String get validationFacilityRequired;

  /// No description provided for @appBarTitleEditAsset.
  ///
  /// In en, this message translates to:
  /// **'Edit Asset'**
  String get appBarTitleEditAsset;

  /// No description provided for @hintOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get hintOptional;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @appBarTitleSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get appBarTitleSetLocation;

  /// No description provided for @labelFacilityId.
  ///
  /// In en, this message translates to:
  /// **'Facility ID'**
  String get labelFacilityId;

  /// No description provided for @labelLocationId.
  ///
  /// In en, this message translates to:
  /// **'Location ID'**
  String get labelLocationId;

  /// No description provided for @hintLocationId.
  ///
  /// In en, this message translates to:
  /// **'e.g. roof-level-3'**
  String get hintLocationId;

  /// No description provided for @validationLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get validationLocationRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
