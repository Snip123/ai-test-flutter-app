// Widget tests for Set Asset Location feature.
// Scenario names match the Gherkin file 1:1 — ADR-0002.
// Feature file: docs/features/assets/set-asset-location.feature
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:platform_main/features/assets/data/assets_repository.dart';
import 'package:platform_main/features/assets/domain/asset.dart';
import 'package:platform_main/features/assets/presentation/set_asset_location_screen.dart';
import 'package:platform_main/app/theme.dart';
import 'package:platform_main/shared/telemetry/telemetry.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

Asset _makeAsset({String? locationId}) => Asset(
      id: 'asset-001',
      tenantId: 'dev-tenant',
      name: 'Rooftop HVAC Unit',
      assetType: 'HVAC',
      facilityId: 'facility-001',
      locationId: locationId,
      status: 'Active',
      display: const AssetDisplay(assetType: 'Split System AC', status: 'Active'),
      createdAt: DateTime(2026, 3, 25),
    );

Future<void> _pumpLocationScreen(
  WidgetTester tester,
  MockAssetsRepository repo, {
  Asset? asset,
}) async {
  final initial = asset ?? _makeAsset();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [assetsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: appTheme,
        home: SetAssetLocationScreen(assetId: 'asset-001', initialAsset: initial),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    AppTelemetry.init();
    registerFallbackValue(
        const SetAssetLocationRequest(facilityId: 'f', locationId: 'l'));
  });

  late MockAssetsRepository mockRepo;

  setUp(() {
    mockRepo = MockAssetsRepository();
  });

  testWidgets('Facility Manager sets a Location on an Asset', (tester) async {
    when(() => mockRepo.setAssetLocation('asset-001', any()))
        .thenAnswer((_) async => _makeAsset(locationId: 'roof-level-3'));
    // getAsset called by the detail notifier after setLocation
    when(() => mockRepo.getAsset('asset-001'))
        .thenAnswer((_) async => _makeAsset(locationId: 'roof-level-3'));

    await _pumpLocationScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('facilityIdField')), 'facility-001');
    await tester.enterText(
        find.byKey(const Key('locationIdField')), 'roof-level-3');

    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    verify(() => mockRepo.setAssetLocation('asset-001', any())).called(1);
  });

  testWidgets(
      'Set Location form shows validation error when location ID is blank',
      (tester) async {
    await _pumpLocationScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('locationIdField')), '');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Location is required'), findsOneWidget);
    verifyNever(() => mockRepo.setAssetLocation(any(), any()));
  });

  testWidgets(
      'Set Location form pre-fills current values when a location is already set',
      (tester) async {
    final asset = _makeAsset(locationId: 'roof-level-3');

    await _pumpLocationScreen(tester, mockRepo, asset: asset);
    await tester.pumpAndSettle();

    // Pre-filled fields
    expect(
      tester
          .widget<EditableText>(find.descendant(
            of: find.byKey(const Key('facilityIdField')),
            matching: find.byType(EditableText),
          ))
          .controller
          .text,
      'facility-001',
    );
    expect(
      tester
          .widget<EditableText>(find.descendant(
            of: find.byKey(const Key('locationIdField')),
            matching: find.byType(EditableText),
          ))
          .controller
          .text,
      'roof-level-3',
    );
  });
}
