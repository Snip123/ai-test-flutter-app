// Register Asset screen — Gherkin: "Asset Management" scenarios 5–8
// Client-side validation before submission; 422 surfaces trace ID (ADR-0014).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/telemetry/telemetry.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';
import 'assets_providers.dart';

class RegisterAssetScreen extends ConsumerStatefulWidget {
  const RegisterAssetScreen({super.key});

  @override
  ConsumerState<RegisterAssetScreen> createState() =>
      _RegisterAssetScreenState();
}

class _RegisterAssetScreenState extends ConsumerState<RegisterAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _assetTypeController = TextEditingController();
  final _facilityIdController = TextEditingController();

  late final _span = AppTelemetry.startSpan(
    'screen.RegisterAsset.viewed',
    attributes: {'screen': 'RegisterAssetScreen'},
  );

  @override
  void dispose() {
    _span.end();
    _nameController.dispose();
    _assetTypeController.dispose();
    _facilityIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Client-side validation — Gherkin scenario 7
    if (!_formKey.currentState!.validate()) return;

    final actionSpan = AppTelemetry.startSpan('action.RegisterAsset.submit');
    try {
      final request = RegisterAssetRequest(
        name: _nameController.text.trim(),
        assetType: _assetTypeController.text.trim(),
        facilityId: _facilityIdController.text.trim(),
      );

      final notifier = ref.read(registerAssetProvider.notifier);
      final success = await notifier.submit(request);

      if (success && mounted) {
        context.pop();
      }
    } finally {
      actionSpan.end();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(registerAssetProvider);
    final isSubmitting = submitState is AsyncLoading;
    final serverError = submitState is AsyncError
        ? submitState.error as AssetsApiException?
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Register Asset')),
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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Rooftop HVAC-3',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('assetTypeField'),
                controller: _assetTypeController,
                decoration: const InputDecoration(
                  labelText: 'Asset Type',
                  hintText: 'e.g. HVAC',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Asset Type is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('facilityIdField'),
                controller: _facilityIdController,
                decoration: const InputDecoration(
                  labelText: 'Facility',
                  hintText: 'e.g. facility-001',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Facility is required'
                    : null,
              ),
              const SizedBox(height: 32),

              // Server-side 422 error — Gherkin scenario 8
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
                          'Trace ID: ${serverError.traceId}',
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
                    : const Text('Register Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
