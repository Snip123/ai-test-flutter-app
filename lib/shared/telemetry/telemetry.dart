// OTel instrumentation — ADR-0012
// Uses the console exporter for local dev. Switch CollectorExporter for
// production (point OTEL_ENDPOINT at Cloud Trace / Jaeger via env).
import 'package:opentelemetry/api.dart' as otel;
import 'package:opentelemetry/sdk.dart' as otel_sdk;

class AppTelemetry {
  static late otel.Tracer _tracer;

  /// Call once from main() before runApp.
  static void init({String environment = 'local'}) {
    final processor = otel_sdk.SimpleSpanProcessor(
      otel_sdk.ConsoleExporter(),
    );
    final provider = otel_sdk.TracerProviderBase(
      processors: [processor],
      resource: otel_sdk.Resource([
        otel.Attribute.fromString('service.name', 'fsi-platform-flutter'),
        otel.Attribute.fromString('environment', environment),
      ]),
    );
    otel.registerGlobalTracerProvider(provider);
    _tracer = provider.getTracer('fsi-platform-flutter', version: '1.0.0');
  }

  /// Start a span. Always set tenant_id. Call [span.end()] when done.
  static otel.Span startSpan(
    String name, {
    String tenantId = 'dev-tenant',
    Map<String, String> attributes = const {},
  }) {
    final span = _tracer.startSpan(name);
    span.setAttribute(otel.Attribute.fromString('tenant_id', tenantId));
    for (final entry in attributes.entries) {
      span.setAttribute(otel.Attribute.fromString(entry.key, entry.value));
    }
    return span;
  }
}
