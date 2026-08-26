import 'package:neon_framework/settings.dart';
import 'package:neon_framework/storage.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/l10n/localizations.dart';

class PhotosOptions extends AppImplementationOptions {
  PhotosOptions(super.storage) {
    super.categories = [
      generalCategory,
    ];
    super.options = [
      cacheImagesOption,
    ];
  }

  final generalCategory = OptionsCategory(
    name: (context) => PhotosLocalizations.of(context).general,
  );

  late final cacheImagesOption = ToggleOption(
    storage: super.storage,
    category: generalCategory,
    key: PhotosOptionKeys.cacheImages,
    label: (context) => PhotosLocalizations.of(context).optionsCacheImages,
    defaultValue: true,
  );
}

/// Account-specific Photos settings; each server account has its own home path.
class PhotosAccountOptions extends AppImplementationOptions {
  PhotosAccountOptions(super.storage) {
    super.categories = [generalCategory];
    super.options = [photosHomePathOption];
  }

  final generalCategory = OptionsCategory(
    name: (context) => PhotosLocalizations.of(context).general,
  );

  late final photosHomePathOption = PathUriOption(
    storage: super.storage,
    category: generalCategory,
    key: PhotosOptionKeys.photosHomePath,
    label: (context) => PhotosLocalizations.of(context).optionsPhotosHomePath,
    // Keep the account default independent from any path saved for another account.
    defaultValue: webdav.PathUri.cwd(),
  );
}

enum PhotosOptionKeys implements Storable {
  photosHomePath._('photosHomePath'),
  cacheImages._('cacheImages');

  const PhotosOptionKeys._(this.value);

  @override
  final String value;
}
