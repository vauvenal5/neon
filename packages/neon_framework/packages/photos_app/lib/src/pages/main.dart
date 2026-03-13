import 'dart:async';

import 'package:files_app/files_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/sort_box.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/src/blocs/bloc.dart';
import 'package:photos_app/src/options.dart';

class PhotosMainPage extends StatefulWidget {
  const PhotosMainPage({
    super.key,
  });

  @override
  State<PhotosMainPage> createState() => _PhotosMainPageState();
}

class _PhotosMainPageState extends State<PhotosMainPage> {
  late PhotosOptions options;
  late PhotosBloc photosBloc;
  late FilesBloc filesBloc;

  @override
  void initState() {
    super.initState();
    options = NeonProvider.of<PhotosOptions>(context);
    photosBloc = NeonProvider.of<PhotosBloc>(context);
    filesBloc = NeonProvider.of<FilesBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: options.photosHomePathOption,
        builder: (context, value, child) => CategoryView(
          uri: value,
        ),
      ),
    );
  }
}

class CategoryView extends StatefulWidget {
  CategoryView({
    required this.uri,
    this.mimeFilter = const MimeFilter.images(),
  }) : super(key: Key(uri.toString()));

  final webdav.PathUri uri;
  final MimeFilter mimeFilter;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final FilesBloc filesBloc;
  late final FilesOptions options;
  late final BlurBloc blurBloc;
  late final FilesBrowserBloc bloc;
  late final StreamSubscription<Object> errorsSubscription;
  late final StickyHeaderController controller;

  int axis = 1;
  double width = 1;

  @override
  void initState() {
    filesBloc = NeonProvider.of<FilesBloc>(context);
    options = NeonProvider.of<FilesOptions>(context);
    blurBloc = NeonProvider.of<BlurBloc>(context);

    controller = StickyHeaderController();

    bloc = FilesBrowserBloc(
      filesBloc: filesBloc,
      options: options,
      account: NeonProvider.of<Account>(context),
      uri: widget.uri,
      mode: FilesBrowserMode.browser,
      blurBloc: blurBloc,
      mimeFilter: widget.mimeFilter,
      loadFiles: false,
    );

    errorsSubscription = bloc.errors.listen((error) {
      if (mounted) {
        NeonError.showSnackbar(context, error);
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    const cut = 550;
    const minAxis = 3;
    final realdWidth = MediaQuery.sizeOf(context).width - 8;
    final newAxis = minAxis + minAxis * ((realdWidth - cut) ~/ cut);
    final newWidth = (realdWidth / newAxis) - 4;

    if (newAxis != axis && newWidth != width) {
      axis = newAxis;
      width = newWidth;
      unawaited(bloc.updateSize(Size.square(width)));
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    unawaited(errorsSubscription.cancel());
    bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResultBuilder.behaviorSubject(
      subject: bloc.files,
      builder: (context, filesSnapshot) {
        final sorted = filesSnapshot.data?.toList() ?? [];
        const box = (property: FilesSortProperty.modifiedDate, order: SortBoxOrder.descending);
        filesSortBox.sortList(sorted, box);

        final categories = <String, List<webdav.WebDavFile>>{};

        for (final file in sorted) {
          final key = '${file.lastModified!.year}-${file.lastModified!.month.toString().padLeft(2, '0')}';
          if (categories[key] == null) {
            categories[key] = [];
          }
          categories[key]!.add(file);
        }

        final List<Widget> slivers =
            categories.keys.map((key) => _buildCategory(key, categories[key]!, sorted, context)).toList();

        return CustomScrollView(
          slivers: slivers,
          physics: const AlwaysScrollableScrollPhysics(),
        );
      },
    );
  }

  Widget _buildHeader(String key, BuildContext context) {
    return Container(
      height: 30.0,
      color: Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        key,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  SliverStickyHeader _buildCategory(
    String key,
    List<webdav.WebDavFile> category,
    List<webdav.WebDavFile> sorted,
    BuildContext context,
  ) {
    return SliverStickyHeader(
      key: ValueKey(key),
      header: _buildHeader(key, context),
      controller: controller,
      sliver: SliverGrid(
        key: ValueKey('${key}_grid'),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final file = category[index];
            final details = FileDetails.fromWebDav(
              file: file,
            );

            return GestureDetector(
              onTap: () => _onTap(file, details, sorted),
              child: FilePreview(
                bloc: filesBloc,
                size: Size.square(width),
                details: details,
              ),
            );
          },
          childCount: category.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: axis,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
      ),
    );
  }

  Future<void> _onTap(webdav.WebDavFile file, FileDetails details, List<webdav.WebDavFile> sorted) async {
    // size warning handling needs to be made global
    final sizeWarning = NeonProvider.of<FilesOptions>(context).downloadSizeWarning.value;
    if (sizeWarning != null && details.size != null && details.size! > sizeWarning) {
      final decision = await showDownloadConfirmationDialog(context, sizeWarning, details.size!);

      if (!decision) {
        return;
      }
    }

    if (context.mounted) {
      final capability = NeonProvider.of<AppsBloc>(context).handleAppCapability(
        context,
        ImageViewerCapability.fromFile(file: file, files: sorted),
      );

      if (capability != null) {
        await capability;
      }
    }
  }
}
