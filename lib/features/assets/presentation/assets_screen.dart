// Assets list screen — Gherkin: "Asset Management" scenarios 1–4
// Three states: loading, data (list or empty), error.
// Canonical Asset Types are NEVER displayed — always use displayAssetType (ADR-0004).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/telemetry/telemetry.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';
import 'assets_providers.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  late final _span = AppTelemetry.startSpan(
    'screen.Assets.viewed',
    attributes: {'screen': 'AssetsScreen'},
  );

  @override
  void dispose() {
    _span.end();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(assetListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('registerAssetButton'),
        onPressed: () => context.push('/assets/register').then((_) {
          ref.read(assetListProvider.notifier).refresh();
        }),
        icon: const Icon(Icons.add),
        label: const Text('Register Asset'),
      ),
      body: assetsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('loadingIndicator')),
        ),
        error: (error, _) => _ErrorView(error: error),
        data: (assetList) => assetList.data.isEmpty
            ? const _EmptyView()
            : _AssetListView(assets: assetList.data),
      ),
    );
  }
}

class _AssetListView extends StatelessWidget {
  final List<Asset> assets;

  const _AssetListView({required this.assets});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final asset = assets[index];
        return ListTile(
          key: Key('assetTile_${asset.id}'),
          title: Text(
            asset.name,
            key: Key('assetName_${asset.id}'),
          ),
          // Tenant Value displayed — never canonical (ADR-0004)
          subtitle: Text(
            asset.displayAssetType,
            key: Key('assetType_${asset.id}'),
          ),
          trailing: _StatusChip(label: asset.displayStatus),
          onTap: () => context.push('/assets/${asset.id}'),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            key: Key('emptyStateMessage'),
            'No Assets registered yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final apiError = error is AssetsApiException ? error as AssetsApiException : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              key: const Key('errorMessage'),
              apiError?.detail ?? 'Failed to load Assets. Please try again.',
              textAlign: TextAlign.center,
            ),
            if (apiError?.traceId != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                key: const Key('traceId'),
                'Trace ID: ${apiError!.traceId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
