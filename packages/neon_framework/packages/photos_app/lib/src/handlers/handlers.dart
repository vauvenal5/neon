import 'package:flutter/material.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/utils.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/album.dart';
import 'package:photos_app/src/pages/image.dart';
import 'package:photos_app/src/utils/dialog.dart';

class ImageHandler extends AppCapabilityHandler {
  ImageHandler();

  @override
  bool canHandle(AppCapability capability) => capability is ImageViewerCapability;

  @override
  Future<C> handle<C extends AppCapability>(BuildContext context, C capability) async {
    if (capability is ImageViewerCapability) {
      await Navigator.of(context).push(_pageRoute(context, capability));
    }
    return capability;
  }

  MaterialPageRoute<void> _pageRoute(BuildContext context, ImageViewerCapability mime) {
    return MaterialPageRoute<void>(
      builder: (context) => ImagePage(
        sorted: mime.files ?? [mime.file],
        file: mime.file,
      ),
    );
  }
}

class AlbumHandler extends AppCapabilityHandler {
  AlbumHandler();

  @override
  bool canHandle(AppCapability capability) => capability is AlbumViewerCapability;

  @override
  Future<C> handle<C extends AppCapability>(BuildContext context, C capability) async {
    if (capability is AlbumViewerCapability) {
      final mode = NeonProvider.of<PhotosOptions>(context).focusRecursionModeOption.value;
      // Pass the dialog as a lazy Ask action so fixed modes do not open it.
      final recursive = await mode.resolveAsync(
        askAction: () => showRecursionDialog(context),
      );

      // Dismissing Ask cancels the Focus action without changing its configured mode.
      if (recursive != null && context.mounted) {
        await Navigator.of(context).push(_pageRoute(context, capability, recursive));
      }
    }
    return capability;
  }

  MaterialPageRoute<void> _pageRoute(
    BuildContext context,
    AlbumViewerCapability capability,
    bool recursive,
  ) {
    return MaterialPageRoute<void>(
      builder: (context) => AlbumPage(
        uri: capability.pathUri,
        recursive: recursive,
      ),
    );
  }
}
