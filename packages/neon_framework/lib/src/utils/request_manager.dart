import 'dart:async';
import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:neon_framework/models.dart';
import 'package:neon_framework/src/bloc/result.dart';
import 'package:neon_framework/src/models/account.dart';
import 'package:neon_framework/storage.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xml/xml.dart' as xml;

/// A callback that unwraps elements of type [R] into [T].
///
/// This is commonly used to get the relevant information from a broader response.
typedef UnwrapCallback<T, R> = T Function(R);

/// A callback to serialize a value of type [T] into a string.
///
/// This is used to store a value in the cache.
@internal
typedef SerializeCallback<T> = String Function(T);

/// A callback to revive cached values [String] into their original type [T].
@internal
typedef DeserializeCallback<T> = T Function(String);

/// How often a request will be tried.
///
/// A request will not be retried if the returned status code is in the `500`
/// range or if the request has timed out.
const kMaxRetries = 3;

/// The default timeout for requests.
///
/// Requests that take longer than this duration will be canceled.
const kDefaultTimeout = Duration(seconds: 30);

/// Implements https://www.rfc-editor.org/rfc/rfc9110#name-date-time-formats
@visibleForTesting
final httpDateFormat = DateFormat('E, d MMM yyyy HH:mm:ss v', 'en_US');

/// A singleton class that handles requests to the Nextcloud API.
///
/// Requests need to be made through the [nextcloud](https://pub.dev/packages/nextcloud)
/// package.
///
/// Requests can be persisted in the local cache if enabled and set up by the [NeonStorage].
class RequestManager {
  RequestManager._();

  /// Mocks the singleton instance for testing.
  @visibleForTesting
  factory RequestManager.mocked(RequestManager requestManager) => _requestManager = requestManager;

  static RequestManager? _requestManager;

  /// Gets the current instance of [RequestManager].
  // ignore: prefer_constructors_over_static_methods
  static RequestManager get instance => _requestManager ??= RequestManager._();

  @visibleForTesting
  static set instance(RequestManager? requestManager) => _requestManager = requestManager;

  final RequestCache? _cache = NeonStorage().requestCache;

  /// Executes a request to a Nextcloud API endpoint.
  Future<void> wrapNextcloud<T, B, H>({
    required Account account,
    required String cacheKey,
    required BehaviorSubject<Result<T>> subject,
    required DynamiteRawResponse<B, H> rawResponse,
    required UnwrapCallback<T, DynamiteResponse<B, H>> unwrap,
    bool disableTimeout = false,
  }) async =>
      wrap<T, DynamiteRawResponse<B, H>>(
        account: account,
        cacheKey: cacheKey,
        subject: subject,
        request: () async {
          await rawResponse.future;

          return rawResponse;
        },
        unwrap: (rawResponse) => unwrap(rawResponse.response),
        serialize: (data) => json.encode(data),
        deserialize: (data) => DynamiteRawResponse<B, H>.fromJson(
          json.decode(data) as Map<String, Object?>,
          serializers: rawResponse.serializers,
          bodyType: rawResponse.bodyType,
          headersType: rawResponse.headersType,
        ),
        disableTimeout: disableTimeout,
      );

  /// Executes a WebDAV request.
  Future<void> wrapWebDav<T>({
    required Account account,
    required String cacheKey,
    required BehaviorSubject<Result<T>> subject,
    required AsyncValueGetter<WebDavMultistatus> request,
    required UnwrapCallback<T, WebDavMultistatus> unwrap,
    bool disableTimeout = false,
  }) async =>
      wrap<T, WebDavMultistatus>(
        account: account,
        cacheKey: cacheKey,
        subject: subject,
        request: request,
        unwrap: unwrap,
        serialize: (data) => data.toXmlElement(namespaces: namespaces).toXmlString(),
        deserialize: (data) => WebDavMultistatus.fromXmlElement(xml.XmlDocument.parse(data).rootElement),
        disableTimeout: disableTimeout,
      );

  /// Executes a HTTP request for binary content.
  Future<void> wrapBinary({
    required Account account,
    required String cacheKey,
    required AsyncValueGetter<CacheParameters> getCacheParameters,
    required DynamiteRawResponse<Uint8List, dynamic> rawResponse,
    required UnwrapCallback<Uint8List, Uint8List>? unwrap,
    required BehaviorSubject<Result<Uint8List>> subject,
    bool disableTimeout = false,
  }) async =>
      wrap<Uint8List, DynamiteRawResponse<Uint8List, dynamic>>(
        account: account,
        cacheKey: cacheKey,
        subject: subject,
        request: () async {
          await rawResponse.future;
          return rawResponse;
        },
        unwrap: (rawResponse) {
          var data = rawResponse.response.body;
          if (unwrap != null) {
            data = unwrap(data);
          }

          return data;
        },
        serialize: (rawResponse) => base64.encode(rawResponse.response.body),
        deserialize: (data) => DynamiteRawResponse<Uint8List, Map<String, String>>.fromJson(
          {
            'statusCode': 200,
            'body': base64.decode(data),
            'headers': <String, String>{},
          },
          bodyType: const FullType(Uint8List),
          headersType: const FullType(Map, [FullType(String), FullType(String)]),
          serializers: Serializers(),
        ),
        getCacheParameters: getCacheParameters,
        disableTimeout: disableTimeout,
      );

  /// Executes a HTTP request for binary content using a simplified [uri] based approach.
  Future<void> wrapUri({
    required Account account,
    required Uri uri,
    required UnwrapCallback<Uint8List, Uint8List>? unwrap,
    required BehaviorSubject<Result<Uint8List>> subject,
  }) {
    final headers = account.getAuthorizationHeaders(uri);

    return wrapBinary(
      account: account,
      cacheKey: uri.toString(),
      getCacheParameters: () async {
        final response = await account.client.executeRawRequest(
          'HEAD',
          uri,
          headers: headers,
        );

        return CacheParameters.parseHeaders(response.headers);
      },
      rawResponse: DynamiteRawResponse<Uint8List, Map<String, String>>(
        response: account.client.executeRawRequest(
          'GET',
          uri,
          headers: headers,
          validStatuses: const {200, 201},
        ),
        bodyType: const FullType(Uint8List),
        headersType: const FullType(Map, [FullType(String), FullType(String)]),
        serializers: Serializers(),
      ),
      unwrap: unwrap,
      subject: subject,
    );
  }

  /// Executes a generic request.
  ///
  /// This method is only meant to be used in testing.
  @visibleForTesting
  Future<void> wrap<T, R>({
    required Account account,
    required String cacheKey,
    required BehaviorSubject<Result<T>> subject,
    required AsyncValueGetter<R> request,
    required UnwrapCallback<T, R> unwrap,
    required SerializeCallback<R> serialize,
    required DeserializeCallback<R> deserialize,
    AsyncValueGetter<CacheParameters>? getCacheParameters,
    bool disableTimeout = false,
    Duration timeLimit = kDefaultTimeout,
    int retries = 0,
  }) async {
    final key = '${account.id}-$cacheKey';

    if (retries == 0) {
      // emit loading state with the current value if present
      final value = subject.valueOrNull?.asLoading() ?? Result.loading();
      subject.add(value);

      final cachedParameters = await _cache?.getParameters(key);

      if (cachedParameters != null) {
        if (cachedParameters.expires != null && !cachedParameters.isExpired) {
          final cachedValue = await _cache?.get(key);
          if (cachedValue != null) {
            subject.add(Result(unwrap(deserialize(cachedValue)), null, isLoading: false, isCached: true));
            return;
          }
        }

        if (cachedParameters.etag != null) {
          final cacheParameters = await timeout(
            () async => getCacheParameters?.call(),
            timeLimit: timeLimit,
          );
          if (cacheParameters != null && cacheParameters.etag == cachedParameters.etag) {
            final cachedValue = await _cache?.get(key);
            if (cachedValue != null) {
              unawaited(
                _cache?.updateParameters(
                  key,
                  cacheParameters,
                ),
              );
              subject.add(Result(unwrap(deserialize(cachedValue)), null, isLoading: false, isCached: true));
              return;
            }
          }
        }
      }

      final cachedValue = await _cache?.get(key);
      if (cachedValue != null) {
        subject.add(
          subject.value.copyWith(
            data: unwrap(deserialize(cachedValue)),
            isLoading: true,
            isCached: true,
          ),
        );
      }
    }

    try {
      final response = await timeout(
        request,
        disableTimeout: disableTimeout,
        timeLimit: timeLimit,
      );
      subject.add(Result.success(unwrap(response)));

      final serialized = serialize(response);

      CacheParameters? cacheParameters;
      if (response is DynamiteRawResponse && response.rawHeaders != null) {
        cacheParameters = CacheParameters.parseHeaders(response.rawHeaders!);
      }

      await _cache?.set(key, serialized, cacheParameters);
    } on TimeoutException catch (e, s) {
      debugPrint('Request timed out ...');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s, maxFrames: 5);

      _emitError<T>(e, subject);
    } on http.ClientException catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s, maxFrames: 5);

      if (e is DynamiteStatusCodeException && e.statusCode >= 500 && retries < kMaxRetries) {
        debugPrint('Retrying...');
        await wrap(
          account: account,
          cacheKey: cacheKey,
          subject: subject,
          request: request,
          unwrap: unwrap,
          serialize: serialize,
          deserialize: deserialize,
          disableTimeout: disableTimeout,
          timeLimit: timeLimit,
          retries: retries + 1,
        );
      } else {
        _emitError<T>(e, subject);
      }
    }
  }

  /// Re emits the current result with the given [error].
  ///
  /// Defaults to a [Result.error] if none has been emitted yet.
  void _emitError<T>(
    Object error,
    BehaviorSubject<Result<T>> subject,
  ) {
    final value = subject.valueOrNull?.copyWith(error: error, isLoading: false) ?? Result.error(error);
    subject.add(value);
  }

  /// Calls a [callback] that is canceled after a given [timeLimit].
  ///
  /// If the callback completes in time the resulting value is returned.
  /// Otherwise the returned future will be completed with a [TimeoutException].
  /// If the timeout is disabled through [disableTimeout] the future of the
  /// callback is returned immediately.
  Future<T> timeout<T>(
    AsyncValueGetter<T> callback, {
    bool disableTimeout = false,
    Duration timeLimit = kDefaultTimeout,
  }) {
    if (disableTimeout) {
      return callback();
    }

    return callback().timeout(timeLimit);
  }
}

/// Parameters for values in [RequestCache].
@immutable
class CacheParameters {
  /// Creates new cache parameters.
  const CacheParameters({
    required this.etag,
    required this.expires,
  });

  /// Parse the cache parameters from HTTP response headers.
  factory CacheParameters.parseHeaders(Map<String, dynamic> headers) {
    final expiry = headers.containsKey('expires') ? httpDateFormat.parse(headers['expires']! as String) : null;
    return CacheParameters(
      etag: headers['etag'] as String?,
      expires: _isExpired(expiry) ? null : expiry,
    );
  }

  /// `ETag` of the resource.
  final String? etag;

  /// `Expires` of the resource.
  final DateTime? expires;

  /// Whether the resource has expired based on [expires].
  bool get isExpired => _isExpired(expires);

  static bool _isExpired(DateTime? date) => date?.isBefore(DateTime.now()) ?? true;

  @override
  bool operator ==(Object other) => other is CacheParameters && other.etag == etag && other.expires == expires;

  @override
  int get hashCode => Object.hashAll([etag, expires]);

  @override
  String toString() => 'CacheParameters(etag: $etag, expires: $expires)';
}
