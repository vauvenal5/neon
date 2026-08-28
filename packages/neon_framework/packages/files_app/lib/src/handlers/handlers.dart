import 'package:files_app/src/blocs/files.dart';
import 'package:files_app/src/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/utils.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:provider/provider.dart';

class DirectorySelectionCapabilityHandler extends AppCapabilityHandler {
  @override
  bool canHandle(AppCapability capability) => capability is DirectorySelectionCapability;

  @override
  Future<C> handle<C extends AppCapability>(BuildContext context, C capability) async {
    if (capability is DirectorySelectionCapability) {
      final account = NeonProvider.of<Account>(context);
      final appsBloc = NeonProvider.of<AppsBloc>(context);
      final filesBloc = NeonProvider.of<FilesBloc>(context);
      capability.result = await showDialog<webdav.PathUri>(
        context: context,
        builder: (context) => MultiProvider(
          // Dialog routes sit above page-local providers, so carry the edited account scope into the route.
          providers: [
            Provider<Account>.value(value: account),
            NeonProvider<AppsBloc>.value(value: appsBloc),
            Provider<FilesBloc>.value(value: filesBloc),
          ],
          child: _dialogBuilder(capability, filesBloc),
        ),
      );
    }
    return capability;
  }

  Widget _dialogBuilder(DirectorySelectionCapability capability, FilesBloc filesBloc) {
    return FilesChooseFolderDialog(
      bloc: filesBloc,
      uri: capability.currentDirectory,
    );
  }
}
