# ai-test-flutter-app

**Role:** Single Flutter codebase serving web (Chrome), mobile (iOS/Android), and desktop (macOS).
**Team:** Platform Guild

## Responsibility

All user-facing UX for the EAM/CMMS platform — every feature on every platform, from a single Dart codebase.

## Platform standards

This app follows the platform constitution:
https://github.com/Snip123/ai-test-platform-standards

See [CLAUDE.md](CLAUDE.md) for Claude Code context.

## Getting started

```bash
# Install dependencies
flutter pub get

# Run on Chrome
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

## Project structure

See [ADR-0006](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/adr/0006-flutter-for-frontend.md) for the framework decision rationale.

```
lib/
├── main.dart                     OTel init, ProviderScope, MaterialApp.router
├── app/
│   ├── router.dart               GoRouter routes
│   └── theme.dart                Design tokens
├── features/
│   └── {feature}/
│       ├── data/                 Repository (Dio calls → domain models)
│       ├── domain/               Models, value objects
│       └── presentation/         Screens, providers (Riverpod)
├── shared/
│   ├── telemetry/                AppTelemetry wrapper (ADR-0012)
│   └── tenant/                   Dio factory with X-Tenant-ID interceptor (ADR-0011)
└── generated/
    └── api/                      openapi-generator Dart client (do not edit)
```

## Docs

### This app
- [Architecture decisions](docs/adr/README.md)
- [Feature specs](docs/features/README.md)
- [Claude Code context](CLAUDE.md)

### Platform (authoritative)
- [Platform standards](https://github.com/Snip123/ai-test-platform-standards)
- [Platform ADRs](https://github.com/Snip123/ai-test-platform-standards/tree/main/docs/adr)
- [ADR-0006 — Flutter for all platforms](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/adr/0006-flutter-for-frontend.md)
- [ADR-0012 — Observability (OTel)](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/adr/0012-observability.md)
- [ADR-0014 — API design conventions](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/adr/0014-api-design-conventions.md)
- [Ubiquitous language](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/domain/ubiquitous-language.md)
- [Bounded contexts](https://github.com/Snip123/ai-test-platform-standards/blob/main/docs/domain/bounded-contexts.md)
