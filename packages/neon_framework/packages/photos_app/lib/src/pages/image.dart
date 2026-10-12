import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:files_app/files_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:logging/logging.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/theme.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photos_app/src/models/timeline.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/image_key.dart';
import 'package:photos_app/src/pages/image_provider.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({
    required this.initialFiles,
    required this.file,
    this.filesStream,
    this.sortFiles,
    super.key,
  });

  final List<webdav.WebDavFile> initialFiles;
  final webdav.WebDavFile file;
  final Stream<Result<BuiltList<webdav.WebDavFile>>>? filesStream;
  final ImageViewerFileSorter? sortFiles;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late PageController pageController;
  var _showAppBar = true;
  late StreamSubscription<FilesRefetchTask?> _subscription;
  late ImageKey _imageKey;
  late webdav.PathUri _currentUri;
  var _pageSyncScheduled = false;

  final log = Logger('ImagePageState');

  @override
  void initState() {
    super.initState();

    // Use the caller's live listing when available; otherwise show the supplied snapshot.
    final initialFiles = PhotoTimeline.fromFiles(widget.initialFiles).images;
    final filesBloc = NeonProvider.of<FilesBloc>(context);
    final initialIndex = initialFiles.indexWhere((file) => file.path == widget.file.path);
    _currentUri = widget.file.path;
    _imageKey = ImageKey(etag: widget.file.etag ?? '', index: initialIndex < 0 ? 0 : initialIndex);

    pageController = PageController(initialPage: _imageKey.index);
    _subscription = filesBloc.refetchTasks.listen((task) async {
      if (_currentUri == task?.uri) {
        log.fine('Incrementing refetch index for $_currentUri');
        setState(() {
          _imageKey = _imageKey.refetchKey();
        });
      }
    });
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values));
    unawaited(_subscription.cancel());
    super.dispose();
  }

  void _onPageChanged(int index, List<webdav.WebDavFile> files) {
    setState(() {
      _currentUri = files[index].path;
      _imageKey = ImageKey(etag: files[index].etag!, index: index);
    });
  }

  void _syncPageController(int index, webdav.WebDavFile file) {
    final currentPage = pageController.hasClients ? pageController.page?.round() : null;
    final keyChanged = _imageKey.etag != file.etag || _imageKey.index != index;
    if (_pageSyncScheduled || (!keyChanged && currentPage == index)) {
      return;
    }

    _pageSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageSyncScheduled = false;
      if (!mounted) {
        return;
      }
      if (keyChanged) {
        setState(() {
          _currentUri = file.path;
          _imageKey = ImageKey(etag: file.etag!, index: index);
        });
      }
      if (pageController.hasClients && pageController.page?.round() != index) {
        pageController.jumpToPage(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = NeonProvider.of<FilesBloc>(context);
    final options = NeonProvider.of<PhotosOptions>(context);
    return ResultBuilder<BuiltList<webdav.WebDavFile>>(
      stream: widget.filesStream,
      initialData: Result<BuiltList<webdav.WebDavFile>>.success(BuiltList<webdav.WebDavFile>.from(widget.initialFiles)),
      builder: (context, filesSnapshot) {
        final imageFiles = (filesSnapshot.data ?? widget.initialFiles)
            .where((file) => file.etag != null && (file.mimeType?.startsWith(ImageViewerCapability.allImages) ?? false))
            .toList();
        final files = widget.sortFiles?.call(imageFiles) ?? PhotoTimeline.fromFiles(imageFiles).images;
        if (files.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('No images found')),
            body: const Center(child: Icon(Icons.image_not_supported_outlined, size: largeIconSize)),
          );
        }
        // Keep the current image by etag, or stay near its previous position if it disappeared.
        final foundIndex = files.indexWhere((file) => file.etag == _imageKey.etag);
        final index = foundIndex >= 0 ? foundIndex : _imageKey.index.clamp(0, files.length - 1).toInt();
        final currentFile = files[index];
        _syncPageController(index, currentFile);
        final imageKey = _imageKey.etag == currentFile.etag && _imageKey.index == index
            ? _imageKey
            : ImageKey(etag: currentFile.etag!, index: index);
        final details = FileDetails.fromWebDav(file: currentFile);

        return Scaffold(
          appBar: _showAppBar
              ? AppBar(
                  title: Text(currentFile.name),
                  actions: widget.filesStream == null
                      ? null
                      : [
                          FavoriteIconButton(bloc: bloc, details: details),
                          FileActions(details: details),
                        ],
                )
              : null,
          body: GestureDetector(
            onTap: () {
              setState(() {
                _showAppBar = !_showAppBar;
                _showAppBar
                    ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values)
                    : SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              });
            },
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.arrowRight): navigateRight,
                const SingleActivator(LogicalKeyboardKey.pageDown): navigateRight,
                const SingleActivator(LogicalKeyboardKey.arrowLeft): navigateLeft,
                const SingleActivator(LogicalKeyboardKey.pageUp): navigateLeft,
              },
              child: Focus(
                autofocus: true,
                child: Stack(
                  children: [
                    PhotoViewGallery.builder(
                      itemCount: files.length,
                      pageController: pageController,
                      onPageChanged: (page) => _onPageChanged(page, files),
                      builder: (context, index) {
                        final file = files[index];
                        // in case it is a new page we need to create a new key, otherwise we need to use the existing one
                        final fileKey = imageKey.etag == file.etag! && imageKey.index == index
                            ? imageKey
                            : ImageKey(etag: file.etag!, index: index);

                        log.fine('Drawing ${file.path}');

                        return PhotoViewGalleryPageOptions(
                          photoViewKey: ObjectKey(fileKey),
                          minScale: PhotoViewComputedScale.contained,
                          imageProvider: NeonImageProvider(file: file, bloc: bloc, options: options, key: fileKey),
                        );
                      },
                      loadingBuilder: (context, event) => Stack(
                        children: [
                          if (currentFile.blurHash != null)
                            BlurHash(
                              hash: currentFile.blurHash!,
                              imageFit: BoxFit.contain,
                            ),
                          Center(
                            child: NeonCircularProgressIndicator(
                              iconData: Icons.download,
                              progress: event?.cumulativeBytesLoaded != null
                                  ? event!.cumulativeBytesLoaded.toDouble() / event.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._buildDesktopButtons(context, index, files.length),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDesktopButtons(BuildContext context, int index, int itemCount) {
    if (Platform.isAndroid || Platform.isIOS) {
      return [];
    }

    var buttons = <Widget>[];

    if (index > 0) {
      buttons.add(_buildDesktopNavButton(
        context: context,
        child: const Icon(Icons.arrow_back),
        onPressed: navigateLeft,
        alignment: Alignment.centerLeft,
        key: LogicalKeyboardKey.arrowLeft,
      ));
    }

    if (index < itemCount - 1) {
      buttons.add(_buildDesktopNavButton(
        context: context,
        child: const Icon(Icons.arrow_forward),
        onPressed: navigateRight,
        alignment: Alignment.centerRight,
        key: LogicalKeyboardKey.arrowRight,
      ));
    }

    return buttons;
  }

  void navigateLeft() => pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );

  void navigateRight() => pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );

  Widget _buildDesktopNavButton({
    required BuildContext context,
    required Widget child,
    required void Function() onPressed,
    required Alignment alignment,
    required LogicalKeyboardKey key,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: FloatingActionButton(
          heroTag: key,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
