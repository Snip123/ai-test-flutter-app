// Assets repository — data layer for the Assets bounded context.
// Calls the API gateway; all requests carry X-Tenant-ID via the Dio interceptor.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opentelemetry/api.dart' as otel;
import '../domain/asset.dart';
import '../../../shared/tenant/tenant_client.dart';
import '../../../shared/telemetry/telemetry.dart';

final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  return AssetsRepository(ref.watch(dioProvider));
});

class AssetsRepository {
  final Dio _dio;

  AssetsRepository(this._dio);

  /// Lists all Assets for the current Tenant.
  /// Corresponds to GET /v1/assets.
  Future<AssetList> listAssets() async {
    final span = AppTelemetry.startSpan('assets.listAssets');
    try {
      final response = await _dio.get<Map<String, dynamic>>('/assets');
      return AssetList.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  /// Gets a single Asset by ID for the current Tenant.
  /// Corresponds to GET /v1/assets/{id}.
  Future<Asset> getAsset(String id) async {
    final span = AppTelemetry.startSpan('assets.getAsset',
        attributes: {'asset_id': id});
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/assets/$id');
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  /// Registers a new Asset for the current Tenant.
  /// Corresponds to POST /v1/assets.
  Future<Asset> registerAsset(RegisterAssetRequest request) async {
    final span = AppTelemetry.startSpan('assets.registerAsset');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/assets',
        data: request.toJson(),
      );
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  /// Updates mutable attributes on an existing Asset.
  /// Corresponds to PATCH /v1/assets/{id}.
  Future<Asset> updateAsset(String id, UpdateAssetRequest request) async {
    final span = AppTelemetry.startSpan('assets.updateAsset',
        attributes: {'asset_id': id});
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/assets/$id',
        data: request.toJson(),
      );
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  /// Decommissions an Active Asset.
  /// Corresponds to POST /v1/assets/{id}/decommission.
  Future<Asset> decommissionAsset(String id, String reason) async {
    final span = AppTelemetry.startSpan('assets.decommissionAsset',
        attributes: {'asset_id': id});
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/assets/$id/decommission',
        data: {'reason': reason},
      );
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  /// Sets or updates the Location of an Asset.
  /// Corresponds to PUT /v1/assets/{id}/location.
  Future<Asset> setAssetLocation(
      String id, SetAssetLocationRequest request) async {
    final span = AppTelemetry.startSpan('assets.setAssetLocation',
        attributes: {'asset_id': id});
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/assets/$id/location',
        data: request.toJson(),
      );
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      span.setAttribute(otel.Attribute.fromString('error', 'true'));
      throw _mapError(e);
    } finally {
      span.end();
    }
  }

  AssetsApiException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;
    final traceId = body is Map ? body['trace_id'] as String? : null;
    final detail = body is Map ? body['detail'] as String? : null;

    return AssetsApiException(
      statusCode: statusCode,
      detail: detail ?? e.message ?? 'Unknown error',
      traceId: traceId,
    );
  }
}

class AssetsApiException implements Exception {
  final int? statusCode;
  final String detail;
  final String? traceId;

  const AssetsApiException({
    this.statusCode,
    required this.detail,
    this.traceId,
  });

  bool get isValidationError => statusCode == 422;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() =>
      'AssetsApiException($statusCode): $detail'
      '${traceId != null ? ' [trace: $traceId]' : ''}';
}
