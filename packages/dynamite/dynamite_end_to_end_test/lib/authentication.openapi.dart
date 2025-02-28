// OpenAPI client generated by Dynamite. Do not manually edit this file.

// ignore_for_file: camel_case_extensions, camel_case_types, discarded_futures
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: public_member_api_docs, unreachable_switch_case
// ignore_for_file: unused_element

/// authentication test Version: 0.0.1.
library; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' as _i4;
import 'package:collection/collection.dart';
import 'package:dynamite_runtime/built_value.dart' as _i3;
import 'package:dynamite_runtime/http_client.dart' as _i1;
import 'package:meta/meta.dart' as _i2;

class $Client extends _i1.DynamiteClient {
  /// Creates a new `DynamiteClient` for untagged requests.
  $Client(
    super.baseURL, {
    super.baseHeaders,
    super.httpClient,
    super.cookieJar,
    super.authentications,
  });

  /// Creates a new [$Client] from another [client].
  $Client.fromClient(_i1.DynamiteClient client)
      : super(
          client.baseURL,
          baseHeaders: client.baseHeaders,
          httpClient: client.httpClient,
          cookieJar: client.cookieJar,
          authentications: client.authentications,
        );

  /// Returns a [Future] containing a `DynamiteResponse` with the status code, deserialized body and headers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [noAuthenticationRaw] for an experimental operation that returns a `DynamiteRawResponse` that can be serialized.
  Future<_i1.DynamiteResponse<JsonObject, void>> noAuthentication() async {
    final rawResponse = noAuthenticationRaw();

    return rawResponse.future;
  }

  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a `DynamiteRawResponse` with the raw `HttpClientResponse` and serialization helpers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [noAuthentication] for an operation that returns a `DynamiteResponse` with a stable API.
  @_i2.experimental
  _i1.DynamiteRawResponse<JsonObject, void> noAuthenticationRaw() {
    const _headers = <String, String>{'Accept': 'application/json'};

    const _path = '/';
    return _i1.DynamiteRawResponse<JsonObject, void>(
      response: executeRequest(
        'get',
        _path,
        headers: _headers,
        validStatuses: const {200},
      ),
      bodyType: const FullType(JsonObject),
      headersType: null,
      serializers: _$jsonSerializers,
    );
  }

  /// Returns a [Future] containing a `DynamiteResponse` with the status code, deserialized body and headers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [basicAuthenticationRaw] for an experimental operation that returns a `DynamiteRawResponse` that can be serialized.
  Future<_i1.DynamiteResponse<JsonObject, void>> basicAuthentication() async {
    final rawResponse = basicAuthenticationRaw();

    return rawResponse.future;
  }

  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a `DynamiteRawResponse` with the raw `HttpClientResponse` and serialization helpers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [basicAuthentication] for an operation that returns a `DynamiteResponse` with a stable API.
  @_i2.experimental
  _i1.DynamiteRawResponse<JsonObject, void> basicAuthenticationRaw() {
    final _headers = <String, String>{'Accept': 'application/json'};

// coverage:ignore-start
    final authentication = authentications?.firstWhereOrNull(
      (auth) => switch (auth) {
        _i1.DynamiteHttpBasicAuthentication() => true,
        _ => false,
      },
    );

    if (authentication != null) {
      _headers.addAll(
        authentication.headers,
      );
    } else {
      throw Exception('Missing authentication for basic_auth');
    }

// coverage:ignore-end
    const _path = '/basic';
    return _i1.DynamiteRawResponse<JsonObject, void>(
      response: executeRequest(
        'get',
        _path,
        headers: _headers,
        validStatuses: const {200},
      ),
      bodyType: const FullType(JsonObject),
      headersType: null,
      serializers: _$jsonSerializers,
    );
  }

  /// Returns a [Future] containing a `DynamiteResponse` with the status code, deserialized body and headers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [bearerAuthenticationRaw] for an experimental operation that returns a `DynamiteRawResponse` that can be serialized.
  Future<_i1.DynamiteResponse<JsonObject, void>> bearerAuthentication() async {
    final rawResponse = bearerAuthenticationRaw();

    return rawResponse.future;
  }

  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a `DynamiteRawResponse` with the raw `HttpClientResponse` and serialization helpers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [bearerAuthentication] for an operation that returns a `DynamiteResponse` with a stable API.
  @_i2.experimental
  _i1.DynamiteRawResponse<JsonObject, void> bearerAuthenticationRaw() {
    final _headers = <String, String>{'Accept': 'application/json'};

// coverage:ignore-start
    final authentication = authentications?.firstWhereOrNull(
      (auth) => switch (auth) {
        _i1.DynamiteHttpBearerAuthentication() => true,
        _ => false,
      },
    );

    if (authentication != null) {
      _headers.addAll(
        authentication.headers,
      );
    } else {
      throw Exception('Missing authentication for bearer_auth');
    }

// coverage:ignore-end
    const _path = '/bearer';
    return _i1.DynamiteRawResponse<JsonObject, void>(
      response: executeRequest(
        'get',
        _path,
        headers: _headers,
        validStatuses: const {200},
      ),
      bodyType: const FullType(JsonObject),
      headersType: null,
      serializers: _$jsonSerializers,
    );
  }

  /// Returns a [Future] containing a `DynamiteResponse` with the status code, deserialized body and headers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [multipleAuthenticationsRaw] for an experimental operation that returns a `DynamiteRawResponse` that can be serialized.
  Future<_i1.DynamiteResponse<JsonObject, void>> multipleAuthentications() async {
    final rawResponse = multipleAuthenticationsRaw();

    return rawResponse.future;
  }

  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a `DynamiteRawResponse` with the raw `HttpClientResponse` and serialization helpers.
  /// Throws a `DynamiteApiException` if the API call does not return an expected status code.
  ///
  /// Status codes:
  ///   * 200
  ///
  /// See:
  ///  * [multipleAuthentications] for an operation that returns a `DynamiteResponse` with a stable API.
  @_i2.experimental
  _i1.DynamiteRawResponse<JsonObject, void> multipleAuthenticationsRaw() {
    final _headers = <String, String>{'Accept': 'application/json'};

// coverage:ignore-start
    final authentication = authentications?.firstWhereOrNull(
      (auth) => switch (auth) {
        _i1.DynamiteHttpBearerAuthentication() || _i1.DynamiteHttpBasicAuthentication() => true,
        _ => false,
      },
    );

    if (authentication != null) {
      _headers.addAll(
        authentication.headers,
      );
    } else {
      throw Exception('Missing authentication for bearer_auth or basic_auth');
    }

// coverage:ignore-end
    const _path = '/multiple';
    return _i1.DynamiteRawResponse<JsonObject, void>(
      response: executeRequest(
        'get',
        _path,
        headers: _headers,
        validStatuses: const {200},
      ),
      bodyType: const FullType(JsonObject),
      headersType: null,
      serializers: _$jsonSerializers,
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
final Serializers _$serializers = Serializers();

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
