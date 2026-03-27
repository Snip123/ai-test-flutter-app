// Dio HTTP client factory — ADR-0011, ADR-0014
// Every request automatically carries X-Tenant-ID (required by the API gateway).
// For local dev the tenant is hardcoded to 'dev-tenant'. In production this
// value comes from the JWT claim resolved at login.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _localTenantId = 'dev-tenant';
const _localBaseUrl = 'http://localhost:8000/v1';

/// Provides a pre-configured [Dio] instance. Inject via Riverpod.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _localBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.add(_TenantInterceptor());
  return dio;
});

/// Injects the X-Tenant-ID header on every outbound request (ADR-0011).
class _TenantInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Tenant-ID'] = _localTenantId;
    handler.next(options);
  }
}
