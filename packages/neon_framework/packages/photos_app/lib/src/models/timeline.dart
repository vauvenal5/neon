import 'package:files_app/files_lib.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/sort_box.dart';
import 'package:nextcloud/webdav.dart' as webdav;

/// Holds the shared image order and month groups used by the grid and gallery.
class PhotoTimeline {
  PhotoTimeline._({required this.images, required this.months});

  factory PhotoTimeline.fromFiles(Iterable<webdav.WebDavFile> files) {
    final images = files
        .where((file) => file.etag != null && (file.mimeType?.startsWith(ImageViewerCapability.allImages) ?? false))
        .toList();
    filesSortBox.sortList(
      images,
      const (property: FilesSortProperty.modifiedDate, order: SortBoxOrder.descending),
    );

    final months = <String, List<webdav.WebDavFile>>{};
    for (final file in images) {
      final date = file.lastModified;
      final key = date == null ? 'Unknown date' : '${date.year}-${date.month.toString().padLeft(2, '0')}';
      months.putIfAbsent(key, () => []).add(file);
    }

    return PhotoTimeline._(images: images, months: months);
  }

  /// Images in the same order used by the Photos grid.
  final List<webdav.WebDavFile> images;

  /// Groups of images in display order, keyed by modified month.
  final Map<String, List<webdav.WebDavFile>> months;
}
