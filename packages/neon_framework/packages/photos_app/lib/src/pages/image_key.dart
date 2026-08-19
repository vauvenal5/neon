import 'package:flutter/foundation.dart';

@immutable
class ImageKey {
  const ImageKey({required this.index, this.refetchIndex = 0});

  final int index;
  final int refetchIndex;

  @override
  bool operator ==(Object other) =>
      other is ImageKey && other.index == index && refetchIndex == other.refetchIndex;

  @override
  int get hashCode => Object.hash(index, refetchIndex);

  bool get isRefetch => refetchIndex > 0;

  ImageKey refetchKey() {
    return ImageKey(index: index, refetchIndex: refetchIndex+1);
  }
}
