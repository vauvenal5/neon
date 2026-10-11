import 'package:flutter/material.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/utils.dart';

/// The app selected in the Files and Photos navigation bar.
enum FilesPhotosApp {
  /// The Files app.
  files,

  /// The Photos app.
  photos,
}

/// Navigation between the Files and Photos apps.
class FilesPhotosNavigationBar extends StatelessWidget {
  /// Creates the shared Files and Photos navigation bar.
  const FilesPhotosNavigationBar({
    required this.selectedApp,
    super.key,
  });

  /// The currently selected app.
  final FilesPhotosApp selectedApp;

  @override
  Widget build(BuildContext context) {
    final appsBloc = NeonProvider.of<AppsBloc>(context);
    final currentIndex = switch (selectedApp) {
      FilesPhotosApp.files => 0,
      FilesPhotosApp.photos => 1,
    };

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {
          // Let the framework switch the active app and update its route.
          appsBloc.setActiveApp(switch (index) {
            0 => 'files',
            1 => 'photos',
            _ => throw RangeError.index(index, FilesPhotosApp.values),
          });
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
        BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Photos'),
      ],
    );
  }
}
