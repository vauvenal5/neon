import 'package:flutter/material.dart';

/// The app selected in the Files and Photos navigation bar.
enum PhotosSelectedView {
  /// The Files app.
  browse,

  /// The Photos app.
  category,
}

/// Navigation between the Files and Photos apps.
class PhotosNavigationBar extends StatelessWidget {
  /// Creates the shared Files and Photos navigation bar.
  const PhotosNavigationBar({
    required this.selectedApp,
    required this.onSelected,
    super.key,
  });

  /// The currently selected app.
  final PhotosSelectedView selectedApp;

  @override
  Widget build(BuildContext context) {
    final currentIndex = switch (selectedApp) {
      PhotosSelectedView.category => 0,
      PhotosSelectedView.browse => 1,
    };

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index != currentIndex) {
          onSelected(switch (index) {
            0 => PhotosSelectedView.category,
            1 => PhotosSelectedView.browse,
            _ => throw RangeError.index(index, PhotosSelectedView.values),
          });
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.photo), label: 'Photos'),
        NavigationDestination(icon: Icon(Icons.folder), label: 'Browse'),
      ],
    );
  }

  /// Called when a different Photos view is selected.
  final ValueChanged<PhotosSelectedView> onSelected;
}
