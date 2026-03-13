import 'dart:async';

import 'package:files_app/l10n/localizations.dart';
import 'package:files_app/src/blocs/browser.dart';
import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/utils/dialog.dart';
import 'package:files_app/src/widgets/browser_view.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/theme.dart';
import 'package:neon_framework/utils.dart';
import 'package:neon_framework/widgets.dart';
import 'package:nextcloud/webdav.dart' as webdav;

class FilesMainPage extends StatefulWidget {
  const FilesMainPage({
    super.key,
  });

  @override
  State<FilesMainPage> createState() => _FilesMainPageState();
}

class _FilesMainPageState extends State<FilesMainPage> {
  webdav.PathUri uri = webdav.PathUri.cwd();
  late FilesBloc bloc;
  late final StreamSubscription<Object> errorsSubscription;

  @override
  void initState() {
    super.initState();
    bloc = NeonProvider.of<FilesBloc>(context);

    errorsSubscription = bloc.errors.listen((error) {
      if (mounted) {
        NeonError.showSnackbar(context, error);
      }
    });
  }

  @override
  void dispose() {
    unawaited(errorsSubscription.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        final parent = uri.parent;
        final canPop = ModalRoute.of(context)?.isCurrent ?? true;
        if (canPop && parent != null) {
          setState(() {
            uri = parent;
          });
          return true;
        }
        return false;
      },
      child: Scaffold(
        body: FilesBrowserView(
          filesBloc: bloc,
          uri: uri,
          mode: FilesBrowserMode.browser,
          setPath: (uri) {
            setState(() {
              this.uri = uri;
            });
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async =>
                  NeonProvider.of<AppsBloc>(context).handleAppCapability(context, AlbumViewerCapability(uri)),
              tooltip: FilesLocalizations.of(context).uploadFiles,
              heroTag: 'view',
              child: Icon(AdaptiveIcons.visibility),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () async => showFilesCreateModal(context, uri),
              tooltip: FilesLocalizations.of(context).uploadFiles,
              heroTag: 'upload',
              child: Icon(AdaptiveIcons.add),
            ),
          ],
        ),
      ),
    );
  }
}
