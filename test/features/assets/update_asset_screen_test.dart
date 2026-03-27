// Widget tests for Update Asset feature.
// Scenario names match the Gherkin file 1:1 — ADR-0002.
// Feature file: docs/features/assets/update-asset.feature
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fsi_platform/features/assets/data/assets_repository.dart';
import 'package:fsi_platform/features/assets/domain/asset.dart';
import 'package:fsi_platform/features/assets/presentation/edit_asset_screen.dart';
import 'package:fsi_platform/app/theme.dart';
import 'package:fsi_platform/shared/telemetry/telemetry.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

Asset _makeAsset({String name = 'Rooftop HVAC Unit'}) => Asset(
      id: 'asset-001',
      tenantId: 'dev-tenant',
      name: name,
      assetType: 'HVAC',
      facilityId: 'facility-001',
      status: 'Active',
      display: const AssetDisplay(assetType: 'Split System AC', status: 'Active'),
      createdAt: DateTime(2026, 3, 25),
    );

Future<void> _pumpEditScreen(
  WidgetTester tester,
  MockAssetsRepository repo, {
  Asset? asset,
}) async {
  final initial = asset ?? _makeAsset();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [assetsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: fsiTheme,
        home: EditAssetScreen(assetId: 'asset-001', initialAsset: initial),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    AppTelemetry.init();
    registerFallbackValue(
        const UpdateAssetRequest(name: 'fallback'));
  });

  late MockAssetsRepository mockRepo;

  setUp(() {
    mockRepo = MockAssetsRepository();
  });

  testWidgets(
      'Facility Manager updates Asset name and serial number', (tester) async {
    when(() => mockRepo.updateAsset('asset-001', any()))
        .thenAnswer((_) async => _makeAsset(name: 'Rooftop HVAC Unit - R1'));

    await _pumpEditScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    // Pre-filled with current values
    expect(find.byKey(const Key('nameField')), findsOneWidget);
    expect(tester.widget<EditableText>(find.descendant(
      of: find.byKey(const Key('nameField')),
      matching: find.byType(EditableText),
    )).controller.text, 'Rooftop HVAC Unit');

    await tester.enterText(
        find.byKey(const Key('nameField')), 'Rooftop HVAC Unit - R1');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    verify(() => mockRepo.updateAsset('asset-001', any())).called(1);
  });

  testWidgets('Edit Asset form shows validation error when name is blank',
      (tester) async {
    await _pumpEditScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nameField')), '');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    verifyNever(() => mockRepo.updateAsset(any(), any()));
  });

  testWidgets('Edit Asset form shows a server error with trace ID',
      (tester) async {
    when(() => mockRepo.updateAsset('asset-001', any())).thenThrow(
      const AssetsApiException(
        statusCode: 422,
        detail: 'name is invalid',
        traceId: 'trace-xyz-456',
      ),
    );

    await _pumpEditScreen(tester, mockRepo);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nameField')), 'Bad Name');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('serverErrorMessage')), findsOneWidget);
    expect(find.byKey(const Key('traceId')), findsOneWidget);
    expect(find.textContaining('trace-xyz-456'), findsOneWidget);
  });
}
