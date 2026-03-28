// Asset detail screen — features: asset-detail, decommission-asset (ADR-0002)
// Three states: loading, data, error on initial fetch.
// Decommission action: confirmation dialog → API → state update.
// Canonical values never displayed — always Tenant Values (ADR-0004).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fsi_platform/l10n/app_localizations.dart';
import '../../../shared/telemetry/telemetry.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';
import 'assets_providers.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  final String assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  late final _span = AppTelemetry.startSpan(
    'screen.AssetDetail.viewed',
    attributes: {'screen': 'AssetDetailScreen', 'asset_id': widget.assetId},
  );

  @override
  void dispose() {
    _span.end();
    super.dispose();
  }

  Future<void> _showDecommissionDialog(Asset asset) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _DecommissionDialog(assetName: asset.name),
    );

    if (reason == null || !mounted) return;

    final actionSpan = AppTelemetry.startSpan('action.AssetDetail.decommission',
        attributes: {'asset_id': widget.assetId});
    try {
      await ref
          .read(assetDetailProvider(widget.assetId).notifier)
          .decommission(reason);
    } finally {
      actionSpan.end();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assetAsync = ref.watch(assetDetailProvider(widget.assetId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarTitleAssetDetail),
        actions: [
          assetAsync.whenOrNull(
            data: (asset) => !asset.isDecommissioned
                ? IconButton(
                    key: const Key('editButton'),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.tooltipEdit,
                    onPressed: () => context
                        .push('/assets/${widget.assetId}/edit')
                        .then((_) => ref.invalidate(
                            assetDetailProvider(widget.assetId))),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: assetAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('loadingIndicator')),
        ),
        error: (error, _) => _ErrorView(error: error),
        data: (asset) => _AssetDetailView(
          asset: asset,
          onDecommission: () => _showDecommissionDialog(asset),
          onSetLocation: () => context
              .push('/assets/${widget.assetId}/location')
              .then((_) =>
                  ref.invalidate(assetDetailProvider(widget.assetId))),
        ),
      ),
    );
  }
}

/// Dialog that owns the reason TextEditingController so it is disposed
/// correctly when the dialog's animation finishes (not during it).
/// Returns the reason string on confirm, or null on cancel.
class _DecommissionDialog extends StatefulWidget {
  final String assetName;

  const _DecommissionDialog({required this.assetName});

  @override
  State<_DecommissionDialog> createState() => _DecommissionDialogState();
}

class _DecommissionDialogState extends State<_DecommissionDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      key: const Key('decommissionDialog'),
      title: Text(l10n.dialogTitleDecommission),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dialogBodyDecommission(widget.assetName)),
            const SizedBox(height: 16),
            TextField(
              key: const Key('decommissionReasonField'),
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.labelReason,
                hintText: l10n.hintReason,
              ),
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancelDecommissionButton'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          key: const Key('confirmDecommissionButton'),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(_reasonController.text.trim()),
          child: Text(l10n.buttonDecommission),
        ),
      ],
    );
  }
}

class _AssetDetailView extends StatelessWidget {
  final Asset asset;
  final VoidCallback onDecommission;
  final VoidCallback onSetLocation;

  const _AssetDetailView({
    required this.asset,
    required this.onDecommission,
    required this.onSetLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailCard(
            children: [
              _DetailRow(label: l10n.labelName, value: asset.name, valueKey: 'assetName'),
              // Tenant Value — never canonical (ADR-0004)
              _DetailRow(
                  label: l10n.labelAssetType,
                  value: asset.displayAssetType,
                  valueKey: 'assetType'),
              _DetailRow(
                  label: l10n.labelStatus,
                  value: asset.displayStatus,
                  valueKey: 'assetStatus'),
              _DetailRow(
                  label: l10n.labelFacility,
                  value: asset.facilityId,
                  valueKey: 'facilityId'),
              if (asset.locationId != null)
                _DetailRow(
                    label: l10n.labelLocation,
                    value: asset.locationId!,
                    valueKey: 'locationId'),
              if (asset.serialNumber != null)
                _DetailRow(
                    label: l10n.labelSerialNumber,
                    value: asset.serialNumber!,
                    valueKey: 'serialNumber'),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('setLocationButton'),
            onPressed: onSetLocation,
            icon: const Icon(Icons.location_on_outlined),
            label: Text(asset.locationId == null
                ? l10n.buttonSetLocation
                : l10n.buttonUpdateLocation),
          ),
          if (!asset.isDecommissioned) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('decommissionButton'),
              onPressed: onDecommission,
              icon: const Icon(Icons.archive_outlined),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              label: Text(l10n.buttonDecommission),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String valueKey;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, key: Key(valueKey)),
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
    final l10n = AppLocalizations.of(context)!;
    final apiError =
        error is AssetsApiException ? error as AssetsApiException : null;
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
              apiError?.detail ?? l10n.errorLoadAsset,
              textAlign: TextAlign.center,
            ),
            if (apiError?.traceId != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                key: const Key('traceId'),
                l10n.labelTraceId(apiError!.traceId!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
