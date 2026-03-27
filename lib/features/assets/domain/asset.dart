// Asset domain model — Assets bounded context (ADR-0003, ADR-0004)
// Fields mirror the OpenAPI schema at ai-test-assets-service/docs/api/openapi.yaml.
// The [display] map carries Tenant Values resolved server-side (ADR-0004).
// NEVER render [assetType] or [status] directly — always use displayAssetType / displayStatus.

class Asset {
  final String id;
  final String tenantId;
  final String name;

  /// Canonical Asset Type — for logic only, never shown in UI (ADR-0004).
  final String assetType;

  final String facilityId;
  final String? locationId;
  final String? serialNumber;
  final String status;

  /// Server-resolved Tenant Values for display (ADR-0004).
  final AssetDisplay? display;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const Asset({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.assetType,
    required this.facilityId,
    this.locationId,
    this.serialNumber,
    required this.status,
    this.display,
    required this.createdAt,
    this.updatedAt,
  });

  /// The Tenant Value for Asset Type — falls back to canonical if unmapped.
  String get displayAssetType => display?.assetType ?? assetType;

  /// The Tenant Value for status — falls back to canonical if unmapped.
  String get displayStatus => display?.status ?? status;

  bool get isDecommissioned => status == 'Decommissioned';

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      assetType: json['asset_type'] as String,
      facilityId: json['facility_id'] as String,
      locationId: json['location_id'] as String?,
      serialNumber: json['serial_number'] as String?,
      status: json['status'] as String,
      display: json['display'] != null
          ? AssetDisplay.fromJson(json['display'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class AssetDisplay {
  final String? assetType;
  final String? status;

  const AssetDisplay({this.assetType, this.status});

  factory AssetDisplay.fromJson(Map<String, dynamic> json) {
    return AssetDisplay(
      assetType: json['asset_type'] as String?,
      status: json['status'] as String?,
    );
  }
}

class AssetList {
  final List<Asset> data;
  final Pagination pagination;

  const AssetList({required this.data, required this.pagination});

  factory AssetList.fromJson(Map<String, dynamic> json) {
    return AssetList(
      data: (json['data'] as List<dynamic>)
          .map((e) => Asset.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class Pagination {
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;

  const Pagination({
    required this.hasMore,
    this.nextCursor,
    this.totalCount,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      hasMore: json['has_more'] as bool,
      nextCursor: json['next_cursor'] as String?,
      totalCount: json['total_count'] as int?,
    );
  }
}

class RegisterAssetRequest {
  final String name;
  final String assetType;
  final String facilityId;
  final String? serialNumber;

  const RegisterAssetRequest({
    required this.name,
    required this.assetType,
    required this.facilityId,
    this.serialNumber,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'asset_type': assetType,
        'facility_id': facilityId,
        if (serialNumber != null) 'serial_number': serialNumber,
      };
}

class UpdateAssetRequest {
  final String name;
  final String? serialNumber;

  const UpdateAssetRequest({required this.name, this.serialNumber});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (serialNumber != null) 'serial_number': serialNumber,
      };
}

class SetAssetLocationRequest {
  final String facilityId;
  final String locationId;

  const SetAssetLocationRequest({
    required this.facilityId,
    required this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'facility_id': facilityId,
        'location_id': locationId,
      };
}
