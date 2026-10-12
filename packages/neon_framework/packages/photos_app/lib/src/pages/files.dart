import 'package:files_app/files_lib.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/models.dart';

/// Shows the Files browser with the Photos app's gallery-only filter.
class PhotosFilesPage extends StatelessWidget {
  const PhotosFilesPage({super.key});

  @override
  Widget build(BuildContext context) => const FilesMainPage(mimeFilter: MimeFilter.gallery());
}
