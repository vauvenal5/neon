import 'package:files_app/l10n/localizations.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/platform.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;

/// Builds the Files actions available for the current multi-selection.
List<NeonMultiSelectAction> buildFilesMultiSelectActions({
  required List<FileDetails> selectedItems,
  required FilesBloc filesBloc,
  required webdav.PathUri destinationUri,
}) {
  final allFiles = selectedItems.every((details) => !details.isDirectory);
  final allFavorites = selectedItems.every((details) => details.isFavorite ?? false);
  final canToggleFavorites = selectedItems.every((details) => details.isFavorite != null);

  return [
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionMove,
      onSelected: (context) => moveFilesAction(context, selectedItems, filesBloc, destinationUri),
    ),
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionCopy,
      onSelected: (context) => copyFilesAction(context, selectedItems, filesBloc, destinationUri),
    ),
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionDelete,
      onSelected: (context) => deleteFilesAction(context, selectedItems, filesBloc),
    ),
    if (allFiles)
      NeonMultiSelectAction(
        label: (context) => FilesLocalizations.of(context).actionDownload,
        onSelected: (context) async {
          final results = <Future<void>>[];
          for (final item in selectedItems) {
            if (item.etag != null) {
              results.add(filesBloc.refetchFile(item.uri, item.etag!));
            }
          }
          await Future.wait(results);
          return NeonMultiSelectActionResult.clearSelection;
        },
      ),
    if (canToggleFavorites)
      NeonMultiSelectAction(
        label: (context) {
          final localizations = FilesLocalizations.of(context);
          return allFavorites ? localizations.removeFromFavorites : localizations.addToFavorites;
        },
        onSelected: (context) => toggleFavoriteFilesAction(context, selectedItems, filesBloc),
      ),
    if (allFiles && NeonPlatform.instance.canUseSharing)
      NeonMultiSelectAction(
        label: (context) => FilesLocalizations.of(context).actionShare,
        onSelected: (context) {
          filesBloc.shareFilesNative(selectedItems);
          return NeonMultiSelectActionResult.clearSelection;
        },
      ),
  ];
}

Future<void> toggleFavoriteFileAction(BuildContext context, FileDetails item, FilesBloc filesBloc) async {
  await toggleFavoriteFilesAction(context, [item], filesBloc);
}

Future<NeonMultiSelectActionResult> toggleFavoriteFilesAction(BuildContext context, List<FileDetails> items, FilesBloc filesBloc) async {
  final remove = items.every((item) => item.isFavorite ?? false);
  for (final item in items) {
    if (remove) {
      filesBloc.removeFavorite(item.uri);
    } else if (item.isFavorite != true) {
      filesBloc.addFavorite(item.uri);
    }
  }
  return NeonMultiSelectActionResult.clearSelection;
}

Future<void> deleteFileAction(BuildContext context, FileDetails item, FilesBloc filesBloc) async {
  await deleteFilesAction(context, [item], filesBloc);
}

Future<NeonMultiSelectActionResult> deleteFilesAction(BuildContext context, List<FileDetails> items, FilesBloc filesBloc) async {
  if (!await showBulkDeleteConfirmationDialog(context, items.length) || !context.mounted) {
    return NeonMultiSelectActionResult.keepSelection;
  }
  for (final item in items) {
    filesBloc.delete(item.uri);
  }
  return NeonMultiSelectActionResult.clearSelection;
}

Future<void> moveFileAction(BuildContext context, FileDetails item, FilesBloc filesBloc) async {
  await moveFilesAction(context, [item], filesBloc, item.uri.parent!);
}

Future<NeonMultiSelectActionResult> moveFilesAction(
    BuildContext context, List<FileDetails> items, FilesBloc filesBloc, webdav.PathUri parentUri) async {
  return targetAction(context, (item, target) => filesBloc.move(item.uri, target), items, filesBloc, parentUri);
}

Future<void> copyFileAction(BuildContext context, FileDetails item, FilesBloc filesBloc) async {
  await copyFilesAction(context, [item], filesBloc, item.uri.parent!);
}

Future<NeonMultiSelectActionResult> copyFilesAction(
    BuildContext context, List<FileDetails> items, FilesBloc filesBloc, webdav.PathUri parentUri) async {
  return targetAction(context, (item, target) => filesBloc.copy(item.uri, target), items, filesBloc, parentUri);
}

Future<NeonMultiSelectActionResult> targetAction(
  BuildContext context,
  void Function(FileDetails, webdav.PathUri) action,
  List<FileDetails> items,
  FilesBloc filesBloc,
  webdav.PathUri parentUri,
) async {
  if (!context.mounted) {
    return NeonMultiSelectActionResult.keepSelection;
  }
  final destination = await showChooseFolderDialog(
    context,
    parentUri: parentUri,
    hideUris: items.where((item) => item.isDirectory).map((item) => item.uri).toSet(),
  );
  if (destination == null || !context.mounted) {
    return NeonMultiSelectActionResult.keepSelection;
  }
  for (final item in items) {
    final target = destination.join(webdav.PathUri.parse(item.name));
    action(item, target);
  }
  return NeonMultiSelectActionResult.clearSelection;
}
