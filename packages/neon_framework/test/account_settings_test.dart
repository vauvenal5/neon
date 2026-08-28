import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/settings.dart';
import 'package:neon_framework/src/bloc/result.dart';
import 'package:neon_framework/src/blocs/accounts.dart';
import 'package:neon_framework/src/blocs/apps.dart';
import 'package:neon_framework/src/pages/account_settings.dart';
import 'package:neon_framework/src/settings/widgets/option_settings_tile.dart';
import 'package:neon_framework/src/utils/account_options.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/storage.dart';
import 'package:neon_framework/testing.dart';
import 'package:nextcloud/provisioning_api.dart' as provisioning_api;
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class _BuildContextFake extends Fake implements BuildContext {}

enum _OptionKey implements Storable {
  path('path');

  const _OptionKey(this.value);

  @override
  final String value;
}

class _SelectingDirectoryHandler extends AppCapabilityHandler {
  _SelectingDirectoryHandler({required this.account, required this.selection});

  final Account account;
  final webdav.PathUri selection;

  @override
  bool canHandle(AppCapability capability) => capability is DirectorySelectionCapability;

  @override
  Future<C> handle<C extends AppCapability>(BuildContext context, C capability) async {
    // The handler context must expose the account whose settings page is open.
    expect(NeonProvider.of<Account>(context), same(account));
    if (capability is DirectorySelectionCapability) {
      capability.result = selection;
    }
    return capability;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(_BuildContextFake());
    registerFallbackValue(MockAccount());
    registerFallbackValue(DirectorySelectionCapability(webdav.PathUri.cwd()));
  });

  testWidgets('path selection uses the account being edited', (tester) async {
    final activeAccount = MockAccount(username: 'active');
    final editedAccount = MockAccount(username: 'edited');
    final activeAppsBloc = MockAppsBloc();
    final editedAppsBloc = MockAppsBloc();
    final accountsBloc = MockAccountsBloc();
    final accountOptions = MockAccountOptions();
    final userDetailsBloc = MockUserDetailsBloc();
    final app = MockAccountOptionsAppImplementation();
    final appOptions = MockAppImplementationOptions();
    final storage = MockStorage();
    final userDetails = BehaviorSubject<Result<provisioning_api.UserDetails>>.seeded(Result.error('unavailable'));
    final selection = webdav.PathUri.parse('Photos/Selected');
    final handler = _SelectingDirectoryHandler(account: editedAccount, selection: selection);

    when(() => storage.getString(_OptionKey.path.value)).thenReturn(null);
    when(() => storage.getString(AccountOptionKeys.initialApp.value)).thenReturn(null);
    when(() => storage.setString(_OptionKey.path.value, any())).thenAnswer((_) async => true);

    final pathOption = PathUriOption(
      storage: storage,
      key: _OptionKey.path,
      label: (_) => 'Photos path',
      defaultValue: webdav.PathUri.cwd(),
    );
    final initialAppOption = SelectOption<String?>(
      storage: storage,
      key: AccountOptionKeys.initialApp,
      label: (_) => 'Initial app',
      defaultValue: null,
      values: const {},
    );

    when(() => app.name(any())).thenReturn('Photos');
    when(() => appOptions.options).thenReturn([pathOption]);
    when(() => accountOptions.initialApp).thenReturn(initialAppOption);
    when(() => accountOptions.appOptions).thenReturn([MapEntry(app, appOptions)]);
    when(() => userDetailsBloc.userDetails).thenAnswer((_) => userDetails);
    when(() => accountsBloc.getOptionsFor(editedAccount)).thenReturn(accountOptions);
    when(() => accountsBloc.getAppsBlocFor(editedAccount)).thenReturn(editedAppsBloc);
    when(() => accountsBloc.getUserDetailsBlocFor(editedAccount)).thenReturn(userDetailsBloc);
    when(() => editedAppsBloc.appBlocProviders).thenReturn([]);
    when(() => editedAppsBloc.findAppCapabilityHandler(any())).thenReturn(handler);

    await tester.pumpWidget(
      TestApp(
        providers: [
          NeonProvider<AccountsBloc>.value(value: accountsBloc),
          Provider<Account>.value(value: activeAccount),
          NeonProvider<AppsBloc>.value(value: activeAppsBloc),
        ],
        child: AccountSettingsPage(account: editedAccount),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(PathUriSettingsTile));
    await tester.pump();

    expect(pathOption.value, selection);
    verify(() => editedAppsBloc.findAppCapabilityHandler(any())).called(1);
    verifyNever(() => activeAppsBloc.findAppCapabilityHandler(any()));
    verifyNever(() => accountsBloc.setActiveAccount(any()));

    await userDetails.close();
    initialAppOption.dispose();
    pathOption.dispose();
  });
}
