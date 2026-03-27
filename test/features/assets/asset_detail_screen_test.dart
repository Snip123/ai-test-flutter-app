// Widget tests for Asset Detail and Decommission features.
// Scenario names match the Gherkin files 1:1 — ADR-0002.
// Feature files: docs/features/assets/asset-detail.feature
//                docs/features/assets/decommission-asset.feature
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fsi_platform/features/assets/data/assets_repository.dart';
import 'package:fsi_platform/features/assets/domain/asset.dart';
import 'package:fsi_platform/features/assets/presentation/asset_detail_screen.dart';
import 'package:fsi_platform/app/theme.dart';
import 'package:fsi_platform/shared/telemetry/telemetry.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

Asset _makeAsset({
  String id = 'asset-001',
  String name = 'Rooftop HVAC Unit',
  String status = 'Active',
  String? locationId,
}) =>
    Asset(
      id: id,
      tenantId: 'dev-tenant',
      name: name,
      assetType: 'HVAC',
      facilityId: 'facility-001',
      locationId: locationId,
      status: status,
      display: AssetDisplay(assetType: 'Split System AC', status: status),
      createdAt: DateTime(2026, 3, 25),
    );

Future<void> _pumpDetailScreen(
  WidgetTester tester,
  MockAssetsRepository repo, {
  String assetId = 'asset-001',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [assetsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: fsiTheme,
        home: AssetDetailScreen(assetId: assetId),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    AppTelemetry.init();
  });

  late MockAssetsRepository mockRepo;

  setUp(() {
    mockRepo = MockAssetsRepository();
  });

  // ── asset-detail.feature ──────────────────────────────────────────────────

  testWidgets('Facility Manager views Asset detail', (tester) async {
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) async => _makeAsset());

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assetName')), findsOneWidget);
    expect(find.text('Rooftop HVAC Unit'), findsOneWidget);
    // Tenant Value for Asset Type — not canonical (ADR-0004)
    expect(find.byKey(const Key('assetType')), findsOneWidget);
    expect(find.text('Split System AC'), findsOneWidget);
    expect(find.text('HVAC'), findsNothing);
    // Status Tenant Value
    expect(find.byKey(const Key('assetStatus')), findsOneWidget);
    // Facility ID shown
    expect(find.byKey(const Key('facilityId')), findsOneWidget);
  });

  testWidgets('Asset detail shows a loading indicator while fetching',
      (tester) async {
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) => Completer<Asset>().future);

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pump();

    expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
  });

  testWidgets(
      'Asset detail shows an error state with trace ID when the service is unavailable',
      (tester) async {
    when(() => mockRepo.getAsset('asset-001')).thenThrow(
      const AssetsApiException(
        statusCode: 503,
        detail: 'Service unavailable',
        traceId: 'trace-abc-123',
      ),
    );

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('errorMessage')), findsOneWidget);
    expect(find.byKey(const Key('traceId')), findsOneWidget);
    expect(find.textContaining('trace-abc-123'), findsOneWidget);
  });

  // ── decommission-asset.feature ────────────────────────────────────────────

  testWidgets('Facility Manager decommissions an Active Asset', (tester) async {
    final decommissioned = _makeAsset(status: 'Decommissioned');
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) async => _makeAsset());
    when(() => mockRepo.decommissionAsset('asset-001', any()))
        .thenAnswer((_) async => decommissioned);

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    // Decommission button visible for Active asset
    expect(find.byKey(const Key('decommissionButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('decommissionButton')));
    await tester.pumpAndSettle();

    // Confirmation dialog shown
    expect(find.byKey(const Key('decommissionDialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmDecommissionButton')));
    await tester.pumpAndSettle();

    // Status updated to Decommissioned; button gone
    expect(find.text('Decommissioned'), findsOneWidget);
    expect(find.byKey(const Key('decommissionButton')), findsNothing);
  });

  testWidgets(
      'Decommission button is not shown for an already-Decommissioned Asset',
      (tester) async {
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) async => _makeAsset(status: 'Decommissioned'));

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('decommissionButton')), findsNothing);
  });

  testWidgets('Decommission confirmation dialog can be cancelled',
      (tester) async {
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) async => _makeAsset());

    await _pumpDetailScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('decommissionButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('decommissionDialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancelDecommissionButton')));
    await tester.pumpAndSettle();

    // Dialog dismissed; asset still Active; API never called
    expect(find.byKey(const Key('decommissionDialog')), findsNothing);
    expect(find.text('Active'), findsOneWidget);
    verifyNever(() => mockRepo.decommissionAsset(any(), any()));
  });
}
