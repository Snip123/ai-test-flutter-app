// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appBarTitleAssets => 'Anlagen';

  @override
  String get tooltipRefresh => 'Aktualisieren';

  @override
  String get labelRegisterAsset => 'Anlage registrieren';

  @override
  String get emptyStateAssets => 'Noch keine Anlagen registriert.';

  @override
  String get errorLoadAssets =>
      'Anlagen konnten nicht geladen werden. Bitte erneut versuchen.';

  @override
  String get errorLoadAsset =>
      'Anlage konnte nicht geladen werden. Bitte erneut versuchen.';

  @override
  String labelTraceId(String traceId) {
    return 'Trace-ID: $traceId';
  }

  @override
  String get appBarTitleAssetDetail => 'Anlagendetails';

  @override
  String get tooltipEdit => 'Bearbeiten';

  @override
  String get dialogTitleDecommission => 'Anlage stilllegen';

  @override
  String dialogBodyDecommission(String assetName) {
    return 'Möchten Sie „$assetName“ wirklich stilllegen?';
  }

  @override
  String get labelReason => 'Grund';

  @override
  String get hintReason => 'z.B. Ende der Nutzungsdauer';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonDecommission => 'Stilllegen';

  @override
  String get labelName => 'Name';

  @override
  String get labelAssetType => 'Anlagentyp';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelFacility => 'Einrichtung';

  @override
  String get labelLocation => 'Standort';

  @override
  String get labelSerialNumber => 'Seriennummer';

  @override
  String get buttonSetLocation => 'Standort festlegen';

  @override
  String get buttonUpdateLocation => 'Standort aktualisieren';

  @override
  String get appBarTitleRegisterAsset => 'Anlage registrieren';

  @override
  String get hintAssetName => 'z.B. Dach-HLK-3';

  @override
  String get hintAssetType => 'z.B. HLK';

  @override
  String get hintFacilityId => 'z.B. einrichtung-001';

  @override
  String get validationNameRequired => 'Name ist erforderlich';

  @override
  String get validationAssetTypeRequired => 'Anlagentyp ist erforderlich';

  @override
  String get validationFacilityRequired => 'Einrichtung ist erforderlich';

  @override
  String get appBarTitleEditAsset => 'Anlage bearbeiten';

  @override
  String get hintOptional => 'Optional';

  @override
  String get buttonSave => 'Speichern';

  @override
  String get appBarTitleSetLocation => 'Standort festlegen';

  @override
  String get labelFacilityId => 'Einrichtungs-ID';

  @override
  String get labelLocationId => 'Standort-ID';

  @override
  String get hintLocationId => 'z.B. dachebene-3';

  @override
  String get validationLocationRequired => 'Standort ist erforderlich';
}
