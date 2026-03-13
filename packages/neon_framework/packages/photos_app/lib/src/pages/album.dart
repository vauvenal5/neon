
import 'package:flutter/material.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/src/widgets/category.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.uri,
  });

  final webdav.PathUri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(uri.name),
      ),
      body: CategoryView(
        uri: uri,
      ),
    );
  }
}
