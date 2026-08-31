import 'package:flutter/material.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/src/widgets/category.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    required this.uri,
    required this.recursive,
    super.key,
  });

  final webdav.PathUri uri;
  final bool recursive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(uri.name),
      ),
      body: CategoryView(
        uri: uri,
        recursive: recursive,
      ),
    );
  }
}
