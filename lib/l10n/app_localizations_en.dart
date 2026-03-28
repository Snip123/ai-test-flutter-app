// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appBarTitleAssets => 'Assets';

  @override
  String get tooltipRefresh => 'Refresh';

  @override
  String get labelRegisterAsset => 'Register Asset';

  @override
  String get emptyStateAssets => 'No Assets registered yet.';

  @override
  String get errorLoadAssets => 'Failed to load Assets. Please try again.';

  @override
  String get errorLoadAsset => 'Failed to load Asset. Please try again.';

  @override
  String labelTraceId(String traceId) {
    return 'Trace ID: $traceId';
  }

  @override
  String get appBarTitleAssetDetail => 'Asset Detail';

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get dialogTitleDecommission => 'Decommission Asset';

  @override
  String dialogBodyDecommission(String assetName) {
    return 'Are you sure you want to decommission \"$assetName\"?';
  }

  @override
  String get labelReason => 'Reason';

  @override
  String get hintReason => 'e.g. End of service life';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDecommission => 'Decommission';

  @override
  String get labelName => 'Name';

  @override
  String get labelAssetType => 'Asset Type';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelFacility => 'Facility';

  @override
  String get labelLocation => 'Location';

  @override
  String get labelSerialNumber => 'Serial Number';

  @override
  String get buttonSetLocation => 'Set Location';

  @override
  String get buttonUpdateLocation => 'Update Location';

  @override
  String get appBarTitleRegisterAsset => 'Register Asset';

  @override
  String get hintAssetName => 'e.g. Rooftop HVAC-3';

  @override
  String get hintAssetType => 'e.g. HVAC';

  @override
  String get hintFacilityId => 'e.g. facility-001';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get validationAssetTypeRequired => 'Asset Type is required';

  @override
  String get validationFacilityRequired => 'Facility is required';

  @override
  String get appBarTitleEditAsset => 'Edit Asset';

  @override
  String get hintOptional => 'Optional';

  @override
  String get buttonSave => 'Save';

  @override
  String get appBarTitleSetLocation => 'Set Location';

  @override
  String get labelFacilityId => 'Facility ID';

  @override
  String get labelLocationId => 'Location ID';

  @override
  String get hintLocationId => 'e.g. roof-level-3';

  @override
  String get validationLocationRequired => 'Location is required';
}
