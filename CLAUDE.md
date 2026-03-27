# ai-test-flutter-app — Claude Code Context

> Generated from ai-test-platform-standards/templates/service-CLAUDE.md (Flutter-adapted)
> This file is authoritative for the Flutter client. Do not contradict platform standards.

---

## Platform standards (authoritative)

This app follows the platform constitution. Key references — load on demand:

- Ubiquitous language: @../ai-test-platform-standards/docs/domain/ubiquitous-language.md
- Context map: @../ai-test-platform-standards/docs/domain/bounded-contexts.md
- Flutter ADR: @../ai-test-platform-standards/docs/adr/0006-flutter-for-frontend.md
- OTel ADR: @../ai-test-platform-standards/docs/adr/0012-observability.md
- REST/API ADR: @../ai-test-platform-standards/docs/adr/0014-api-design-conventions.md
- Flutter agent context: @../ai-test-platform-standards/agents/flutter-agent.md

---

## This app

**Role:** Single Flutter codebase serving web (Chrome), mobile (iOS/Android), and desktop (macOS).
**Owned by:** Platform Guild
**Responsibility:** All user-facing UX for the FSI EAM/CMMS platform — every feature on every platform.

### Local docs
- Local ADRs: @docs/adr/
- Feature specs: @docs/features/
  - Assets: @docs/features/assets/asset-management.feature

---

## Hard rules (non-negotiable)

1. **Spec first** — no feature code without a `.feature` file in `docs/features/`
2. **Tenant Values only** — never render a Canonical Value directly; always use `displayAssetType`, `displayStatus`, etc.
3. **All platforms** — no `kIsWeb`, `Platform.isIOS`, or feature-flag checks inside feature code; layout adaptations only
4. **Three states** — every async operation has loading, success, and error UI
5. **OTel on every screen** — start a span in `initState`, end it in `dispose`; start a span for every user action
6. **Use the Dio provider** — never create a raw `Dio` or `http.Client`; always use `dioProvider` which carries `X-Tenant-ID`
7. **Generated client** — run `make generate-client` after any API change; do not edit `lib/generated/`

---

## Project structure

```
lib/
├── main.dart                     — OTel init, ProviderScope, MaterialApp.router
├── app/
│   ├── router.dart               — GoRouter routes
│   └── theme.dart                — Design tokens (placeholder for fsi-design-system)
├── features/
│   └── {feature}/
│       ├── data/                 — Repository (Dio calls → domain models)
│       ├── domain/               — Models, value objects
│       └── presentation/         — Screens, providers (Riverpod)
├── shared/
│   ├── telemetry/telemetry.dart  — AppTelemetry wrapper (ADR-0012)
│   └── tenant/tenant_client.dart — Dio factory with X-Tenant-ID interceptor (ADR-0011)
└── generated/
    └── api/                      — openapi-generator Dart client (do not edit)
```

---

## Build & run

```bash
# Install dependencies
flutter pub get

# Run on Chrome (walking skeleton target)
flutter run -d chrome

# Run on iOS Simulator
flutter run -d ios

# Run on Android Emulator
flutter run -d android

# Run on macOS
flutter run -d macos

# Run widget tests
flutter test

# Regenerate API client after OpenAPI spec changes
make generate-client

# Lint
flutter analyze
```

---

## OTel pattern (required on every screen)

```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  late final _span = AppTelemetry.startSpan(
    'screen.MyScreen.viewed',
    attributes: {'screen': 'MyScreen'},
  );

  @override
  void dispose() {
    _span.end();
    super.dispose();
  }
}

// Every user action:
final actionSpan = AppTelemetry.startSpan('action.MyFeature.doThing');
try {
  // ... action
} finally {
  actionSpan.end();
}
```

---

## Tenant Value display pattern (required)

```dart
// CORRECT — uses Tenant Value resolved server-side
Text(asset.displayAssetType)

// WRONG — exposes Canonical Value to the user
Text(asset.assetType)
```

---

## ADR index (this app)

| ID | Title | Status |
|----|-------|--------|
| — | No local ADRs yet | — |
