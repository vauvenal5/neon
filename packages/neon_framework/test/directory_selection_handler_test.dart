import 'package:built_collection/built_collection.dart';
// ignore: depend_on_referenced_packages
import 'package:files_app/files_lib.dart';
// ignore: depend_on_referenced_packages
import 'package:files_app/l10n/localizations.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:files_app/src/handlers/handlers.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:files_app/src/widgets/browser_view.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:files_app/src/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/bloc/result.dart';
import 'package:neon_framework/src/blocs/apps.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/src/utils/request_manager.dart';
import 'package:neon_framework/testing.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class _MockRequestManager extends Mock implements RequestManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockAccount());
    registerFallbackValue(http.Request('PROPFIND', Uri()));
    registerFallbackValue(const webdav.WebDavResponseConverter());
    registerFallbackValue(BehaviorSubject<Result<BuiltList<webdav.WebDavFile>>>());
  });

  testWidgets('directory dialog preserves the edited account scope', (tester) async {
    FakeNeonStorage.setup();
    final activeAccount = MockAccount(username: 'active');
    final editedAccount = MockAccount(username: 'edited');
    final activeAppsBloc = MockAppsBloc();
    final editedAppsBloc = MockAppsBloc();
    final storage = MockStorage();
    final options = FilesOptions(storage);
    final activeFilesBloc = FilesBloc(options: options, account: activeAccount);
    final editedFilesBloc = FilesBloc(options: options, account: editedAccount);
    final requestManager = _MockRequestManager();

    when(
      () => requestManager.wrap<BuiltList<webdav.WebDavFile>, webdav.WebDavMultistatus>(
        account: editedAccount,
        subject: any(named: 'subject'),
        getRequest: any(named: 'getRequest'),
        converter: any(named: 'converter'),
        unwrap: any<BuiltList<webdav.WebDavFile> Function(webdav.WebDavMultistatus)>(named: 'unwrap'),
      ),
    ).thenAnswer((_) async {});
    RequestManager.instance = requestManager;

    await tester.pumpWidget(
      TestApp(
        localizationsDelegates: const [FilesLocalizations.delegate],
        supportedLocales: FilesLocalizations.supportedLocales,
        providers: [
          Provider<Account>.value(value: activeAccount),
          NeonProvider<AppsBloc>.value(value: activeAppsBloc),
          Provider<FilesBloc>.value(value: activeFilesBloc),
          Provider<FilesOptions>.value(value: options),
        ],
        child: MultiProvider(
          providers: [
            Provider<Account>.value(value: editedAccount),
            NeonProvider<AppsBloc>.value(value: editedAppsBloc),
            Provider<FilesBloc>.value(value: editedFilesBloc),
          ],
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await DirectorySelectionCapabilityHandler().handle(
                  context,
                  DirectorySelectionCapability(webdav.PathUri.cwd()),
                );
              },
              child: const Text('Choose folder'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Choose folder'));
    await tester.pump();

    final browserContext = tester.element(find.byType(FilesBrowserView));
    expect(NeonProvider.of<Account>(browserContext), same(editedAccount));
    expect(NeonProvider.of<AppsBloc>(browserContext), same(editedAppsBloc));
    expect(tester.widget<FilesChooseFolderDialog>(find.byType(FilesChooseFolderDialog)).bloc, same(editedFilesBloc));
    verify(
      () => requestManager.wrap<BuiltList<webdav.WebDavFile>, webdav.WebDavMultistatus>(
        account: editedAccount,
        subject: any(named: 'subject'),
        getRequest: any(named: 'getRequest'),
        converter: any(named: 'converter'),
        unwrap: any<BuiltList<webdav.WebDavFile> Function(webdav.WebDavMultistatus)>(named: 'unwrap'),
      ),
    ).called(1);

    Navigator.of(browserContext).pop();
    await tester.pumpAndSettle();

    activeFilesBloc.dispose();
    editedFilesBloc.dispose();
    options.dispose();
    RequestManager.instance = null;
  });
}
