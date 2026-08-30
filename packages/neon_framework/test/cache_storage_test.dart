import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/storage/cache_storage.dart';
import 'package:neon_framework/testing.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

void main() {
  test('useCache scopes paths by account and app', () async {
    final cacheDirectory = await Directory.systemTemp.createTemp('neon-cache-path-test-');
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final manager = NeonCacheStorageManager(cacheDirectory: () async => cacheDirectory);
    final firstAccount = MockAccount(username: 'account-1');
    final secondAccount = MockAccount(username: 'account-2');
    final firstStorage = manager.forAccount(firstAccount);

    final filesPath = await firstStorage.useCache(
      appID: 'files',
      action: (directory) async => directory.path,
    );
    final photosPath = await firstStorage.useCache(
      appID: 'photos',
      action: (directory) async => directory.path,
    );
    final secondAccountPath = await manager.forAccount(secondAccount).useCache(
          appID: 'files',
          action: (directory) async => directory.path,
        );

    expect(filesPath, p.join(cacheDirectory.path, firstAccount.id, 'files'));
    expect(photosPath, p.join(cacheDirectory.path, firstAccount.id, 'photos'));
    expect(secondAccountPath, p.join(cacheDirectory.path, secondAccount.id, 'files'));
  });

  test('clear removes every app cache for only the selected account', () async {
    final cacheDirectory = await Directory.systemTemp.createTemp('neon-cache-clear-test-');
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final manager = NeonCacheStorageManager(cacheDirectory: () async => cacheDirectory);
    final firstAccount = MockAccount(username: 'account-1');
    final secondAccount = MockAccount(username: 'account-2');

    Future<File> createCachedFile(Account account, String appID) => manager.forAccount(account).useCache(
          appID: appID,
          action: (directory) async => File(p.join(directory.path, 'cached')).create(),
        );

    final filesFile = await createCachedFile(firstAccount, 'files');
    final photosFile = await createCachedFile(firstAccount, 'photos');
    final secondAccountFile = await createCachedFile(secondAccount, 'files');

    // One framework operation clears every app namespace without involving app-owned callbacks.
    await manager.forAccount(firstAccount).clear();

    expect(filesFile.existsSync(), isFalse);
    expect(photosFile.existsSync(), isFalse);
    expect(secondAccountFile.existsSync(), isTrue);
    await manager.forAccount(MockAccount(username: 'missing')).clear();
  });

  test('clear waits for active operations and blocks new operations', () async {
    final cacheDirectory = await Directory.systemTemp.createTemp('neon-cache-coordination-test-');
    addTearDown(() => cacheDirectory.delete(recursive: true));
    final manager = NeonCacheStorageManager(cacheDirectory: () async => cacheDirectory);
    final activeStarted = Completer<void>();
    final releaseActive = Completer<void>();
    final clearCompleted = Completer<void>();
    final waitingStarted = Completer<void>();
    final account = MockAccount(username: 'account-1');
    final storage = manager.forAccount(account);

    final active = storage.useCache(
      appID: 'files',
      action: (directory) async {
        activeStarted.complete();
        await releaseActive.future;
      },
    );
    await activeStarted.future;

    final clearing = storage.clear().whenComplete(clearCompleted.complete);
    final waiting = storage.useCache(
      appID: 'photos',
      action: (directory) async => waitingStarted.complete(),
    );
    await Future<void>.delayed(Duration.zero);

    expect(clearCompleted.isCompleted, isFalse);
    expect(waitingStarted.isCompleted, isFalse);

    releaseActive.complete();
    await Future.wait([active, clearing, waiting]);

    expect(clearCompleted.isCompleted, isTrue);
    expect(waitingStarted.isCompleted, isTrue);
  });

  test('preparation purges the legacy app-first files cache once', () async {
    final cacheDirectory = await Directory.systemTemp.createTemp('neon-cache-migration-test-');
    addTearDown(() => cacheDirectory.delete(recursive: true));
    var resolutions = 0;
    final manager = NeonCacheStorageManager(
      cacheDirectory: () async {
        resolutions++;
        return cacheDirectory;
      },
    );
    final legacyFile = File(p.join(cacheDirectory.path, 'files', 'etag', 'image.jpg'));
    await legacyFile.create(recursive: true);
    final account = MockAccount(username: 'account-1');
    final storage = manager.forAccount(account);

    await storage.useCache(appID: 'files', action: (_) async {});
    expect(legacyFile.existsSync(), isFalse);

    await legacyFile.create(recursive: true);
    await storage.useCache(appID: 'photos', action: (_) async {});

    // Preparation is memoized, so later app operations do not repeat migration work.
    expect(legacyFile.existsSync(), isTrue);
    expect(resolutions, 1);
  });

  test('useCache rejects path traversal in namespace identifiers', () async {
    final manager = NeonCacheStorageManager(cacheDirectory: () async => Directory('/cache'));
    final account = MockAccount();
    final invalidAccount = _MockAccount();
    when(() => invalidAccount.id).thenReturn('../account');

    // Keep validating the derived account ID defensively even though callers now pass an Account.
    expect(
      () => manager.forAccount(invalidAccount),
      throwsArgumentError,
    );
    expect(
      () => manager.forAccount(account).useCache(appID: '../files', action: (_) async {}),
      throwsArgumentError,
    );
  });

  test('manager shares a handle across account objects with the same filesystem identity', () {
    final manager = NeonCacheStorageManager(cacheDirectory: () async => Directory('/cache'));
    final oldAccount = MockAccount(appPassword: 'old-password');
    final refreshedAccount = MockAccount(appPassword: 'new-password');

    // Credential refreshes must not split coordination for the unchanged account directory.
    expect(oldAccount.id, refreshedAccount.id);
    expect(manager.forAccount(oldAccount), same(manager.forAccount(refreshedAccount)));
  });
}

class _MockAccount extends Mock implements Account {}
