import 'package:logging/logging.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:photos_app/src/options.dart';

abstract class PhotosBloc implements Bloc {
  factory PhotosBloc({
    required PhotosOptions options,
    required PhotosAccountOptions accountOptions,
    required Account account,
  }) = _PhotosBloc;

  PhotosAccountOptions get accountOptions;
}

class _PhotosBloc extends Bloc implements PhotosBloc {
  _PhotosBloc({
    required this.options,
    required this.accountOptions,
    required this.account,
  });

  final PhotosOptions options;
  @override
  final PhotosAccountOptions accountOptions;
  final Account account;

  @override
  Logger get log => Logger('PhotosBloc');

  @override
  void dispose() {}
}
