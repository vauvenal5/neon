import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/l10n/localizations.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/models/disposable.dart';
import 'package:neon_framework/src/settings/models/option.dart';
import 'package:neon_framework/src/settings/models/options_collection.dart';
import 'package:neon_framework/src/storage/keys.dart';
import 'package:neon_framework/storage.dart';

/// Owns all framework and app options related to an [account].
@internal
@immutable
class AccountOptions extends OptionsCollection implements AccountOptionsResolver {
  /// Creates all option collections scoped to [account].
  AccountOptions({required this.account, required BuiltSet<AppImplementation> appImplementations})
      : super(NeonStorage().settingsStore(StorageKeys.accountOptions, account.id)) {
    // Build app options here so one per-account owner controls their storage and lifecycle.
    for (final app in appImplementations) {
      if (app case final AccountOptionsAppImplementation accountOptionsApp) {
        final storage = NeonStorage().appAccountSettingsStore(appID: app.id, accountID: account.id);
        _appOptions[app] = accountOptionsApp.buildAccountOptions(account, storage);
        _appStores[app] = storage;
      }
    }
  }

  /// Account whose options are represented by this collection.
  final Account account;

  final Map<AppImplementation, AppImplementationOptions> _appOptions = {};
  final Map<AppImplementation, SettingsStore> _appStores = {};

  /// All app-owned option collections keyed by their app implementation.
  Iterable<MapEntry<AppImplementation, AppImplementationOptions>> get appOptions => _appOptions.entries;

  void updateAppImplementations(BuiltSet<AppImplementation> appImplementations) {
    initialApp.values = {
      null: (context) => NeonLocalizations.of(context).accountOptionsAutomatic,
    }..addEntries(appImplementations.map((app) => MapEntry(app.id, app.name)));
  }

  @override
  late final List<Option<dynamic>> options = [
    initialApp,
  ];

  /// The initial app to show on app start.
  ///
  /// Defaults to `null` letting the framework choose one.
  late final initialApp = SelectOption<String?>(
    storage: storage,
    key: AccountOptionKeys.initialApp,
    label: (context) => NeonLocalizations.of(context).accountOptionsInitialApp,
    defaultValue: null,
    values: {},
  );

  @override
  AppImplementationOptions? getAppAccountOptions(AppImplementation app) => _appOptions[app];

  @override
  A getAccountOptions<T extends Bloc, R extends AppImplementationOptions, A extends AppImplementationOptions>(
    AccountOptionsAppImplementation<T, R, A> app,
  ) {
    final value = _appOptions[app];
    if (value == null) {
      throw StateError('No account options were registered for ${app.id}');
    }
    return value as A;
  }

  /// Resets all framework and app options owned by this collection.
  @override
  void reset() {
    // Keep framework and app options aligned when an account-level reset is requested.
    super.reset();
    for (final appOptions in _appOptions.values) {
      appOptions.reset();
    }
  }

  /// Clears all persisted app settings owned by this aggregate.
  Future<void> clearAppOptions() async {
    for (final storage in _appStores.values) {
      await storage.clear();
    }
  }

  @override
  void dispose() {
    // Dispose the inherited framework options before releasing app-owned collections.
    super.dispose();
    _appOptions.values.disposeAll();
  }
}

/// Storage keys for the [AccountOptions].
@internal
enum AccountOptionKeys implements Storable {
  /// The storage key for [AccountOptions.initialApp]
  initialApp._('initial-app');

  const AccountOptionKeys._(this.value);

  @override
  final String value;
}
