import 'dart:async';

import 'package:account_repository/account_repository.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

/// Creates and retains account-specific filesystem cache handles.
@internal
class NeonCacheStorageManager {
  /// Creates a manager using the platform application cache directory.
  NeonCacheStorageManager({
    @visibleForTesting Future<Directory> Function()? cacheDirectory,
  }) : _cacheDirectory = cacheDirectory ?? getApplicationCacheDirectory;

  final Future<Directory> Function() _cacheDirectory;
  final Map<String, NeonCacheStorage> _accountStoragesByID = {};
  Future<Directory>? _preparedDirectory;

  /// Returns the shared cache handle for [account].
  NeonCacheStorage forAccount(Account account) {
    final accountID = account.id;
    _validatePathSegment(accountID, 'accountID');

    // Key handles by the filesystem identity so refreshed Account objects still coordinate access to the same path.
    return _accountStoragesByID[accountID] ??= NeonCacheStorage._(
      accountID: accountID,
      cacheDirectory: _prepare,
    );
  }

  Future<Directory> _prepare() => _preparedDirectory ??= _prepareOnce();

  Future<Directory> _prepareOnce() async {
    final directory = await _cacheDirectory();
    final legacyFilesDirectory = Directory(p.join(directory.path, 'files'));
    if (legacyFilesDirectory.existsSync()) {
      // The previous app-first layout cannot be attributed reliably, so discard it before using account-first paths.
      legacyFilesDirectory.deleteSync(recursive: true);
    }
    return directory;
  }
}

/// Filesystem cache data and operation coordination for one account.
class NeonCacheStorage {
  NeonCacheStorage._({
    required String accountID,
    required Future<Directory> Function() cacheDirectory,
  })  : _accountID = accountID,
        _cacheDirectory = cacheDirectory;

  final String _accountID;
  final Future<Directory> Function() _cacheDirectory;
  int _activeOperations = 0;
  Completer<void>? _idle;
  Future<void>? _clearing;

  /// Runs [action] with the cache directory assigned to [appID].
  ///
  /// Clearing waits for active actions and prevents new actions from starting
  /// until deletion completes.
  Future<T> useCache<T>({
    required String appID,
    required Future<T> Function(Directory directory) action,
  }) async {
    _validatePathSegment(appID, 'appID');

    var clearing = _clearing;
    while (clearing != null) {
      await clearing;
      clearing = _clearing;
    }

    _activeOperations++;
    try {
      final root = await _cacheDirectory();
      final directory = Directory(p.join(root.path, _accountID, appID));
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      return await action(directory);
    } finally {
      _activeOperations--;
      if (_activeOperations == 0) {
        _idle?.complete();
        _idle = null;
      }
    }
  }

  /// Deletes cache data for every app belonging to this account.
  Future<void> clear() => _clearing ??= _clear().whenComplete(() {
        _clearing = null;
      });

  Future<void> _clear() async {
    if (_activeOperations > 0) {
      await (_idle ??= Completer<void>()).future;
    }

    final root = await _cacheDirectory();
    final directory = Directory(p.join(root.path, _accountID));
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}

void _validatePathSegment(String value, String name) {
  if (value.isEmpty || value == '.' || value == '..' || p.basename(value) != value) {
    throw ArgumentError.value(value, name, 'must be one non-empty path segment');
  }
}
