import 'package:files_app/src/blocs/browser.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/options.dart';
import 'package:files_app/src/utils/dialog.dart';
import 'package:files_app/src/utils/task.dart';
import 'package:files_app/src/widgets/actions.dart';
import 'package:files_app/src/widgets/file_preview.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:neon_framework/theme.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;

class FileListTile extends StatelessWidget {
  const FileListTile({
    required this.bloc,
    required this.browserBloc,
    required this.details,
    required this.setPath,
    this.checkOpenInNeon,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelect,
    super.key,
  });

  final FilesBloc bloc;
  final FilesBrowserBloc browserBloc;
  final FileDetails details;
  final void Function(webdav.PathUri uri) setPath;
  final Future<bool> Function()? checkOpenInNeon;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  Future<void> _onTap(BuildContext context, FileDetails details) async {
    if (details.isDirectory) {
      setPath(details.uri);
    } else if (browserBloc.mode == FilesBrowserMode.browser) {
      final sizeWarning = NeonProvider.of<FilesOptions>(context).downloadSizeWarning.value;
      if (sizeWarning != null && details.size != null && details.size! > sizeWarning) {
        final decision = await showDownloadConfirmationDialog(context, sizeWarning, details.size!);

        if (!decision) {
          return;
        }
      }

      // if we can not handle the file type in neon, we open externally
      if (!(await checkOpenInNeon?.call() ?? false)) {
        bloc.openFile(details.uri, details.etag!, details.mimeType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // When the ETag is null it means we are uploading this file right now
      selected: selectionMode && isSelected,
      selectedColor: Theme.of(context).colorScheme.onPrimary,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
      onTap: selectionMode
          ? onSelect
          : (details.isDirectory || details.etag != null ? () async => _onTap(context, details) : null),
      onLongPress: onSelect,
      title: Text(
        details.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (details.lastModified != null)
            RelativeTime(
              date: details.lastModified!,
            ),
          if (details.size != null && details.size! > 0) ...[
            const SizedBox(
              width: 10,
            ),
            Text(
              filesize(details.size, 1),
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ],
      ),
      leading: FilePreview(
        details: details,
        bloc: bloc,
      ),
      trailing: selectionMode
          ? Checkbox(value: isSelected, shape: const CircleBorder(), onChanged: onSelect == null ? null : (_) => onSelect!())
          : StreamBuilder(
              stream: bloc.downloadTasks.where((task) => task != null && task.uri == details.uri),
              initialData: bloc.getTask(details.uri),
              builder: _buildTrailing,
            ),
    );
  }

  Widget _buildTrailing(BuildContext context, AsyncSnapshot<FilesTask?> task) {
    const empty = SizedBox.square(dimension: largeIconSize);

    if (FilesBrowserMode.browser == browserBloc.mode) {
      if (task.hasData) {
        return StreamBuilder(
          stream: task.data!.progress,
          builder: (context, progress) => progress.hasData && progress.data == 1.0
              ? FileActions(
                  details: details,
                )
              : empty,
        );
      }

      return FileActions(
        details: details,
      );
    }

    return empty;
  }
}
