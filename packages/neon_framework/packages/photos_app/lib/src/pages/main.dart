import 'package:files_app/src/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/utils.dart';
import 'package:photos_app/src/blocs/bloc.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/widgets/category.dart';

class PhotosMainPage extends StatefulWidget {
  const PhotosMainPage({
    super.key,
  });

  @override
  State<PhotosMainPage> createState() => _PhotosMainPageState();
}

class _PhotosMainPageState extends State<PhotosMainPage> {
  late PhotosAccountOptions accountOptions;

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
      // Share the same app switcher with Files.
      bottomNavigationBar: const FilesPhotosNavigationBar(selectedApp: FilesPhotosApp.photos),
      body: ValueListenableBuilder(
        valueListenable: accountOptions.mainRecursionModeOption,
        builder: (context, mode, child) => ValueListenableBuilder(
          valueListenable: accountOptions.photosHomePathOption,
          builder: (context, value, child) {
            // Missing Ask state falls back to non-recursive discovery without affecting the main view.
            final recursive = mode.resolve(askAction: () => accountOptions.recursion ?? false);

            return CategoryView(uri: value, recursive: recursive);
          },
        ),
      ),
    );
  }
}
