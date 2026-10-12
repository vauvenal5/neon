import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/models/file_details.dart';
import 'package:files_app/src/utils/task.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/theme.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/core.dart' as core;

class FilePreview extends StatelessWidget {
  const FilePreview({
    required this.bloc,
    required this.details,
    this.size = const Size.square(largeIconSize),
    this.color,
    super.key,
  });

  final FilesBloc bloc;
  final FileDetails details;
  final Size size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget icon = Center(
      child: StreamBuilder(
        stream: bloc.downloadTasks.where((task) => task != null && task.uri == details.uri),
        initialData: bloc.getTask(details.uri),
        builder: (context, task) {
          return task.hasData ? _buildProgressIndicator(context, task.data!) : _buildPreview(context);
        },
      ),
    );

    if (details.isFavorite ?? false) {
      icon = Stack(
        children: [
          icon,
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              AdaptiveIcons.star,
              color: Colors.yellow,
            ),
          ),
        ],
      );
    }

    return SizedBox.fromSize(
      size: size,
      child: icon,
    );
  }

  Widget _buildPreview(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;

    Widget child;
    if (details.isDirectory) {
      child = Icon(
        AdaptiveIcons.folder,
        color: color,
        size: size.shortestSide,
      );
    } else {
      child = FilePreviewImage(
        file: details,
        size: size,
        account: NeonProvider.of<Account>(context),
      );
    }

    return child;
  }

  Widget _buildProgressIndicator(BuildContext context, FilesTask task) {
    return StreamBuilder(
      stream: task.progress,
      builder: (context, progress) => progress.hasData && progress.data == 1.0
          ? _buildPreview(context)
          : NeonCircularProgressIndicator(
              iconData: switch (task) {
                FilesUploadTask() => Icons.upload,
                FilesRefetchTask() => Icons.refresh,
                FilesDownloadTask() => Icons.download,
              },
              progress: progress.data,
            ),
    );
  }
}

class FilePreviewImage extends NeonApiImage {
  factory FilePreviewImage({
    required FileDetails file,
    required Size size,
    required Account account,
  }) {
    final width = size.width.toInt();
    final height = size.height.toInt();

    return FilePreviewImage._(
      file: file,
      size: size,
      width: width,
      height: height,
      account: account,
    );
  }

  FilePreviewImage._({
    required FileDetails file,
    required Size super.size,
    required int width,
    required int height,
    required super.account,
  }) : super(
          getRequest: (client) => client.core.preview.$getPreview_Request(
            file: file.uri.path,
            x: width,
            y: height,
            mimeFallback: core.PreviewGetPreviewMimeFallback.$1,
          ),
          etag: file.etag,
          expires: null,
          isSvgHint: file.mimeType?.contains('svg') ?? false,
          blurHash: file.blurHash,
        );
}
