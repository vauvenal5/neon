import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:files_app/src/blocs/browser.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/options.dart';
import 'package:files_app/src/sort/files.dart';
import 'package:files_app/src/utils/task.dart';
import 'package:files_app/src/widgets/file_list_tile.dart';
import 'package:files_app/src/widgets/navigator.dart';
import 'package:files_app/src/widgets/selection.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/sort_box.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;

class FilesBrowserView extends StatefulWidget {
  FilesBrowserView({
    required this.filesBloc,
    required this.uri,
    required this.mode,
    required this.setPath,
    this.hideUri,
    this.hideUris = const {},
  }) : super(key: Key(uri.toString()));

  final FilesBloc filesBloc;
  final webdav.PathUri uri;
  final FilesBrowserMode mode;
  final void Function(webdav.PathUri uri) setPath;
  final webdav.PathUri? hideUri;
  final Set<webdav.PathUri> hideUris;

  @override
  State<FilesBrowserView> createState() => _FilesBrowserViewState();
}

class _FilesBrowserViewState extends State<FilesBrowserView> {
  late final FilesOptions options;
  late final FilesBrowserBloc bloc;
  late final StreamSubscription<Object> errorsSubscription;
  late final NeonAppBarController? appBarController;
  late final NeonMultiSelectController<FileDetails>? selection;

  @override
  void initState() {
    options = NeonProvider.of<FilesOptions>(context);
    if (widget.mode == FilesBrowserMode.browser) {
      appBarController = NeonProvider.of<NeonAppBarController>(context);
      selection = NeonMultiSelectController<FileDetails>(
        keyOf: (details) => details.uri,
        actionsBuilder: (selectedItems) => buildFilesMultiSelectActions(
          selectedItems: selectedItems,
          filesBloc: widget.filesBloc,
          destinationUri: widget.uri,
        ),
      )..addListener(_onSelectionChanged);
      appBarController?.registerSelectionSession(ObjectKey(this), selection!);
    } else {
      appBarController = null;
      selection = null;
    }

    bloc = FilesBrowserBloc(
      filesBloc: widget.filesBloc,
      options: options,
      account: NeonProvider.of<Account>(context),
      uri: widget.uri,
      mode: widget.mode,
      hideUri: widget.hideUri,
      hideUris: widget.hideUris,
      mimeFilter: options.appConfigMimeFilter,
    );

    errorsSubscription = bloc.errors.listen((error) {
      if (mounted) {
        NeonError.showSnackbar(context, error);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    appBarController?.clearSelectionSession(ObjectKey(this));
    selection
      ?..removeListener(_onSelectionChanged)
      ..dispose();
    unawaited(errorsSubscription.cancel());
    bloc.dispose();

    super.dispose();
  }

  bool get _isSelectionMode => widget.mode == FilesBrowserMode.browser && selection!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ResultBuilder.behaviorSubject(
      subject: bloc.files,
      builder: (context, filesSnapshot) => StreamBuilder(
        stream: widget.filesBloc.uploadTasks,
        builder: (context, tasksSnapshot) => SortBoxBuilder(
          sortBox: filesSortBox,
          sortProperty: options.filesSortPropertyOption,
          sortBoxOrder: options.filesSortBoxOrderOption,
          presort: const {
            (property: FilesSortProperty.isFolder, order: SortBoxOrder.ascending),
          },
          input: filesSnapshot.data?.toList(),
          builder: (context, sorted) {
            final uploadingTaskTiles =
                tasksSnapshot.hasData ? buildUploadTasks(tasksSnapshot.requireData, sorted) : null;

            return NeonListView(
              scrollKey: 'files-${widget.uri.path}',
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final file = sorted[index];

                final details = FileDetails.fromWebDav(file: file);
                return FileListTile(
                  key: ValueKey(file.etag!),
                  bloc: widget.filesBloc,
                  browserBloc: bloc,
                  details: details,
                  setPath: widget.setPath,
                  checkOpenInNeon: () => handleFileInNeon(sorted, file),
                  selectionMode: _isSelectionMode,
                  isSelected: selection?.isSelected(details) ?? false,
                  onSelect: widget.mode == FilesBrowserMode.browser ? () => selection!.toggle(details) : null,
                );
              },
              isLoading: filesSnapshot.isLoading,
              error: filesSnapshot.error,
              onRefresh: bloc.refresh,
              topScrollingChildren: [
                if (widget.mode != FilesBrowserMode.browser || selection!.isEmpty)
                  FilesBrowserNavigator(
                    uri: widget.uri,
                    bloc: widget.filesBloc,
                    setPath: widget.setPath,
                  ),
                ...?uploadingTaskTiles,
              ],
            );
          },
        ),
      ),
    );
  }

  void clearSelection() {
    selection?.clear();
  }

  void _onSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> handleFileInNeon(List<webdav.WebDavFile> sorted, webdav.WebDavFile file) async {
    final capability = NeonProvider.of<AppsBloc>(context)
        .handleAppCapability(context, ImageViewerCapability.fromFile(file: file, files: sorted));
    // If capability is null, either the file is not an image, or ther is no handler for the capability.
    // In both cases we should return false to allow the default behavior of opening the file in Neon.
    if (capability != null) {
      await capability;
      return true;
    }
    return false;
  }

  Iterable<Widget> buildUploadTasks(BuiltList<FilesUploadTask> tasks, List<webdav.WebDavFile> files) sync* {
    for (final task in tasks) {
      // in case of long uploads, user could navigate to another folder
      if (task.uri.parent != widget.uri) {
        continue;
      }

      yield FileListTile(
        bloc: widget.filesBloc,
        browserBloc: bloc,
        details: FileDetails.fromUploadTask(
          task: task,
        ),
        setPath: widget.setPath,
      );
    }
  }
}
