import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/src/models/app_implementation.dart';

/// Registered app implementations and runtime-only dependencies.
@immutable
class AppImplementations {
  /// Creates the registered app and dependency collections.
  AppImplementations({
    required this.registeredAppImplementations,
    BuiltSet<AppImplementation>? dependencyApps,
  }) : dependencyApps = _deduplicateDependencies(registeredAppImplementations, dependencyApps ?? BuiltSet<AppImplementation>());

  /// Implementations matched against server apps and used for app navigation.
  final BuiltSet<AppImplementation> registeredAppImplementations;

  /// Runtime-only implementations that provide services to the registered apps.
  final BuiltSet<AppImplementation> dependencyApps;

  /// Returns all implementations in dependency-first order.
  late final BuiltList<AppImplementation> allAppImplementations =
      BuiltList<AppImplementation>([...dependencyApps, ...registeredAppImplementations]);

  static BuiltSet<AppImplementation> _deduplicateDependencies(
    BuiltSet<AppImplementation> appImplementations,
    BuiltSet<AppImplementation> dependencyApps,
  ) {
    final registeredIDs = appImplementations.map((app) => app.id).toSet();
    final dependencyIDs = <String>{};
    final uniqueDependencies = SetBuilder<AppImplementation>();

    for (final app in dependencyApps) {
      // Keep only the first dependency for each ID, and let registered apps own overlaps.
      if (!registeredIDs.contains(app.id) && dependencyIDs.add(app.id)) {
        uniqueDependencies.add(app);
      }
    }

    return uniqueDependencies.build();
  }
}
