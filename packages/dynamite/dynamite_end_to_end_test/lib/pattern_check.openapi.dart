// OpenAPI client generated by Dynamite. Do not manually edit this file.

// ignore_for_file: camel_case_extensions, camel_case_types, discarded_futures
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: public_member_api_docs, unreachable_switch_case
// ignore_for_file: unused_element

/// Pattern check test Version: 0.0.1.
library; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' as _i4;
import 'package:dynamite_runtime/built_value.dart' as _i3;
import 'package:dynamite_runtime/utils.dart' as _i1;
import 'package:meta/meta.dart' as _i2;

part 'pattern_check.openapi.g.dart';

@BuiltValue(instantiable: false)
abstract interface class $TestObjectInterface {
  @BuiltValueField(wireName: 'only-numbers')
  String? get onlyNumbers;
  @BuiltValueField(wireName: 'min-length')
  String? get minLength;
  @BuiltValueField(wireName: 'max-length')
  String? get maxLength;
  @BuiltValueField(wireName: 'multiple-checks')
  String? get multipleChecks;
}

abstract class TestObject implements $TestObjectInterface, Built<TestObject, TestObjectBuilder> {
  /// Creates a new TestObject object using the builder pattern.
  factory TestObject([void Function(TestObjectBuilder)? b]) = _$TestObject;

  const TestObject._();

  /// Creates a new object from the given [json] data.
  ///
  /// Use [toJson] to serialize it back into json.
  factory TestObject.fromJson(Map<String, dynamic> json) => _$jsonSerializers.deserializeWith(serializer, json)!;

  /// Parses this object into a json like map.
  ///
  /// Use the fromJson factory to revive it again.
  Map<String, dynamic> toJson() => _$jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;

  /// Serializer for TestObject.
  static Serializer<TestObject> get serializer => _$testObjectSerializer;

  @BuiltValueHook(finalizeBuilder: true)
  static void _validate(TestObjectBuilder b) {
    _i1.checkPattern(
      b.onlyNumbers,
      RegExp(r'^[0-9]*$'),
      'onlyNumbers',
    );
    _i1.checkMinLength(
      b.minLength,
      3,
      'minLength',
    );
    _i1.checkMaxLength(
      b.maxLength,
      20,
      'maxLength',
    );
    _i1.checkPattern(
      b.multipleChecks,
      RegExp(r'^[0-9]*$'),
      'multipleChecks',
    );
    _i1.checkMinLength(
      b.multipleChecks,
      3,
      'multipleChecks',
    );
    _i1.checkMaxLength(
      b.multipleChecks,
      20,
      'multipleChecks',
    );
  }
}

// coverage:ignore-start
/// Serializer for all values in this library.
///
/// Serializes values into the `built_value` wire format.
/// See: [$jsonSerializers] for serializing into json.
@_i2.visibleForTesting
final Serializers $serializers = _$serializers;
final Serializers _$serializers = (Serializers().toBuilder()
      ..addBuilderFactory(const FullType(TestObject), TestObjectBuilder.new)
      ..add(TestObject.serializer))
    .build();

/// Serializer for all values in this library.
///
/// Serializes values into the json. Json serialization is more expensive than the built_value wire format.
/// See: [$serializers] for serializing into the `built_value` wire format.
@_i2.visibleForTesting
final Serializers $jsonSerializers = _$jsonSerializers;
final Serializers _$jsonSerializers = (_$serializers.toBuilder()
      ..add(_i3.DynamiteDoubleSerializer())
      ..addPlugin(_i4.StandardJsonPlugin())
      ..addPlugin(const _i3.HeaderPlugin())
      ..addPlugin(const _i3.ContentStringPlugin()))
    .build();
// coverage:ignore-end
