// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appBarTitleAssets => 'الأصول';

  @override
  String get tooltipRefresh => 'تحديث';

  @override
  String get labelRegisterAsset => 'تسجيل أصل';

  @override
  String get emptyStateAssets => 'لا توجد أصول مسجلة حتى الآن.';

  @override
  String get errorLoadAssets => 'فشل تحميل الأصول. يرجى المحاولة مرة أخرى.';

  @override
  String get errorLoadAsset => 'فشل تحميل الأصل. يرجى المحاولة مرة أخرى.';

  @override
  String labelTraceId(String traceId) {
    return 'معرّف التتبع: $traceId';
  }

  @override
  String get appBarTitleAssetDetail => 'تفاصيل الأصل';

  @override
  String get tooltipEdit => 'تعديل';

  @override
  String get dialogTitleDecommission => 'إيقاف تشغيل الأصل';

  @override
  String dialogBodyDecommission(String assetName) {
    return 'هل أنت متأكد من رغبتك في إيقاف تشغيل \"$assetName\"؟';
  }

  @override
  String get labelReason => 'السبب';

  @override
  String get hintReason => 'مثال: انتهاء العمر التشغيلي';

  @override
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonDecommission => 'إيقاف التشغيل';

  @override
  String get labelName => 'الاسم';

  @override
  String get labelAssetType => 'نوع الأصل';

  @override
  String get labelStatus => 'الحالة';

  @override
  String get labelFacility => 'المنشأة';

  @override
  String get labelLocation => 'الموقع';

  @override
  String get labelSerialNumber => 'الرقم التسلسلي';

  @override
  String get buttonSetLocation => 'تحديد الموقع';

  @override
  String get buttonUpdateLocation => 'تحديث الموقع';

  @override
  String get appBarTitleRegisterAsset => 'تسجيل أصل';

  @override
  String get hintAssetName => 'مثال: تكييف السطح-3';

  @override
  String get hintAssetType => 'مثال: تكييف';

  @override
  String get hintFacilityId => 'مثال: منشأة-001';

  @override
  String get validationNameRequired => 'الاسم مطلوب';

  @override
  String get validationAssetTypeRequired => 'نوع الأصل مطلوب';

  @override
  String get validationFacilityRequired => 'المنشأة مطلوبة';

  @override
  String get appBarTitleEditAsset => 'تعديل الأصل';

  @override
  String get hintOptional => 'اختياري';

  @override
  String get buttonSave => 'حفظ';

  @override
  String get appBarTitleSetLocation => 'تحديد الموقع';

  @override
  String get labelFacilityId => 'معرّف المنشأة';

  @override
  String get labelLocationId => 'معرّف الموقع';

  @override
  String get hintLocationId => 'مثال: مستوى-السطح-3';

  @override
  String get validationLocationRequired => 'الموقع مطلوب';
}
