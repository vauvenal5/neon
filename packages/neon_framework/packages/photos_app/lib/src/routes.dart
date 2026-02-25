import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_framework/utils.dart';
import 'package:nextcloud/comments.dart' as PhotosApp;
import 'package:photos_app/src/pages/main.dart';

part 'routes.g.dart';

@TypedGoRoute<PhotosAppRoute>(
  path: '$appsBaseRoutePrefix${PhotosApp.appID}',
  name: PhotosApp.appID,
)
@immutable
class PhotosAppRoute extends NeonBaseAppRoute with _$PhotosAppRoute {
  const PhotosAppRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PhotosMainPage();
}
