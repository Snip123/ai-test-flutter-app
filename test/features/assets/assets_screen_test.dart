// Widget tests for the Assets feature.
// Scenario names match the Gherkin file 1:1 — ADR-0002.
// Feature file: docs/features/assets/asset-management.feature
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fsi_platform/features/assets/data/assets_repository.dart';
import 'package:fsi_platform/features/assets/domain/asset.dart';
import 'package:fsi_platform/features/assets/presentation/assets_screen.dart';
import 'package:fsi_platform/features/assets/presentation/register_asset_screen.dart';
import 'package:fsi_platform/app/theme.dart';
import 'package:fsi_platform/shared/telemetry/telemetry.dart';
import 'package:go_router/go_router.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAssetsRepository extends Mock implements AssetsRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Asset _makeAsset({
  String id = '01HV000000000000000000001',
  String name = 'Rooftop HVAC-1',
  String assetType = 'HVAC',
  String displayAssetType = 'Split System AC',
  String facilityId = 'facility-001',
  String status = 'Active',
}) {
  return Asset(
    id: id,
    tenantId: 'dev-tenant',
    name: name,
    assetType: assetType,
    facilityId: facilityId,
    status: status,
    display: AssetDisplay(assetType: displayAssetType, status: status),
    createdAt: DateTime(2026, 3, 25),
  );
}

AssetList _makeAssetList(List<Asset> assets) => AssetList(
      data: assets,
      pagination: const Pagination(hasMore: false, totalCount: 0),
    );

/// Pumps the full app with a fresh GoRouter per test (prevents state bleed
/// between tests when a previous test navigated away from the initial route).
Future<void> _pumpApp(
  WidgetTester tester,
  MockAssetsRepository repo,
) async {
  final router = GoRouter(
    initialLocation: '/assets',
    routes: [
      GoRoute(
        path: '/assets',
        builder: (context, state) => const AssetsScreen(),
      ),
      GoRoute(
        path: '/assets/register',
        builder: (context, state) => const RegisterAssetScreen(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assetsRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(
        theme: fsiTheme,
        routerConfig: router,
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    AppTelemetry.init();
    // Required by mocktail for any() matchers on custom types
    registerFallbackValue(const RegisterAssetRequest(
      name: 'fallback',
      assetType: 'fallback',
      facilityId: 'fallback',
    ));
  });

  late MockAssetsRepository mockRepo;

  setUp(() {
    mockRepo = MockAssetsRepository();
  });

  // Scenario: Asset list displays registered Assets using Tenant Values
  testWidgets(
    'Asset list displays registered Assets using Tenant Values',
    (tester) async {
      final assets = [
        _makeAsset(
          id: '01HV000000000000000000001',
          name: 'Rooftop HVAC-1',
          assetType: 'HVAC',
          displayAssetType: 'Split System AC',
        ),
        _makeAsset(
          id: '01HV000000000000000000002',
          name: 'Boiler Unit 2',
          assetType: 'Boiler',
          displayAssetType: 'Gas Boiler',
        ),
      ];
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList(assets));

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      // Asset names displayed
      expect(find.text('Rooftop HVAC-1'), findsOneWidget);
      expect(find.text('Boiler Unit 2'), findsOneWidget);

      // Tenant Values displayed, NOT canonical values (ADR-0004)
      expect(find.text('Split System AC'), findsOneWidget);
      expect(find.text('Gas Boiler'), findsOneWidget);
      expect(find.text('HVAC'), findsNothing);
      expect(find.text('Boiler'), findsNothing);
    },
  );

  // Scenario: Asset list shows a loading indicator while fetching Assets
  testWidgets(
    'Asset list shows a loading indicator while fetching Assets',
    (tester) async {
      // Never-completing future — no pending timers, reliably shows loading state
      when(() => mockRepo.listAssets())
          .thenAnswer((_) => Completer<AssetList>().future);

      await _pumpApp(tester, mockRepo);
      await tester.pump(); // one frame — still loading

      expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
    },
  );

  // Scenario: Asset list shows an empty state when no Assets are registered
  testWidgets(
    'Asset list shows an empty state when no Assets are registered',
    (tester) async {
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList([]));

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('emptyStateMessage')), findsOneWidget);
    },
  );

  // Scenario: Asset list shows an error state when the Assets service is unavailable
  testWidgets(
    'Asset list shows an error state when the Assets service is unavailable',
    (tester) async {
      when(() => mockRepo.listAssets()).thenThrow(
        const AssetsApiException(
          statusCode: 503,
          detail: 'Service temporarily unavailable',
          traceId: 'abc-trace-123',
        ),
      );

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('errorMessage')), findsOneWidget);
      expect(find.byKey(const Key('traceId')), findsOneWidget);
      expect(find.textContaining('abc-trace-123'), findsOneWidget);
    },
  );

  // Scenario: Facility Manager navigates to the Register Asset form
  testWidgets(
    'Facility Manager navigates to the Register Asset form',
    (tester) async {
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList([]));

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('registerAssetButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('nameField')), findsOneWidget);
      expect(find.byKey(const Key('assetTypeField')), findsOneWidget);
      expect(find.byKey(const Key('facilityIdField')), findsOneWidget);
    },
  );

  // Scenario: Register Asset form shows client-side validation errors for missing required fields
  testWidgets(
    'Register Asset form shows client-side validation errors for missing required fields',
    (tester) async {
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList([]));

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('registerAssetButton')));
      await tester.pumpAndSettle();

      // Submit without filling any fields
      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Asset Type is required'), findsOneWidget);
      expect(find.text('Facility is required'), findsOneWidget);

      // Repository must NOT have been called
      verifyNever(() => mockRepo.registerAsset(any()));
    },
  );

  // Scenario: Facility Manager registers a new Asset successfully
  testWidgets(
    'Facility Manager registers a new Asset successfully',
    (tester) async {
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList([]));
      when(() => mockRepo.registerAsset(any()))
          .thenAnswer((_) async => _makeAsset(name: 'Rooftop HVAC-3'));

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('registerAssetButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('nameField')), 'Rooftop HVAC-3');
      await tester.enterText(find.byKey(const Key('assetTypeField')), 'HVAC');
      await tester.enterText(find.byKey(const Key('facilityIdField')), 'facility-001');

      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      // Navigated back to Asset list
      expect(find.byType(AssetsScreen), findsOneWidget);
    },
  );

  // Scenario: Register Asset form shows a server validation error with trace ID
  testWidgets(
    'Register Asset form shows a server validation error with trace ID',
    (tester) async {
      when(() => mockRepo.listAssets())
          .thenAnswer((_) async => _makeAssetList([]));
      when(() => mockRepo.registerAsset(any())).thenThrow(
        const AssetsApiException(
          statusCode: 422,
          detail: 'asset_type is not a recognised Canonical Asset Type',
          traceId: 'xyz-trace-456',
        ),
      );

      await _pumpApp(tester, mockRepo);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('registerAssetButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('nameField')), 'Rooftop HVAC-3');
      await tester.enterText(find.byKey(const Key('assetTypeField')), 'INVALID');
      await tester.enterText(find.byKey(const Key('facilityIdField')), 'facility-001');

      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('serverErrorMessage')), findsOneWidget);
      expect(find.byKey(const Key('traceId')), findsOneWidget);
      expect(find.textContaining('xyz-trace-456'), findsOneWidget);
    },
  );
}
