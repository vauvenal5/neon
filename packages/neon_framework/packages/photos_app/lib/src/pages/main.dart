import 'package:flutter/material.dart';
import 'package:neon_framework/utils.dart';
import 'package:photos_app/src/blocs/bloc.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/files.dart';
import 'package:photos_app/src/widgets/category.dart';
import 'package:photos_app/src/widgets/photos_navigation_bar.dart';

class PhotosMainPage extends StatefulWidget {
  const PhotosMainPage({
    super.key,
  });

  @override
  State<PhotosMainPage> createState() => _PhotosMainPageState();
}

class _PhotosMainPageState extends State<PhotosMainPage> {
  late PhotosAccountOptions accountOptions;
  var selectedView = PhotosSelectedView.category;

  @override
  void didChangeDependencies() {
    // Refresh the account-scoped option when the active account provider changes.
    final bloc = NeonProvider.of<PhotosBloc>(context, listen: true);
    accountOptions = bloc.accountOptions;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the selected tab and displayed Photos view in sync.
      bottomNavigationBar: PhotosNavigationBar(
        selectedApp: selectedView,
        onSelected: (view) => setState(() => selectedView = view),
      ),
      body: switch (selectedView) {
        PhotosSelectedView.category => _buildCategoryView(),
        PhotosSelectedView.browse => _buildBrowseView(),
      },
    );
  }

  Widget _buildCategoryView() {
    return ValueListenableBuilder(
      valueListenable: accountOptions.mainRecursionModeOption,
      builder: (context, mode, child) => ValueListenableBuilder(
        valueListenable: accountOptions.photosHomePathOption,
        builder: (context, value, child) {
          // Missing Ask state falls back to non-recursive discovery without affecting the main view.
          final recursive = mode.resolve(askAction: () => accountOptions.recursion ?? false);

          return CategoryView(uri: value, recursive: recursive);
        },
      ),
    );
  }

  Widget _buildBrowseView() {
    return const PhotosFilesPage();
  }
}
