import 'dart:io';

import 'package:files_app/l10n/localizations.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/pages/details.dart';
import 'package:files_app/src/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/platform.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;

class FileActions extends StatelessWidget {
  const FileActions({required this.details, super.key});

  final FileDetails details;

  @override
  Widget build(BuildContext context) {
    final filesBloc = NeonProvider.of<FilesBloc>(context);
    final parentUri = details.uri.parent ?? details.uri;
    final actions = [
      ...buildFilesActions(selectedItems: [details], filesBloc: filesBloc, parentUri: parentUri),
      AttachFileAction(items: [details], filesBloc: filesBloc),
      DetailsFileAction(items: [details], filesBloc: filesBloc),
      FocusFileAction(items: [details], filesBloc: filesBloc),
      RenameFileAction(items: [details], filesBloc: filesBloc),
    ];

    return NeonPopupMenuButton(
      actions: actions,
      onSelected: (action) async {
        await action.onSelected(context);
      },
    );
  }
}

/// Creates the common operations so every menu uses the same actions and eligibility rules.
List<FilesAppAction> buildFilesActions({
  required List<FileDetails> selectedItems,
  required FilesBloc filesBloc,
  required webdav.PathUri parentUri,
}) =>
    [
      MoveFilesAction(items: selectedItems, filesBloc: filesBloc, parentUri: parentUri),
      CopyFilesAction(items: selectedItems, filesBloc: filesBloc, parentUri: parentUri),
      DeleteFilesAction(items: selectedItems, filesBloc: filesBloc),
      DownloadFilesAction(items: selectedItems, filesBloc: filesBloc),
      ToggleFavoriteFilesAction(items: selectedItems, filesBloc: filesBloc),
      ShareFilesAction(items: selectedItems, filesBloc: filesBloc),
    ];

/// Adds Files-specific selection data to the framework's reusable action contract.
abstract class FilesAppAction extends FilesAction {
  const FilesAppAction({required this.items, required this.filesBloc}) : super();

  final List<FileDetails> items;
  final FilesBloc filesBloc;

  bool get hasItems => items.isNotEmpty;

  bool get hasSingleItem => items.length == 1;

  bool get allItemsAreFiles => hasItems && items.every((item) => !item.isDirectory);

  bool get allItemsHaveFavoriteState => hasItems && items.every((item) => item.isFavorite != null);

  bool get canShareItems => allItemsAreFiles && NeonPlatform.instance.canUseSharing;

  @override
  String label(BuildContext context);

  @override
  bool mayRender() => hasItems;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context);
}

/// Adds the shared destination picker for operations that move or copy selected items.
abstract class TargetDirFilesAction extends FilesAppAction {
  const TargetDirFilesAction({required super.items, required super.filesBloc, required this.parentUri});

  final webdav.PathUri parentUri;

  /// Shares the destination picker while each operation defines its own file change.
  Future<NeonMultiSelectActionResult> performTargetAction(
    BuildContext context,
    void Function(FileDetails, webdav.PathUri) action,
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
      action(item, destination.join(webdav.PathUri.parse(item.name)));
    }
    return NeonMultiSelectActionResult.clearSelection;
  }
}

/// Provides safe access to the single item required by item-specific actions.
abstract class SingleItemFilesAction extends FilesAppAction {
  const SingleItemFilesAction({required super.items, required super.filesBloc});

  FileDetails get item => items.single;

  @override
  bool mayRender() => hasSingleItem;
}

/// Owns the move operation and its file-versus-folder eligibility rule.
class MoveFilesAction extends TargetDirFilesAction {
  const MoveFilesAction({required super.items, required super.filesBloc, required super.parentUri});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionMove;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) =>
      performTargetAction(context, (item, target) => filesBloc.move(item.uri, target));
}

/// Owns the copy operation and its localized menu label.
class CopyFilesAction extends TargetDirFilesAction {
  const CopyFilesAction({required super.items, required super.filesBloc, required super.parentUri});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionCopy;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) =>
      performTargetAction(context, (item, target) => filesBloc.copy(item.uri, target));
}

/// Owns deletion confirmation and deletion for every selected item.
class DeleteFilesAction extends FilesAppAction {
  const DeleteFilesAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionDelete;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    if (!await showBulkDeleteConfirmationDialog(context, items.length) || !context.mounted) {
      return NeonMultiSelectActionResult.keepSelection;
    }
    for (final item in items) {
      filesBloc.delete(item.uri);
    }
    return NeonMultiSelectActionResult.clearSelection;
  }
}

/// Owns downloading and only appears when every selected item is a file.
class DownloadFilesAction extends FilesAppAction {
  const DownloadFilesAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionDownload;

  @override
  bool mayRender() => allItemsAreFiles;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    await Future.wait([
      for (final item in items)
        if (item.etag != null) filesBloc.refetchFile(item.uri, item.etag!),
    ]);
    return NeonMultiSelectActionResult.clearSelection;
  }
}

/// Owns the favorite toggle and its selection-wide label and eligibility rule.
class ToggleFavoriteFilesAction extends FilesAppAction {
  const ToggleFavoriteFilesAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) {
    final allFavorites = items.every((item) => item.isFavorite ?? false);
    final localizations = FilesLocalizations.of(context);
    return allFavorites ? localizations.removeFromFavorites : localizations.addToFavorites;
  }

  @override
  bool mayRender() => allItemsHaveFavoriteState;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
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
}

/// Owns native sharing and only appears when sharing is supported for all selected files.
class ShareFilesAction extends FilesAppAction {
  const ShareFilesAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionShare;

  @override
  bool mayRender() => canShareItems;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    filesBloc.shareFilesNative(items);
    return NeonMultiSelectActionResult.clearSelection;
  }
}

/// Adds native attachment handling to the shared action contract.
class AttachFileAction extends SingleItemFilesAction {
  const AttachFileAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionAttach;

  @override
  bool mayRender() => super.mayRender() && canShareItems && Platform.isAndroid;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    filesBloc.attachFileNative(item.uri, item.etag!);
    return NeonMultiSelectActionResult.clearSelection;
  }
}

/// Adds the details page as a reusable single-item action.
class DetailsFileAction extends SingleItemFilesAction {
  const DetailsFileAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).details;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FilesDetailsPage(bloc: filesBloc, details: item),
      ),
    );
    return NeonMultiSelectActionResult.keepSelection;
  }
}

/// Opens the album viewer for a selected directory.
class FocusFileAction extends SingleItemFilesAction {
  const FocusFileAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => 'Focus';

  @override
  bool mayRender() => super.mayRender() && item.isDirectory;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    await NeonProvider.of<AppsBloc>(context).handleAppCapability(context, AlbumViewerCapability(item.uri));
    return NeonMultiSelectActionResult.keepSelection;
  }
}

/// Owns the rename dialog and selects the file or folder prompt from the item type.
class RenameFileAction extends SingleItemFilesAction {
  const RenameFileAction({required super.items, required super.filesBloc});

  @override
  String label(BuildContext context) => FilesLocalizations.of(context).actionRename;

  @override
  Future<NeonMultiSelectActionResult> onSelected(BuildContext context) async {
    if (!context.mounted) {
      return NeonMultiSelectActionResult.keepSelection;
    }
    final result = await showRenameDialog(
      context: context,
      title: item.isDirectory ? FilesLocalizations.of(context).folderRename : FilesLocalizations.of(context).fileRename,
      initialValue: item.name,
    );
    if (result != null) {
      filesBloc.rename(item.uri, result);
      return NeonMultiSelectActionResult.clearSelection;
    }
    return NeonMultiSelectActionResult.keepSelection;
  }
}
