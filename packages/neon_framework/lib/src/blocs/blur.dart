import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:logging/logging.dart';
import 'package:neon_framework/blocs.dart';
import 'package:queue/queue.dart';

class BlurBloc extends Bloc {
  final blurHashQueue = Queue(parallel: 10);
  final blurHashTasks = <String, BlurHashDecodeTask>{};

  @override
  void dispose() {
    blurHashQueue.dispose();
  }

  @override
  Logger get log => Logger('PreviewBloc');

  Future<ui.Image>? getBlurHash(String? blurHash, ui.Size size, {bool cache = true}) {
    if (blurHash == null) {
      return null;
    }

    final task = BlurHashDecodeTask(blurHash: blurHash, size: size);

    if (blurHashTasks[task.key] != null) {
      return blurHashTasks[task.key]!.result.future;
    }

    unawaited(SchedulerBinding.instance.scheduleTask(task.execute, Priority.animation));
    if(cache) {
      blurHashTasks[task.key] = task;
    }
    return task.result.future;
  }

  void remove(String? blurHash, ui.Size size) {
    if (blurHash == null) {
      return;
    }

    final task = BlurHashDecodeTask(blurHash: blurHash, size: size);
    if (blurHashTasks[task.key] != null) {
      blurHashTasks.remove(task.key);
    }
  }
}

class BlurHashDecodeTask {
  BlurHashDecodeTask({
    required this.blurHash,
    required this.size,
  });

  final String blurHash;
  final ui.Size size;
  Completer<ui.Image> result = Completer();

  Future<void> execute() async {
    result.complete(
      blurHashDecodeImage(
        blurHash: blurHash,
        width: size.width.toInt(),
        height: size.height.toInt(),
      ),
    );
  }

  String get key => '$blurHash-${size.width}x${size.height}';
}
