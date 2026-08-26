/// The Neon client for the Photos app.
///
/// Add `PhotosApp()` to your runNeon command to execute this app.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/storage.dart';
import 'package:photos_app/l10n/localizations.dart';
import 'package:photos_app/src/blocs/bloc.dart';
import 'package:photos_app/src/handlers/handlers.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/main.dart';
import 'package:photos_app/src/routes.dart';

class PhotosApp extends AccountOptionsAppImplementation<PhotosBloc, PhotosOptions, PhotosAccountOptions> {
  PhotosApp();

  static const String appID = "photos";

  final ImageHandler _imageHandler = ImageHandler();
  final AlbumHandler _albumHandler = AlbumHandler();

  @override
  final String id = appID;

  @override
  final LocalizationsDelegate<PhotosLocalizations> localizationsDelegate = PhotosLocalizations.delegate;

  @override
  final List<Locale> supportedLocales = PhotosLocalizations.supportedLocales;

  @override
  late final PhotosOptions options = PhotosOptions(storage);

  @override
  PhotosAccountOptions buildAccountOptions(Account account, SettingsStore storage) => PhotosAccountOptions(storage);

  @override
  PhotosBloc buildBlocWithAccountOptions(Account account, PhotosAccountOptions accountOptions) => PhotosBloc(
        options: options,
        accountOptions: accountOptions,
        account: account,
      );

  @override
  final Widget page = const PhotosMainPage();

  @override
  final RouteBase route = $photosAppRoute;

  @override
  AppCapabilityHandler? appCapabilityHandler(AppCapability capability) {
    if (_imageHandler.canHandle(capability)) {
      return _imageHandler;
    }

    if (_albumHandler.canHandle(capability)) {
      return _albumHandler;
    }

    return null;
  }
}
