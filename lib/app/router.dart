// GoRouter navigation — ADR-0006
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/assets/presentation/asset_detail_screen.dart';
import '../features/assets/presentation/assets_screen.dart';
import '../features/assets/presentation/edit_asset_screen.dart';
import '../features/assets/presentation/register_asset_screen.dart';
import '../features/assets/presentation/set_asset_location_screen.dart';
import '../features/assets/presentation/assets_providers.dart';

final appRouter = GoRouter(
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
    GoRoute(
      path: '/assets/:id',
      builder: (context, state) => AssetDetailScreen(
        assetId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/assets/:id/edit',
      builder: (context, state) {
        final assetId = state.pathParameters['id']!;
        // Read the already-fetched asset from the detail provider.
        // If not yet loaded, show a loading scaffold — the edit screen
        // guards against null via the initialAsset requirement.
        return _EditAssetRouteWrapper(assetId: assetId);
      },
    ),
    GoRoute(
      path: '/assets/:id/location',
      builder: (context, state) {
        final assetId = state.pathParameters['id']!;
        return _SetLocationRouteWrapper(assetId: assetId);
      },
    ),
  ],
);

/// Reads the cached Asset from the detail provider before mounting EditAssetScreen.
class _EditAssetRouteWrapper extends ConsumerWidget {
  final String assetId;

  const _EditAssetRouteWrapper({required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetDetailProvider(assetId));
    return assetAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Asset')),
        body: Center(child: Text('Failed to load asset: $e')),
      ),
      data: (asset) =>
          EditAssetScreen(assetId: assetId, initialAsset: asset),
    );
  }
}

/// Reads the cached Asset from the detail provider before mounting SetAssetLocationScreen.
class _SetLocationRouteWrapper extends ConsumerWidget {
  final String assetId;

  const _SetLocationRouteWrapper({required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetDetailProvider(assetId));
    return assetAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Set Location')),
        body: Center(child: Text('Failed to load asset: $e')),
      ),
      data: (asset) =>
          SetAssetLocationScreen(assetId: assetId, initialAsset: asset),
    );
  }
}
