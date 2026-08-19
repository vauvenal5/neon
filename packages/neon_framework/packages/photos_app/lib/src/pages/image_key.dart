import 'package:flutter/foundation.dart';

@immutable
class ImageKey {
  const ImageKey({required this.etag, required this.index, this.refetchIndex = 0});

  final String etag;
  final int index;
  // this counter allows us to force a refresh of the image if a refetch is triggered from the image view
  final int refetchIndex;

  @override
  bool operator ==(Object other) =>
      other is ImageKey && other.etag == etag && other.index == index && refetchIndex == other.refetchIndex;

  @override
  int get hashCode => Object.hash(etag, index, refetchIndex);

  bool get isRefetch => refetchIndex > 0;

  ImageKey refetchKey() {
    return ImageKey(etag: etag, index: index, refetchIndex: refetchIndex+1);
  }
}
