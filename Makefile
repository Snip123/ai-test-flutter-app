APP_NAME := fsi-platform-flutter

.PHONY: run run-chrome run-ios run-android run-macos test analyze generate-client

run-chrome:
	flutter run -d chrome

run-ios:
	flutter run -d ios

run-android:
	flutter run -d android

run-macos:
	flutter run -d macos

test:
	flutter test

analyze:
	flutter analyze

generate-client:
	# Regenerates the Dart API client from the assets service OpenAPI spec.
	# Requires openapi-generator-cli on PATH.
	openapi-generator-cli generate \
		-i ../ai-test-assets-service/docs/api/openapi.yaml \
		-g dart-dio \
		-o lib/generated/api \
		--additional-properties=pubName=fsi_assets_client
