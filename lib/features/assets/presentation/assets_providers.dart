// Riverpod providers for the Assets feature — ADR-0006 (Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/assets_repository.dart';
import '../domain/asset.dart';

/// Fetches and holds the Asset list for the current Tenant.
final assetListProvider = AsyncNotifierProvider<AssetListNotifier, AssetList>(
  AssetListNotifier.new,
);

class AssetListNotifier extends AsyncNotifier<AssetList> {
  @override
  Future<AssetList> build() => _fetch();

  Future<AssetList> _fetch() =>
      ref.read(assetsRepositoryProvider).listAssets();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// Fetches and holds a single Asset by ID.
/// Supports decommission and setLocation mutations that update state in-place.
final assetDetailProvider =
    AsyncNotifierProviderFamily<AssetDetailNotifier, Asset, String>(
  AssetDetailNotifier.new,
);

class AssetDetailNotifier extends FamilyAsyncNotifier<Asset, String> {
  @override
  Future<Asset> build(String id) =>
      ref.read(assetsRepositoryProvider).getAsset(id);

  Future<bool> decommission(String reason) async {
    final actionState = state;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(assetsRepositoryProvider).decommissionAsset(arg, reason),
    );
    if (result is AsyncData) {
      state = result;
      return true;
    }
    state = actionState; // restore on failure so caller can surface the error
    return false;
  }

  Future<bool> setLocation(String facilityId, String locationId) async {
    final actionState = state;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(assetsRepositoryProvider).setAssetLocation(
            arg,
            SetAssetLocationRequest(
                facilityId: facilityId, locationId: locationId),
          ),
    );
    if (result is AsyncData) {
      state = result;
      return true;
    }
    state = actionState;
    return false;
  }
}

/// Holds the result of the most recent Register Asset submission.
final registerAssetProvider =
    AsyncNotifierProvider<RegisterAssetNotifier, Asset?>(
  RegisterAssetNotifier.new,
);

class RegisterAssetNotifier extends AsyncNotifier<Asset?> {
  @override
  Future<Asset?> build() async => null;

  Future<bool> submit(RegisterAssetRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(assetsRepositoryProvider).registerAsset(request),
    );
    state = result;
    return result is AsyncData;
  }
}

/// Holds the result of the most recent Update Asset submission.
final updateAssetProvider =
    AsyncNotifierProviderFamily<UpdateAssetNotifier, Asset?, String>(
  UpdateAssetNotifier.new,
);

class UpdateAssetNotifier extends FamilyAsyncNotifier<Asset?, String> {
  @override
  Future<Asset?> build(String id) async => null;

  Future<bool> submit(UpdateAssetRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(assetsRepositoryProvider).updateAsset(arg, request),
    );
    state = result;
    return result is AsyncData;
  }
}
