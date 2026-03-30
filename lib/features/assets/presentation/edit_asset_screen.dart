// Edit Asset screen — feature: update-asset (ADR-0002)
// Pre-fills current Asset values; validates name before submitting.
// 422 server errors surface detail + trace ID.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform_main/l10n/app_localizations.dart';
import '../../../shared/telemetry/telemetry.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';
import 'assets_providers.dart';

class EditAssetScreen extends ConsumerStatefulWidget {
  final String assetId;
  final Asset initialAsset;

  const EditAssetScreen({
    super.key,
    required this.assetId,
    required this.initialAsset,
  });

  @override
  ConsumerState<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends ConsumerState<EditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.initialAsset.name);
  late final _serialNumberController =
      TextEditingController(text: widget.initialAsset.serialNumber ?? '');

  late final _span = AppTelemetry.startSpan(
    'screen.EditAsset.viewed',
    attributes: {'screen': 'EditAssetScreen', 'asset_id': widget.assetId},
  );

  @override
  void dispose() {
    _span.end();
    _nameController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final actionSpan = AppTelemetry.startSpan('action.EditAsset.submit',
        attributes: {'asset_id': widget.assetId});
    try {
      final request = UpdateAssetRequest(
        name: _nameController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
      );
      final success = await ref
          .read(updateAssetProvider(widget.assetId).notifier)
          .submit(request);
      if (success && mounted) Navigator.of(context).pop();
    } finally {
      actionSpan.end();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final submitState = ref.watch(updateAssetProvider(widget.assetId));
    final isSubmitting = submitState is AsyncLoading;
    final serverError =
        submitState is AsyncError ? submitState.error as AssetsApiException? : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarTitleEditAsset)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('nameField'),
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.labelName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validationNameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('serialNumberField'),
                controller: _serialNumberController,
                decoration: InputDecoration(
                  labelText: l10n.labelSerialNumber,
                  hintText: l10n.hintOptional,
                ),
              ),
              const SizedBox(height: 32),
              if (serverError != null) ...[
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
                        serverError.detail,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                      if (serverError.traceId != null) ...[
                        const SizedBox(height: 4),
                        SelectableText(
                          key: const Key('traceId'),
                          l10n.labelTraceId(serverError.traceId!),
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
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.buttonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
