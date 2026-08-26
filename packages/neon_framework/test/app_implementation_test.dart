import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neon_framework/blocs.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/settings.dart';
import 'package:neon_framework/src/testing/mocks.dart';
import 'package:neon_framework/src/utils/findable.dart';

// Provide a minimal bloc so the test can observe construction and cache behavior.
class _TestBloc extends Mock implements Bloc {}

// Keep mutable observations outside the immutable app implementation.
class _BuildRecorder {
  AccountOptionsResolver? accountOptions;
  int count = 0;
}

// Exercise the real AppImplementation cache while recording the resolver passed to its builder.
class _TestAppImplementation extends AppImplementation<_TestBloc, AppImplementationOptions> {
  _TestAppImplementation(this.options);

  final recorder = _BuildRecorder();

  @override
  final id = 'test';

  @override
  final LocalizationsDelegate<Object> localizationsDelegate = DefaultWidgetsLocalizations.delegate;

  @override
  final supportedLocales = const [Locale('en')];

  @override
  final AppImplementationOptions options;

  @override
  _TestBloc buildBloc(Account account, AccountOptionsResolver accountOptions) {
    recorder.accountOptions = accountOptions;
    recorder.count++;
    return _TestBloc();
  }

  @override
  final page = const SizedBox.shrink();

  @override
  final RouteBase route = GoRoute(
    path: '/',
    builder: (context, state) => const SizedBox.shrink(),
  );
}

void main() {
  test('getBloc forwards account options when building a bloc', () {
    final app = _TestAppImplementation(MockAppImplementationOptions());
    final account = MockAccount();
    final accountOptions = MockAccountOptions();

    final bloc = app.getBloc(account, accountOptions);

    expect(app.recorder.accountOptions, same(accountOptions));
    expect(app.getBloc(account, MockAccountOptions()), same(bloc));
    expect(app.recorder.count, 1);
  });

  group('group name', () {
    test('AccountFind', () {
      final app1 = MockAppImplementation();
      final app2 = MockAppImplementation();

      final apps = {
        app1,
        app2,
      };

      when(() => app1.id).thenReturn('app1');
      when(() => app2.id).thenReturn('app2');

      expect(apps.tryFind(null), isNull);
      expect(apps.tryFind('invalidID'), isNull);
      expect(apps.tryFind(app2.id), equals(app2));

      expect(() => apps.find('invalidID'), throwsA(isA<StateError>()));
      expect(apps.find(app2.id), equals(app2));
    });
  });
}
