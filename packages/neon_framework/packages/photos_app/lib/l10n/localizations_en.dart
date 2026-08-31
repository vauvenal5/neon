// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PhotosLocalizationsEn extends PhotosLocalizations {
  PhotosLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get general => 'General';

  @override
  String get recursion => 'Photo Discovery';

  @override
  String get optionsPhotosHomePath => 'Media Folder';

  @override
  String get optionsCacheImages => 'Cache Images';

  @override
  String get optionsMainRecursionMode => 'Media Folder Scanning';

  @override
  String get optionsFocusRecursionMode => 'Focus View Scanning';

  @override
  String get recursionModeEnabled => 'Scan subfolder contents.';

  @override
  String get recursionModeDisabled => 'Scan selected folder only.';

  @override
  String get recursionModeAsk => 'Ask every time.';

  @override
  String get recursionDialogTitle => 'Show photos from subfolders?';

  @override
  String get recursionDialogContent =>
      'All subfolders will be scanned and discovered photos will also be shown.';
}
