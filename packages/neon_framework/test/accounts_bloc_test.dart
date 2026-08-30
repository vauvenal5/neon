import 'package:account_repository/account_repository.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/blocs/accounts.dart';
import 'package:neon_framework/src/storage/keys.dart';
import 'package:neon_framework/testing.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  setUpAll(() => registerFallbackValue(MockAccount()));

  test('clearCachedFiles delegates the selected account to framework cache storage', () async {
    final account = MockAccount(username: 'edited');
    final repository = _MockAccountRepository();
    final neonStorage = MockNeonStorage();
    final cacheStorage = MockNeonCacheStorage();
    when(() => repository.accounts).thenAnswer(
      (_) => const Stream<({Account? active, BuiltList<Account> accounts})>.empty(),
    );
    when(() => neonStorage.cacheStorageFor(account)).thenReturn(cacheStorage);
    when(cacheStorage.clear).thenAnswer((_) async {});
    final bloc = AccountsBloc(
      allAppImplementations: BuiltSet<AppImplementation>(),
      accountRepository: repository,
    );
    addTearDown(bloc.dispose);

    await bloc.clearCachedFiles(account);

    verify(() => neonStorage.cacheStorageFor(account)).called(1);
    verify(cacheStorage.clear).called(1);
  });

  test('removeAccount clears cached files after logout and tolerates cleanup failure', () async {
    final account = MockAccount(username: 'removed');
    final repository = _MockAccountRepository();
    final neonStorage = MockNeonStorage();
    final cacheStorage = MockNeonCacheStorage();
    final settingsStore = MockStorage();
    when(() => repository.accounts).thenAnswer(
      (_) => const Stream<({Account? active, BuiltList<Account> accounts})>.empty(),
    );
    when(() => repository.logOut(account.id)).thenAnswer((_) async {});
    when(() => neonStorage.cacheStorageFor(account)).thenReturn(cacheStorage);
    when(cacheStorage.clear).thenThrow(Exception('cleanup failed'));
    when(() => neonStorage.settingsStore(StorageKeys.accountOptions, account.id)).thenReturn(settingsStore);
    when(() => settingsStore.getString(any())).thenReturn(null);
    final bloc = AccountsBloc(
      allAppImplementations: BuiltSet<AppImplementation>(),
      accountRepository: repository,
    );
    addTearDown(bloc.dispose);

    // Local cleanup is best effort and must not turn a completed logout into a user-visible failure.
    await expectLater(bloc.removeAccount(account), completes);

    verifyInOrder([
      () => repository.logOut(account.id),
      () => neonStorage.cacheStorageFor(account),
      cacheStorage.clear,
    ]);
  });
}
