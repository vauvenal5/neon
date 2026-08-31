import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/storage.dart';
import 'package:neon_framework/testing.dart';
import 'package:neon_framework/utils.dart';
import 'package:nextcloud/webdav.dart' as webdav;
import 'package:photos_app/l10n/localizations.dart';
import 'package:photos_app/src/blocs/bloc.dart';
import 'package:photos_app/src/handlers/handlers.dart';
import 'package:photos_app/src/options.dart';
import 'package:photos_app/src/pages/album.dart';

class _MemorySettingsStore implements SettingsStore {
  _MemorySettingsStore(this.id);

  final Map<String, Object> _values = {};

  @override
  final String id;

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  List<String> keys() => _values.keys.toList();

  @override
  Future<bool> remove(String key) async => _values.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }
}

void main() {
  test('recursion modes lazily resolve the supplied Ask actions', () async {
    var askInvocations = 0;
    bool ask() {
      askInvocations++;
      return true;
    }

    // Fixed modes must not invoke the entry point's potentially interactive Ask action.
    expect(RecursionMode.enabled.resolve(askAction: ask), isTrue);
    expect(RecursionMode.disabled.resolve(askAction: ask), isFalse);
    expect(askInvocations, 0);
    expect(RecursionMode.ask.resolve(askAction: ask), isTrue);
    expect(askInvocations, 1);
    expect(RecursionMode.ask.resolve(askAction: () => false), isFalse);

    expect(await RecursionMode.enabled.resolveAsync(askAction: () async => null), isTrue);
    expect(await RecursionMode.disabled.resolveAsync(askAction: () async => null), isFalse);
    expect(await RecursionMode.ask.resolveAsync(askAction: () async => null), isNull);
  });

  test('recursion modes default to disabled and persist in their respective scopes', () {
    final appStorage = _MemorySettingsStore('photos');
    final accountStorage = _MemorySettingsStore('photos-account');
    final options = PhotosOptions(appStorage);
    final accountOptions = PhotosAccountOptions(accountStorage);

    expect(accountOptions.mainRecursionModeOption.value, RecursionMode.disabled);
    expect(options.focusRecursionModeOption.value, RecursionMode.disabled);

    accountOptions.mainRecursionModeOption.value = RecursionMode.ask;
    options.focusRecursionModeOption.value = RecursionMode.enabled;

    final restoredOptions = PhotosOptions(appStorage);
    final restoredAccountOptions = PhotosAccountOptions(accountStorage);
    expect(restoredAccountOptions.mainRecursionModeOption.value, RecursionMode.ask);
    expect(restoredOptions.focusRecursionModeOption.value, RecursionMode.enabled);

    options.dispose();
    accountOptions.dispose();
    restoredOptions.dispose();
    restoredAccountOptions.dispose();
  });

  test('account recursion answers are stored and reset with the account options', () async {
    final storage = _MemorySettingsStore('photos-account');
    final options = PhotosAccountOptions(storage);

    await options.rememberRecursion(recursive: false);

    expect(options.recursion, isFalse);

    options.reset();
    expect(options.recursion, isNull);
    options.dispose();
  });

  test('main recursion modes are independent between accounts', () {
    final first = PhotosAccountOptions(_MemorySettingsStore('first-account'));
    final second = PhotosAccountOptions(_MemorySettingsStore('second-account'));

    // Changing one account must not alter another account's conservative default.
    first.mainRecursionModeOption.value = RecursionMode.enabled;
    expect(first.mainRecursionModeOption.value, RecursionMode.enabled);
    expect(second.mainRecursionModeOption.value, RecursionMode.disabled);

    first.dispose();
    second.dispose();
  });

  test('account export preserves the main Ask resolution', () async {
    final source = PhotosAccountOptions(_MemorySettingsStore('source'));
    final destination = PhotosAccountOptions(_MemorySettingsStore('destination'));
    final selectedPath = webdav.PathUri.parse('Photos/Exported');

    source
      ..photosHomePathOption.value = selectedPath
      ..mainRecursionModeOption.value = RecursionMode.ask;
    await source.rememberRecursion(recursive: false);

    final exported = source.serialize();
    // The hidden resolution travels with the visible account-scoped mode and path.
    expect(exported[PhotosOptionKeys.mainRecursionValue.value], isFalse);

    destination.deserialize(exported);
    expect(destination.photosHomePathOption.value, selectedPath);
    expect(destination.mainRecursionModeOption.value, RecursionMode.ask);
    expect(destination.recursion, isFalse);

    destination.deserialize({PhotosOptionKeys.mainRecursionMode.value: RecursionMode.ask.toString()});
    expect(destination.recursion, isNull);

    source.dispose();
    destination.dispose();
  });

  testWidgets('returning to Ask prompts again and cancellation retains the previous mode', (tester) async {
    final accountStorage = _MemorySettingsStore('photos-account');
    final accountOptions = PhotosAccountOptions(accountStorage);
    final bloc = PhotosBloc(
      accountOptions: accountOptions,
      account: MockAccount(),
    );

    await tester.pumpWidget(
      TestApp(
        localizationsDelegates: const [PhotosLocalizations.delegate],
        supportedLocales: PhotosLocalizations.supportedLocales,
        providers: [NeonProvider<PhotosBloc>.value(value: bloc)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              // Mirror the settings tile's guarded commit so cancellation can be asserted directly.
              final accepted = await accountOptions.mainRecursionModeOption.onSelected!(context, RecursionMode.ask);
              if (accepted) {
                accountOptions.mainRecursionModeOption.value = RecursionMode.ask;
              }
            },
            child: const Text('Select Ask'),
          ),
        ),
      ),
    );

    accountOptions.mainRecursionModeOption.value = RecursionMode.disabled;
    await tester.tap(find.text('Select Ask'));
    await tester.pumpAndSettle();
    expect(find.text('Show photos from subfolders?'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(accountOptions.mainRecursionModeOption.value, RecursionMode.ask);
    expect(accountOptions.recursion, isTrue);

    accountOptions.mainRecursionModeOption.value = RecursionMode.disabled;
    await tester.tap(find.text('Select Ask'));
    await tester.pumpAndSettle();
    expect(find.text('Show photos from subfolders?'), findsOneWidget);

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    expect(accountOptions.mainRecursionModeOption.value, RecursionMode.disabled);
    expect(accountOptions.recursion, isTrue);

    bloc.dispose();
    accountOptions.dispose();
  });

  testWidgets('Focus Ask prompts for every action and cancellation prevents navigation', (tester) async {
    final options = PhotosOptions(_MemorySettingsStore('photos'));
    final handler = AlbumHandler();
    var completedActions = 0;
    options.focusRecursionModeOption.value = RecursionMode.ask;

    await tester.pumpWidget(
      TestApp(
        localizationsDelegates: const [PhotosLocalizations.delegate],
        supportedLocales: PhotosLocalizations.supportedLocales,
        providers: [NeonProvider<PhotosOptions>.value(value: options)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              // Exercise the capability boundary used by the Files Focus action.
              await handler.handle(context, AlbumViewerCapability(webdav.PathUri.parse('Photos/Focused')));
              completedActions++;
            },
            child: const Text('Focus'),
          ),
        ),
      ),
    );

    for (var invocation = 1; invocation <= 2; invocation++) {
      await tester.tap(find.text('Focus'));
      await tester.pumpAndSettle();
      expect(find.text('Show photos from subfolders?'), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(completedActions, invocation);
      expect(find.byType(AlbumPage), findsNothing);
    }

    options.dispose();
  });
}
