import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/platform.dart';
import 'package:neon_framework/settings.dart';
import 'package:neon_framework/src/bloc/result.dart';
import 'package:neon_framework/src/blocs/accounts.dart';
import 'package:neon_framework/src/blocs/apps.dart';
import 'package:neon_framework/src/pages/account_settings.dart';
import 'package:neon_framework/src/settings/widgets/option_settings_tile.dart';
import 'package:neon_framework/src/utils/account_options.dart';
import 'package:neon_framework/src/utils/provider.dart';
import 'package:neon_framework/src/widgets/dialog.dart';
import 'package:neon_framework/storage.dart';
import 'package:neon_framework/testing.dart';
import 'package:nextcloud/core.dart' as core;
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

core.ThemingPublicCapabilities_Theming _buildServerTheme(String color) => core.ThemingPublicCapabilities_Theming(
      (b) => b
        ..name = 'Edited account'
        ..url = 'https://edited.example.com'
        ..slogan = ''
        ..color = color
        ..colorText = '#ffffff'
        ..colorElement = color
        ..colorElementBright = color
        ..colorElementDark = color
        ..logo = ''
        ..background = 'ignored-background.png'
        ..backgroundText = '#ffffff'
        ..backgroundPlain = false
        ..backgroundDefault = false
        ..logoheader = ''
        ..favicon = '',
    );

core.OcsGetCapabilitiesResponseApplicationJson_Ocs_Data _buildCapabilities(
  core.ThemingPublicCapabilities_Theming? theme,
) =>
    core.OcsGetCapabilitiesResponseApplicationJson_Ocs_Data(
      (b) => b
        ..version.update(
          (b) => b
            ..major = 0
            ..minor = 0
            ..micro = 0
            ..string = ''
            ..edition = ''
            ..extendedSupport = false,
        )
        ..capabilities = (
          commentsCapabilities: core.CommentsCapabilities((b) => b..files.update((b) => b..comments = true)),
          coreCapabilities: null,
          corePublicCapabilities: null,
          davCapabilities: null,
          dropAccountCapabilities: null,
          filesCapabilities: null,
          filesSharingCapabilities: null,
          filesTrashbinCapabilities: null,
          filesVersionsCapabilities: null,
          notesCapabilities: null,
          notificationsCapabilities: null,
          passwordPolicyCapabilities: null,
          provisioningApiCapabilities: null,
          sharebymailCapabilities: null,
          spreedCapabilities: null,
          spreedPublicCapabilities: null,
          systemtagsCapabilities: null,
          tablesCapabilities: null,
          termsOfServicePublicCapabilities: null,
          themingPublicCapabilities:
              theme == null ? null : core.ThemingPublicCapabilities((b) => b..theming.replace(theme)),
          userStatusCapabilities: null,
          weatherStatusCapabilities: null,
        ),
    );

void main() {
  late MockNeonPlatform platform;

  setUpAll(() {
    registerFallbackValue(_BuildContextFake());
    registerFallbackValue(MockAccount());
    registerFallbackValue(DirectorySelectionCapability(webdav.PathUri.cwd()));
  });

  setUp(() {
    platform = MockNeonPlatform();
    when(() => platform.canUsePaths).thenReturn(false);
    NeonPlatform.instance = platform;
  });

  testWidgets('path selection uses the account being edited', (tester) async {
    final activeAccount = MockAccount(username: 'active');
    final editedAccount = MockAccount(username: 'edited');
    final activeAppsBloc = MockAppsBloc();
    final editedAppsBloc = MockAppsBloc();
    final accountsBloc = MockAccountsBloc();
    final accountOptions = MockAccountOptions();
    final capabilitiesBloc = MockCapabilitiesBloc();
    final userDetailsBloc = MockUserDetailsBloc();
    final app = MockAccountOptionsAppImplementation();
    final appOptions = MockAppImplementationOptions();
    final storage = MockStorage();
    final userDetails = BehaviorSubject<Result<provisioning_api.UserDetails>>.seeded(Result.error('unavailable'));
    final capabilities = BehaviorSubject<Result<core.OcsGetCapabilitiesResponseApplicationJson_Ocs_Data>>.seeded(
      Result.loading(),
    );
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
    when(() => accountsBloc.getCapabilitiesBlocFor(editedAccount)).thenReturn(capabilitiesBloc);
    when(() => accountsBloc.getUserDetailsBlocFor(editedAccount)).thenReturn(userDetailsBloc);
    when(() => capabilitiesBloc.capabilities).thenAnswer((_) => capabilities);
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
    await capabilities.close();
    initialAppOption.dispose();
    pathOption.dispose();
  });

  testWidgets('page and dialogs switch to the edited account theme when capabilities arrive', (tester) async {
    final activeAccount = MockAccount(username: 'active');
    final editedAccount = MockAccount(username: 'edited');
    final accountsBloc = MockAccountsBloc();
    final appsBloc = MockAppsBloc();
    final capabilitiesBloc = MockCapabilitiesBloc();
    final accountOptions = MockAccountOptions();
    final userDetailsBloc = MockUserDetailsBloc();
    final storage = MockStorage();
    final userDetails = BehaviorSubject<Result<provisioning_api.UserDetails>>.seeded(Result.error('unavailable'));
    final capabilities = BehaviorSubject<Result<core.OcsGetCapabilitiesResponseApplicationJson_Ocs_Data>>.seeded(
      Result.loading(),
    );
    when(() => storage.getString(AccountOptionKeys.initialApp.value)).thenReturn(null);
    final initialAppOption = SelectOption<String?>(
      storage: storage,
      key: AccountOptionKeys.initialApp,
      label: (_) => 'Initial app',
      defaultValue: null,
      values: const {},
    );

    // Supply only the aggregate settings used by this theme-focused widget test.
    when(() => accountOptions.initialApp).thenReturn(initialAppOption);
    when(() => accountOptions.appOptions).thenReturn([]);
    when(() => appsBloc.appBlocProviders).thenReturn([]);
    when(() => userDetailsBloc.userDetails).thenAnswer((_) => userDetails);
    when(() => capabilitiesBloc.capabilities).thenAnswer((_) => capabilities);
    when(() => accountsBloc.getOptionsFor(editedAccount)).thenReturn(accountOptions);
    when(() => accountsBloc.getAppsBlocFor(editedAccount)).thenReturn(appsBloc);
    when(() => accountsBloc.getCapabilitiesBlocFor(editedAccount)).thenReturn(capabilitiesBloc);
    when(() => accountsBloc.getUserDetailsBlocFor(editedAccount)).thenReturn(userDetailsBloc);

    await tester.pumpWidget(
      TestApp(
        useNextcloudTheme: true,
        providers: [
          NeonProvider<AccountsBloc>.value(value: accountsBloc),
          Provider<Account>.value(value: activeAccount),
        ],
        child: AccountSettingsPage(account: editedAccount),
      ),
    );
    await tester.pump();

    final initialColor = Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary;
    const editedColor = Color(0xffc2185b);
    expect(initialColor.toARGB32(), isNot(editedColor.toARGB32()));

    capabilities.add(Result.success(_buildCapabilities(_buildServerTheme('#c2185b'))));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary.toARGB32(),
      editedColor.toARGB32(),
    );

    await tester.tap(find.byIcon(MdiIcons.cogRefresh));
    await tester.pumpAndSettle();

    // Dialog routes capture the local inherited theme from the edited account settings page.
    expect(
      Theme.of(tester.element(find.byType(NeonConfirmationDialog))).colorScheme.primary.toARGB32(),
      editedColor.toARGB32(),
    );
    verifyNever(() => accountsBloc.setActiveAccount(any()));

    await capabilities.close();
    await userDetails.close();
    initialAppOption.dispose();
  });

  testWidgets('clears cached files for the account being edited and reports success', (tester) async {
    final activeAccount = MockAccount(username: 'active');
    final editedAccount = MockAccount(username: 'edited');
    final accountsBloc = MockAccountsBloc();
    final appsBloc = MockAppsBloc();
    final capabilitiesBloc = MockCapabilitiesBloc();
    final accountOptions = MockAccountOptions();
    final userDetailsBloc = MockUserDetailsBloc();
    final storage = MockStorage();
    final clearCompleter = Completer<void>();
    final userDetails = BehaviorSubject<Result<provisioning_api.UserDetails>>.seeded(Result.error('unavailable'));
    final capabilities = BehaviorSubject<Result<core.OcsGetCapabilitiesResponseApplicationJson_Ocs_Data>>.seeded(
      Result.loading(),
    );
    when(() => storage.getString(AccountOptionKeys.initialApp.value)).thenReturn(null);
    final initialAppOption = SelectOption<String?>(
      storage: storage,
      key: AccountOptionKeys.initialApp,
      label: (_) => 'Initial app',
      defaultValue: null,
      values: const {},
    );

    when(() => platform.canUsePaths).thenReturn(true);
    when(() => accountOptions.initialApp).thenReturn(initialAppOption);
    when(() => accountOptions.appOptions).thenReturn([]);
    when(() => appsBloc.appBlocProviders).thenReturn([]);
    when(() => userDetailsBloc.userDetails).thenAnswer((_) => userDetails);
    when(() => capabilitiesBloc.capabilities).thenAnswer((_) => capabilities);
    when(() => accountsBloc.getOptionsFor(editedAccount)).thenReturn(accountOptions);
    when(() => accountsBloc.getAppsBlocFor(editedAccount)).thenReturn(appsBloc);
    when(() => accountsBloc.getCapabilitiesBlocFor(editedAccount)).thenReturn(capabilitiesBloc);
    when(() => accountsBloc.getUserDetailsBlocFor(editedAccount)).thenReturn(userDetailsBloc);
    when(() => accountsBloc.clearCachedFiles(editedAccount)).thenAnswer((_) => clearCompleter.future);

    await tester.pumpWidget(
      TestApp(
        providers: [
          NeonProvider<AccountsBloc>.value(value: accountsBloc),
          Provider<Account>.value(value: activeAccount),
        ],
        child: AccountSettingsPage(account: editedAccount),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Clear cached files'));
    await tester.pumpAndSettle();
    expect(find.textContaining('edited'), findsWidgets);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    verify(() => accountsBloc.clearCachedFiles(editedAccount)).called(1);
    verifyNever(() => accountsBloc.clearCachedFiles(activeAccount));
    expect(find.byType(CircularProgressIndicator), findsOne);

    clearCompleter.complete();
    await tester.pump();

    expect(find.textContaining('were cleared'), findsOne);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await capabilities.close();
    await userDetails.close();
    initialAppOption.dispose();
  });
}
