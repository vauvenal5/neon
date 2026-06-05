import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:logging/logging.dart';
import 'package:neon_framework/blocs.dart';
import 'package:queue/queue.dart';
import 'package:cacherine/cacherine.dart';

/// A bloc that manages the decoding of blur hashes into images.
/// It uses a [Queue] to limit the maximum number of concurrent decoding tasks,
/// and a map to cache the results of previously decoded blur hashes so that they can be reused without re-decoding.
///
/// Please note that cache clean up is the responsibility of the caller, as the cache is not automatically cleared.
class BlurBloc extends Bloc {
  final _blurHashCash = SimpleLRUCache<String, BlurHashDecodeTask>(1000);

  @override
  void dispose() {
    _blurHashCash.clear();
  }

  @override
  Logger get log => Logger('BlurBloc');

  /// Gets the decoded image for the given [blurHash] and [size].
  /// If the image is already cached, it returns the cached image.
  /// If the image is not cached, it creates a new [BlurHashDecodeTask] to decode the blur hash, and returns the result of that task.
  BlurHashDecodeTask getBlurHash(String blurHash, ui.Size size) {
    final key = '$blurHash-${size.width}x${size.height}';

    final cachedTask = _blurHashCash.get(key);
    if (cachedTask != null) {
      return cachedTask;
    }

    final task = BlurHashDecodeTask(blurHash: blurHash, size: size);

    // We are offloading the decoding process to the schedular to allow for pre-caching of the blur hashes,
    // and to ensure that the decoding process does not block UI refreshes.
    // Please note that this only works as long as the decoding process is not too heavy,
    // as it could potentially still block the UI if it takes longer then a few milliseconds.
    unawaited(task.execute());

    _blurHashCash.set(key, task);
    return task;
  }
}

/// A task to decode a blur hash into an image. The result is stored in a [Completer] so that it can be awaited by multiple callers.
class BlurHashDecodeTask {
  /// Creates a new [BlurHashDecodeTask] with the given [blurHash] and [size].
  /// The result is stored in a [Completer] so that it can be awaited by multiple callers.
  BlurHashDecodeTask({
    required String blurHash,
    required ui.Size size,
  }) : _blurHashMeta = _BlurHashMeta(
          blurHash: blurHash,
          width: size.width.toInt(),
          height: size.height.toInt(),
        );

  // The blur hash to decode.
  final _BlurHashMeta _blurHashMeta;

  ValueNotifier<ui.Image?> blur = ValueNotifier<ui.Image?>(null);

  // Executes the task by decoding the blur hash into an image and completing the [result] completer with the decoded image.
  Future<void> execute() async {
    // We are using compute to offload the decoding process to a separate isolate,
    // as it can be CPU intensive and we don't want to block the UI thread.
    final pixels = await compute(
      (blurHashMeta) => optimizedBlurHashDecode(
        blurHash: blurHashMeta.blurHash,
        width: blurHashMeta.width,
        height: blurHashMeta.height,
      ),
      _blurHashMeta,
    );

    // We are using the schedular to decode the image just to be on the safe side.
    await SchedulerBinding.instance.scheduleTask(
      () => ui.decodeImageFromPixels(
        pixels,
        _blurHashMeta.width,
        _blurHashMeta.height,
        ui.PixelFormat.rgba8888,
        (image) => blur.value = image,
      ),
      Priority.animation,
    );
  }
}

class _BlurHashMeta {
  _BlurHashMeta({
    required this.blurHash,
    required this.width,
    required this.height,
  });

  // The blur hash to decode.
  final String blurHash;

  // The width of the resulting image.
  final int width;

  // The height of the resulting image.
  final int height;
}
