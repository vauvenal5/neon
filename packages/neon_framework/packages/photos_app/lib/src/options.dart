import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neon_framework/settings.dart';
import 'package:neon_framework/storage.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/l10n/localizations.dart';
import 'package:photos_app/src/utils/dialog.dart';

class PhotosOptions extends AppImplementationOptions {
  PhotosOptions(super.storage) {
    super.categories = [
      generalCategory,
      recursionCategory,
    ];
    super.options = [
      cacheImagesOption,
      focusRecursionModeOption,
    ];
  }

  final generalCategory = OptionsCategory(
    name: (context) => PhotosLocalizations.of(context).general,
  );

  final recursionCategory = OptionsCategory(
    // Keep the global Focus preference in its dedicated Photos settings category.
    name: (context) => PhotosLocalizations.of(context).recursion,
  );

  late final cacheImagesOption = ToggleOption(
    storage: super.storage,
    category: generalCategory,
    key: PhotosOptionKeys.cacheImages,
    label: (context) => PhotosLocalizations.of(context).optionsCacheImages,
    defaultValue: true,
  );

  late final focusRecursionModeOption = SelectOption<RecursionMode>(
    storage: super.storage,
    category: recursionCategory,
    key: PhotosOptionKeys.focusRecursionMode,
    label: (context) => PhotosLocalizations.of(context).optionsFocusRecursionMode,
    // Discover only the selected folder until the user explicitly enables recursion.
    defaultValue: RecursionMode.disabled,
    values: recursionModeValues,
  );
}

/// Account-specific Photos settings; each server account has its own home path.
class PhotosAccountOptions extends AppImplementationOptions {
  PhotosAccountOptions(super.storage) : _recursionValue = storage.getBool(PhotosOptionKeys.mainRecursionValue.value) {
    super.categories = [generalCategory];
    // Display both path discovery controls as regular account-specific Photos options.
    super.options = [photosHomePathOption, mainRecursionModeOption];
  }

  bool? _recursionValue;

  bool? get recursion => _recursionValue;

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
    onSelected: _approvePhotosHomePath,
  );

  late final mainRecursionModeOption = SelectOption<RecursionMode>(
    storage: super.storage,
    category: generalCategory,
    key: PhotosOptionKeys.mainRecursionMode,
    label: (context) => PhotosLocalizations.of(context).optionsMainRecursionMode,
    // Account media discovery starts conservatively without scanning subfolders.
    defaultValue: RecursionMode.disabled,
    values: recursionModeValues,
    onSelected: _approveMainRecursionMode,
  );

  Future<bool> _approveMainRecursionMode(BuildContext context, RecursionMode value) async {
    if (value != RecursionMode.ask) {
      return true;
    }

    final recursive = await showRecursionDialog(context);
    if (recursive == null) {
      return false;
    }

    // Resolve Ask for this account before publishing the mode change.
    await rememberRecursion(recursive: recursive);
    return true;
  }

  Future<bool> _approvePhotosHomePath(BuildContext context, webdav.PathUri _) async {
    final mode = mainRecursionModeOption.value;
    if (mode != RecursionMode.ask) {
      return true;
    }

    final recursive = await showRecursionDialog(context);
    if (recursive == null) {
      return false;
    }

    // Persist the account's refreshed decision before publishing the new path.
    await rememberRecursion(recursive: recursive);
    return true;
  }

  Future<void> rememberRecursion({required bool recursive}) async {
    // Update the synchronous view before awaiting persistence so imported Ask state is immediately coherent.
    _recursionValue = recursive;
    await storage.setBool(PhotosOptionKeys.mainRecursionValue.value, recursive);
  }

  Future<void> _clearRecursion() async {
    // Clear the cached and persisted answer together so a partial import cannot reuse stale state.
    _recursionValue = null;
    await storage.remove(PhotosOptionKeys.mainRecursionValue.value);
  }

  @override
  Map<String, Object?> serialize() {
    final values = super.serialize();

    // Export the hidden Ask resolution with the visible account options so Ask remains fully defined.
    if (_recursionValue != null) {
      values[PhotosOptionKeys.mainRecursionValue.value] = _recursionValue;
    }

    return values;
  }

  @override
  void deserialize(Map<String, Object?> values) {
    final recursive = values[PhotosOptionKeys.mainRecursionValue.value];
    if (recursive is bool) {
      // Restore the hidden resolution before visible options notify the Photos view about imported values.
      unawaited(rememberRecursion(recursive: recursive));
    } else if (values.containsKey(PhotosOptionKeys.mainRecursionMode.value) ||
        values.containsKey(PhotosOptionKeys.photosHomePath.value)) {
      unawaited(_clearRecursion());
    }

    super.deserialize(values);
  }

  @override
  void reset() {
    super.reset();
    // Remove the hidden Ask resolution together with the visible account settings.
    unawaited(_clearRecursion());
  }
}

enum PhotosOptionKeys implements Storable {
  photosHomePath._('photosHomePath'),
  cacheImages._('cacheImages'),
  mainRecursionMode._('mainRecursionMode'),
  focusRecursionMode._('focusRecursionMode'),
  mainRecursionValue._('mainRecursionValue');

  const PhotosOptionKeys._(this.value);

  @override
  final String value;
}

enum RecursionMode {
  enabled,
  disabled,
  ask;

  // Keep fixed values internal so callers only need to supply their distinct Ask behavior.
  bool? get _fixedValue => switch (this) {
        enabled => true,
        disabled => false,
        ask => null,
      };

  bool resolve({required bool Function() askAction}) => _fixedValue ?? askAction();

  Future<bool?> resolveAsync({required Future<bool?> Function() askAction}) async => _fixedValue ?? await askAction();
}

final recursionModeValues = <RecursionMode, LabelBuilder>{
  RecursionMode.enabled: (context) => PhotosLocalizations.of(context).recursionModeEnabled,
  RecursionMode.disabled: (context) => PhotosLocalizations.of(context).recursionModeDisabled,
  RecursionMode.ask: (context) => PhotosLocalizations.of(context).recursionModeAsk,
};
