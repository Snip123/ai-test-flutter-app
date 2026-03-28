// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appBarTitleAssets => 'Actifs';

  @override
  String get tooltipRefresh => 'Actualiser';

  @override
  String get labelRegisterAsset => 'Enregistrer un actif';

  @override
  String get emptyStateAssets => 'Aucun actif enregistré pour l\'instant.';

  @override
  String get errorLoadAssets =>
      'Impossible de charger les actifs. Veuillez réessayer.';

  @override
  String get errorLoadAsset =>
      'Impossible de charger l\'actif. Veuillez réessayer.';

  @override
  String labelTraceId(String traceId) {
    return 'Trace ID : $traceId';
  }

  @override
  String get appBarTitleAssetDetail => 'Détail de l\'actif';

  @override
  String get tooltipEdit => 'Modifier';

  @override
  String get dialogTitleDecommission => 'Mettre l\'actif hors service';

  @override
  String dialogBodyDecommission(String assetName) {
    return 'Êtes-vous sûr de vouloir mettre « $assetName » hors service ?';
  }

  @override
  String get labelReason => 'Raison';

  @override
  String get hintReason => 'ex. Fin de vie utile';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonDecommission => 'Mettre hors service';

  @override
  String get labelName => 'Nom';

  @override
  String get labelAssetType => 'Type d\'actif';

  @override
  String get labelStatus => 'Statut';

  @override
  String get labelFacility => 'Installation';

  @override
  String get labelLocation => 'Emplacement';

  @override
  String get labelSerialNumber => 'Numéro de série';

  @override
  String get buttonSetLocation => 'Définir l\'emplacement';

  @override
  String get buttonUpdateLocation => 'Mettre à jour l\'emplacement';

  @override
  String get appBarTitleRegisterAsset => 'Enregistrer un actif';

  @override
  String get hintAssetName => 'ex. CVC en toiture-3';

  @override
  String get hintAssetType => 'ex. CVC';

  @override
  String get hintFacilityId => 'ex. installation-001';

  @override
  String get validationNameRequired => 'Le nom est requis';

  @override
  String get validationAssetTypeRequired => 'Le type d\'actif est requis';

  @override
  String get validationFacilityRequired => 'L\'installation est requise';

  @override
  String get appBarTitleEditAsset => 'Modifier l\'actif';

  @override
  String get hintOptional => 'Facultatif';

  @override
  String get buttonSave => 'Enregistrer';

  @override
  String get appBarTitleSetLocation => 'Définir l\'emplacement';

  @override
  String get labelFacilityId => 'ID d\'installation';

  @override
  String get labelLocationId => 'ID d\'emplacement';

  @override
  String get hintLocationId => 'ex. niveau-toit-3';

  @override
  String get validationLocationRequired => 'L\'emplacement est requis';
}
