
import 'package:flutter/material.dart';
import 'package:neon_framework/utils.dart';
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
  late PhotosOptions options;

  @override
  void initState() {
    super.initState();
    options = NeonProvider.of<PhotosOptions>(context);
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
