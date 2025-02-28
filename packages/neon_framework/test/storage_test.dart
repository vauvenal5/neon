import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/src/storage/keys.dart';
import 'package:neon_framework/src/storage/settings_store.dart';
import 'package:neon_framework/src/storage/single_value_store.dart';
import 'package:neon_framework/testing.dart';

void main() {
  group('Storages', () {
    late MockSharedPreferences sharedPreferences;

    setUp(() {
      sharedPreferences = MockSharedPreferences();
    });

    test('AppStorage formatKey', () async {
      var appStorage = DefaultSettingsStore(sharedPreferences, StorageKeys.accountOptions);
      var key = appStorage.formatKey('test-key');
      expect(key, 'accounts-test-key');
      expect(appStorage.id, StorageKeys.accountOptions.value);

      appStorage = DefaultSettingsStore(sharedPreferences, StorageKeys.accountOptions, 'test-suffix');
      key = appStorage.formatKey('test-key');
      expect(key, 'accounts-test-suffix-test-key');
      expect(appStorage.id, 'test-suffix');
    });

    test('AppStorage interface', () async {
      final appStorage = DefaultSettingsStore(sharedPreferences, StorageKeys.accountOptions);
      const key = 'key';
      final formattedKey = appStorage.formatKey(key);

      when(() => sharedPreferences.remove(formattedKey)).thenAnswer((_) => Future.value(false));
      dynamic result = await appStorage.remove(key);
      expect(result, equals(false));
      verify(() => sharedPreferences.remove(formattedKey)).called(1);

      when(() => sharedPreferences.getString(formattedKey)).thenReturn(null);
      result = appStorage.getString(key);
      expect(result, isNull);
      verify(() => sharedPreferences.getString(formattedKey)).called(1);

      when(() => sharedPreferences.setString(formattedKey, 'value')).thenAnswer((_) => Future.value(false));
      result = await appStorage.setString(key, 'value');
      expect(result, false);
      verify(() => sharedPreferences.setString(formattedKey, 'value')).called(1);

      when(() => sharedPreferences.getBool(formattedKey)).thenReturn(true);
      result = appStorage.getBool(key);
      expect(result, equals(true));
      verify(() => sharedPreferences.getBool(formattedKey)).called(1);

      when(() => sharedPreferences.setBool(formattedKey, true)).thenAnswer((_) => Future.value(true));
      result = await appStorage.setBool(key, true);
      expect(result, true);
      verify(() => sharedPreferences.setBool(formattedKey, true)).called(1);
    });

    test('SingleValueStorage', () async {
      final storage = DefaultSingleValueStore(sharedPreferences, StorageKeys.global);
      final key = StorageKeys.global.value;

      when(() => sharedPreferences.containsKey(key)).thenReturn(true);
      dynamic result = storage.hasValue();
      expect(result, equals(true));
      verify(() => sharedPreferences.containsKey(key)).called(1);

      when(() => sharedPreferences.remove(key)).thenAnswer((_) => Future.value(false));
      result = await storage.remove();
      expect(result, equals(false));
      verify(() => sharedPreferences.remove(key)).called(1);

      when(() => sharedPreferences.getString(key)).thenReturn(null);
      result = storage.getString();
      expect(result, isNull);
      verify(() => sharedPreferences.getString(key)).called(1);

      when(() => sharedPreferences.setString(key, 'value')).thenAnswer((_) => Future.value(false));
      result = await storage.setString('value');
      expect(result, false);
      verify(() => sharedPreferences.setString(key, 'value')).called(1);

      when(() => sharedPreferences.getBool(key)).thenReturn(true);
      result = storage.getBool();
      expect(result, equals(true));
      verify(() => sharedPreferences.getBool(key)).called(1);

      when(() => sharedPreferences.setBool(key, true)).thenAnswer((_) => Future.value(true));
      result = await storage.setBool(true);
      expect(result, true);
      verify(() => sharedPreferences.setBool(key, true)).called(1);

      when(() => sharedPreferences.getStringList(key)).thenReturn(['hi there']);
      result = storage.getStringList();
      expect(result, equals(['hi there']));
      verify(() => sharedPreferences.getStringList(key)).called(1);

      when(() => sharedPreferences.setStringList(key, ['hi there'])).thenAnswer((_) => Future.value(false));
      result = await storage.setStringList(['hi there']);
      expect(result, false);
      verify(() => sharedPreferences.setStringList(key, ['hi there'])).called(1);
    });
  });
}
