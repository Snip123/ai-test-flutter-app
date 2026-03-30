// Set Asset Location screen — feature: set-asset-location (ADR-0002)
// Pre-fills current location if set; validates both fields before submitting.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_main/l10n/app_localizations.dart';
import '../../../shared/telemetry/telemetry.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';
import 'assets_providers.dart';

class SetAssetLocationScreen extends ConsumerStatefulWidget {
  final String assetId;
  final Asset initialAsset;

  const SetAssetLocationScreen({
    super.key,
    required this.assetId,
    required this.initialAsset,
  });

  @override
  ConsumerState<SetAssetLocationScreen> createState() =>
      _SetAssetLocationScreenState();
}

class _SetAssetLocationScreenState
    extends ConsumerState<SetAssetLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _facilityIdController =
      TextEditingController(text: widget.initialAsset.facilityId);
  late final _locationIdController =
      TextEditingController(text: widget.initialAsset.locationId ?? '');

  bool _isSubmitting = false;
  AssetsApiException? _serverError;

  late final _span = AppTelemetry.startSpan(
    'screen.SetAssetLocation.viewed',
    attributes: {
      'screen': 'SetAssetLocationScreen',
      'asset_id': widget.assetId
    },
  );

  @override
  void dispose() {
    _span.end();
    _facilityIdController.dispose();
    _locationIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final actionSpan = AppTelemetry.startSpan(
        'action.SetAssetLocation.submit',
        attributes: {'asset_id': widget.assetId});
    try {
      final success = await ref
          .read(assetDetailProvider(widget.assetId).notifier)
          .setLocation(
            _facilityIdController.text.trim(),
            _locationIdController.text.trim(),
          );
      if (success && mounted) Navigator.of(context).pop();
    } on AssetsApiException catch (e) {
      setState(() => _serverError = e);
    } finally {
      actionSpan.end();
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarTitleSetLocation)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('facilityIdField'),
                controller: _facilityIdController,
                decoration: InputDecoration(
                  labelText: l10n.labelFacilityId,
                  hintText: l10n.hintFacilityId,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.validationFacilityRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('locationIdField'),
                controller: _locationIdController,
                decoration: InputDecoration(
                  labelText: l10n.labelLocationId,
                  hintText: l10n.hintLocationId,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.validationLocationRequired
                    : null,
              ),
              const SizedBox(height: 32),
              if (_serverError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: const Key('serverErrorMessage'),
                        _serverError!.detail,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                      if (_serverError!.traceId != null) ...[
                        const SizedBox(height: 4),
                        SelectableText(
                          key: const Key('traceId'),
                          l10n.labelTraceId(_serverError!.traceId!),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                key: const Key('submitButton'),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.buttonSetLocation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
