import 'dart:async';

import 'package:files_app/files_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/src/models/timeline.dart';

class CategoryView extends StatefulWidget {
  CategoryView({
    required this.uri,
    required this.recursive,
    this.mimeFilter = const MimeFilter.images(),
  }) : super(key: Key('${uri}_$recursive'));

  final webdav.PathUri uri;
  final bool recursive;
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
  late final NeonAppBarController appBarController;
  late final NeonMultiSelectController<FileDetails> selection;

  int axis = 1;
  double width = 1;

  @override
  void initState() {
    appBarController = NeonProvider.of<NeonAppBarController>(context);
    filesBloc = NeonProvider.of<FilesBloc>(context);
    options = NeonProvider.of<FilesOptions>(context);
    blurBloc = NeonProvider.of<BlurBloc>(context);
    selection = NeonMultiSelectController<FileDetails>(
      keyOf: (details) => details.etag ?? details.uri.toString(),
      actionsBuilder: (selectedItems) => buildFilesActions(
        selectedItems: selectedItems,
        filesBloc: filesBloc,
        parentUri: widget.uri,
      ),
    )..addListener(_onSelectionChanged);
    appBarController.registerSelectionSession(ObjectKey(this), selection);

    controller = StickyHeaderController();

    bloc = FilesBrowserBloc(
      filesBloc: filesBloc,
      options: options,
      account: NeonProvider.of<Account>(context),
      uri: widget.uri,
      mode: FilesBrowserMode.browser,
      mimeFilter: widget.mimeFilter,
      // Recreate the browser when the resolved recursion preference changes.
      recursive: widget.recursive,
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
    // it is not allowed to access MediaQuery in initState, so we need to calculate the axis and width here
    final realdWidth = MediaQuery.sizeOf(context).width - 8;
    final newAxis = minAxis + minAxis * ((realdWidth - cut) ~/ cut);
    final newWidth = (realdWidth / newAxis) - 4;

    if (newAxis != axis && newWidth != width) {
      axis = newAxis;
      width = newWidth;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    appBarController.clearSelectionSession(ObjectKey(this));
    selection
      ..removeListener(_onSelectionChanged)
      ..dispose();
    unawaited(errorsSubscription.cancel());
    bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResultBuilder.behaviorSubject(
      subject: bloc.files,
      builder: (context, filesSnapshot) {
        // Both the grid and gallery use the same filtered, sorted timeline.
        final timeline = PhotoTimeline.fromFiles(filesSnapshot.data ?? []);

        final List<Widget> slivers = timeline.months.keys
            .map((key) => _buildCategory(key, timeline.months[key]!, timeline.images, context))
            .toList();

        return NeonListView.custom(
          scrollKey: 'category-${widget.uri.path}',
          isLoading: filesSnapshot.isLoading,
          error: filesSnapshot.error,
          onRefresh: bloc.refresh,
          slivers: slivers,
        );
      },
    );
  }

  Widget _buildHeader(String key, BuildContext context) {
    return Container(
      height: 30,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final theme = Theme.of(context);

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

            final isSelected = selection.isSelected(details);

            return InkWell(
              key: ValueKey(details.etag),
              onTap: selection.isNotEmpty ? () => selection.toggle(details) : () => _onTap(file, details, sorted),
              onLongPress: () => selection.toggle(details),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FilePreview(
                    bloc: filesBloc,
                    size: Size.square(width),
                    details: details,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FavoriteIconButton(bloc: filesBloc, details: details),
                  ),
                  if (selection.isNotEmpty)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.25) : null,
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Checkbox(
                            value: isSelected,
                            shape: const CircleBorder(),
                            onChanged: (_) => selection.toggle(details)),
                      ),
                    ),
                ],
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

  void _onSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
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

    if (!mounted) {
      return;
    }

    final capability = NeonProvider.of<AppsBloc>(context).handleAppCapability(
      context,
      ImageViewerCapability.fromFile(
        file: file,
        files: sorted,
        sortFiles: (files) => PhotoTimeline.fromFiles(files).images,
        // Keep the viewer synchronized with this category's active query.
        filesStream: bloc.files,
      ),
    );

    if (capability != null) {
      await capability;
    }
  }
}
