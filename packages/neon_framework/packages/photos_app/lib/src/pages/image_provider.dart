import 'dart:ui' as ui show Codec, ImmutableBuffer;

import 'package:files_app/files_lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/image_key.dart';

class NeonImageProvider extends ImageProvider<ImageKey> {
  NeonImageProvider({required this.file, required this.bloc, required this.options, required this.key});

  final webdav.WebDavFile file;
  final FilesBloc bloc;
  final PhotosOptions options;
  final ImageKey key;

  @override
  Future<ImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ImageKey>(key);
  }

  @override
  @protected
  ImageStreamCompleter loadImage(ImageKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
      debugLabel: file.path.toString(),
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
      chunkEvents: _chunkEvents(),
    );
  }

  Future<ui.Codec> _loadAsync(ImageDecoderCallback decode) async {
    final data = await bloc.fetchFile(
      file.path,
      file.etag!,
      cache: options.cacheImagesOption.value,
    );
    return decode(await ui.ImmutableBuffer.fromUint8List(data));
  }

  Stream<ImageChunkEvent> _chunkEvents() {
    final task = bloc.getDownloadTask(file.path);
    if (task == null) {
      return bloc.downloadTasks
          .where((task) => task != null && task.uri == file.path)
          .asyncExpand((task) => task!.progress.map(_toChunkEvent));
    }

    return task.progress.map(_toChunkEvent);
  }

  ImageChunkEvent _toChunkEvent(double progress) => ImageChunkEvent(
    cumulativeBytesLoaded: (progress * 100).toInt(),
    expectedTotalBytes: 100,
  );
}