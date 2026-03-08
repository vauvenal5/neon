/// Export all the public APIs of the files app package.
/// The photos app is heavily dependant on the files app.
/// The photos app basically does not work without files and needs a lot of the same functionality.
library;

export 'package:files_app/src/blocs/browser.dart';
export 'package:files_app/src/blocs/files.dart';
export 'package:files_app/src/models/file_details.dart';
export 'package:files_app/src/options.dart';
export 'package:files_app/src/sort/files.dart';
export 'package:files_app/src/utils/dialog.dart' show showDownloadConfirmationDialog;
export 'package:files_app/src/widgets/actions.dart';
export 'package:files_app/src/widgets/file_preview.dart';