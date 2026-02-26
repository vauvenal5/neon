import 'package:flutter/material.dart';

/// Filter for MIME types to be shown in different views.
@immutable
class MimeFilter {
  /// Creates a new [MimeFilter] with the given [activeMimeRegex] and [showDirectories] values.
  const MimeFilter({
    required this.activeMimeRegex,
    required this.showDirectories,
  });

  /// A [MimeFilter] which allows all MIME types and shows directories.
  const MimeFilter.files() : this(activeMimeRegex: '.*', showDirectories: true);

  /// A [MimeFilter] which allows only MIME types starting with "image/" and hides directories.
  const MimeFilter.images() : this(activeMimeRegex: 'image/.*', showDirectories: false);

  /// Regex pattern defining the active MIME types.
  final String activeMimeRegex;

  /// Whether to show directories.
  final bool showDirectories;
}
