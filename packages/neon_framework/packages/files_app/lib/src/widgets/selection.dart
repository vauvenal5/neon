import 'package:files_app/l10n/localizations.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/utils/dialog.dart';
import 'package:flutter/material.dart';
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
      onSelected: (context) => _applyFilesAction(
        context,
        _BulkFileAction.move,
        selectedItems,
        filesBloc,
        destinationUri,
      ),
    ),
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionCopy,
      onSelected: (context) => _applyFilesAction(
        context,
        _BulkFileAction.copy,
        selectedItems,
        filesBloc,
        destinationUri,
      ),
    ),
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionDelete,
      onSelected: (context) => _applyFilesAction(
        context,
        _BulkFileAction.delete,
        selectedItems,
        filesBloc,
        destinationUri,
      ),
    ),
    if (allFiles)
      NeonMultiSelectAction(
        label: (context) => FilesLocalizations.of(context).actionDownload,
        onSelected: (context) => _applyFilesAction(
          context,
          _BulkFileAction.download,
          selectedItems,
          filesBloc,
          destinationUri,
        ),
      ),
    if (canToggleFavorites)
      NeonMultiSelectAction(
        label: (context) {
          final localizations = FilesLocalizations.of(context);
          return allFavorites ? localizations.removeFromFavorites : localizations.addToFavorites;
        },
        onSelected: (context) => _applyFilesAction(
          context,
          _BulkFileAction.favorite,
          selectedItems,
          filesBloc,
          destinationUri,
        ),
      ),
    NeonMultiSelectAction(
      label: (context) => FilesLocalizations.of(context).actionShare,
      onSelected: (context) => _applyFilesAction(
        context,
        _BulkFileAction.share,
        selectedItems,
        filesBloc,
        destinationUri,
      ),
    ),
  ];
}

Future<NeonMultiSelectActionResult> _applyFilesAction(
  BuildContext context,
  _BulkFileAction action,
  List<FileDetails> items,
  FilesBloc filesBloc,
  webdav.PathUri destinationUri,
) async {
  switch (action) {
    case _BulkFileAction.move:
    case _BulkFileAction.copy:
      final destination = await showChooseFolderForSelectionDialog(
        context,
        uri: destinationUri,
        hideUris: items.where((item) => item.isDirectory).map((item) => item.uri).toSet(),
      );
      if (destination == null || !context.mounted) {
        return NeonMultiSelectActionResult.keepSelection;
      }
      for (final item in items) {
        final target = destination.join(webdav.PathUri.parse(item.name));
        if (action == _BulkFileAction.move) {
          filesBloc.move(item.uri, target);
        } else {
          filesBloc.copy(item.uri, target);
        }
      }
    case _BulkFileAction.delete:
      if (!await showBulkDeleteConfirmationDialog(context, items.length) || !context.mounted) {
        return NeonMultiSelectActionResult.keepSelection;
      }
      for (final item in items) {
        filesBloc.delete(item.uri);
      }
    case _BulkFileAction.download:
      final results = <Future<void>>[];
      for (final item in items) {
        if (item.etag != null) {
          results.add(filesBloc.refetchFile(item.uri, item.etag!));
        }
      }
      await Future.wait(results);
    case _BulkFileAction.favorite:
      final remove = items.every((item) => item.isFavorite ?? false);
      for (final item in items) {
        if (remove) {
          filesBloc.removeFavorite(item.uri);
        } else if (item.isFavorite != true) {
          filesBloc.addFavorite(item.uri);
        }
      }
    case _BulkFileAction.share:

  }

  return NeonMultiSelectActionResult.clearSelection;
}

Future<NeonMultiSelectActionResult> moveFileAction(
  BuildContext context,
  FileDetails item,
  FilesBloc filesBloc,
) async {
  return moveFilesAction(context, [item], filesBloc, item.uri.parent!);
}

Future<NeonMultiSelectActionResult> moveFilesAction(
  BuildContext context,
  List<FileDetails> items,
  FilesBloc filesBloc,
  webdav.PathUri parentUri,
) async {
  if (!context.mounted) {
    return NeonMultiSelectActionResult.keepSelection;
  }
  final destination = await showChooseFolderForSelectionDialog(
    context,
    uri: parentUri,
    hideUris: items.where((item) => item.isDirectory).map((item) => item.uri).toSet(),
  );
  if (destination == null || !context.mounted) {
    return NeonMultiSelectActionResult.keepSelection;
  }
  for (final item in items) {
    final target = destination.join(webdav.PathUri.parse(item.name));
    filesBloc.move(item.uri, target);
  }
  return NeonMultiSelectActionResult.clearSelection;
}

enum _BulkFileAction { move, copy, delete, download, favorite, share }
