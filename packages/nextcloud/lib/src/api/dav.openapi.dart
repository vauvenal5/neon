// ignore_for_file: camel_case_types
// ignore_for_file: discarded_futures
// ignore_for_file: public_member_api_docs
// ignore_for_file: unreachable_switch_case
// ignore_for_file: camel_case_extensions
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:collection/collection.dart';
import 'package:dynamite_runtime/built_value.dart';
import 'package:dynamite_runtime/http_client.dart';
import 'package:dynamite_runtime/utils.dart' as dynamite_utils;
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';
import 'package:uri/uri.dart';

part 'dav.openapi.g.dart';

class $Client extends DynamiteClient {
  $Client(
    super.baseURL, {
    super.baseHeaders,
    super.userAgent,
    super.httpClient,
    super.cookieJar,
    super.authentications,
  });

  $Client.fromClient(DynamiteClient client)
      : super(
          client.baseURL,
          baseHeaders: client.baseHeaders,
          httpClient: client.httpClient,
          cookieJar: client.cookieJar,
          authentications: client.authentications,
        );

  $DirectClient get direct => $DirectClient(this);

  $OutOfOfficeClient get outOfOffice => $OutOfOfficeClient(this);
}

class $DirectClient {
  $DirectClient(this._rootClient);

  final $Client _rootClient;

  /// Get a direct link to a file.
  ///
  /// Returns a [Future] containing a [DynamiteResponse] with the status code, deserialized body and headers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [fileId] ID of the file.
  ///   * [expirationTime] Duration until the link expires.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Direct link returned
  ///   * 404: File not found
  ///   * 400: Getting direct link is not possible
  ///   * 403: Missing permissions to get direct link
  ///
  /// See:
  ///  * [getUrlRaw] for an experimental operation that returns a [DynamiteRawResponse] that can be serialized.
  Future<DynamiteResponse<DirectGetUrlResponseApplicationJson, void>> getUrl({
    required int fileId,
    int? expirationTime,
    bool? oCSAPIRequest,
  }) async {
    final rawResponse = getUrlRaw(
      fileId: fileId,
      expirationTime: expirationTime,
      oCSAPIRequest: oCSAPIRequest,
    );

    return rawResponse.future;
  }

  /// Get a direct link to a file.
  ///
  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a [DynamiteRawResponse] with the raw [HttpClientResponse] and serialization helpers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [fileId] ID of the file.
  ///   * [expirationTime] Duration until the link expires.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Direct link returned
  ///   * 404: File not found
  ///   * 400: Getting direct link is not possible
  ///   * 403: Missing permissions to get direct link
  ///
  /// See:
  ///  * [getUrl] for an operation that returns a [DynamiteResponse] with a stable API.
  @experimental
  DynamiteRawResponse<DirectGetUrlResponseApplicationJson, void> getUrlRaw({
    required int fileId,
    int? expirationTime,
    bool? oCSAPIRequest,
  }) {
    final _parameters = <String, dynamic>{};
    final _headers = <String, String>{
      'Accept': 'application/json',
    };

// coverage:ignore-start
    final authentication = _rootClient.authentications.firstWhereOrNull(
      (auth) => switch (auth) {
        DynamiteHttpBearerAuthentication() || DynamiteHttpBasicAuthentication() => true,
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
    final $fileId = jsonSerializers.serialize(fileId, specifiedType: const FullType(int));
    _parameters['fileId'] = $fileId;

    final $expirationTime = jsonSerializers.serialize(expirationTime, specifiedType: const FullType(int));
    _parameters['expirationTime'] = $expirationTime;

    var $oCSAPIRequest = jsonSerializers.serialize(oCSAPIRequest, specifiedType: const FullType(bool));
    $oCSAPIRequest ??= true;
    _headers['OCS-APIRequest'] = const dynamite_utils.HeaderEncoder().convert($oCSAPIRequest);

    final _path = UriTemplate('/ocs/v2.php/apps/dav/api/v1/direct{?fileId*,expirationTime*}').expand(_parameters);
    return DynamiteRawResponse<DirectGetUrlResponseApplicationJson, void>(
      response: _rootClient.executeRequest(
        'post',
        _path,
        _headers,
        null,
        const {200},
      ),
      bodyType: const FullType(DirectGetUrlResponseApplicationJson),
      headersType: null,
      serializers: jsonSerializers,
    );
  }
}

class $OutOfOfficeClient {
  $OutOfOfficeClient(this._rootClient);

  final $Client _rootClient;

  /// Get the currently configured out-of-office data of a user.
  ///
  /// Returns a [Future] containing a [DynamiteResponse] with the status code, deserialized body and headers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId] The user id to get out-of-office data for.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Out-of-office data
  ///   * 404: No out-of-office data was found
  ///
  /// See:
  ///  * [getCurrentOutOfOfficeDataRaw] for an experimental operation that returns a [DynamiteRawResponse] that can be serialized.
  Future<DynamiteResponse<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson, void>>
      getCurrentOutOfOfficeData({
    required String userId,
    bool? oCSAPIRequest,
  }) async {
    final rawResponse = getCurrentOutOfOfficeDataRaw(
      userId: userId,
      oCSAPIRequest: oCSAPIRequest,
    );

    return rawResponse.future;
  }

  /// Get the currently configured out-of-office data of a user.
  ///
  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a [DynamiteRawResponse] with the raw [HttpClientResponse] and serialization helpers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId] The user id to get out-of-office data for.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Out-of-office data
  ///   * 404: No out-of-office data was found
  ///
  /// See:
  ///  * [getCurrentOutOfOfficeData] for an operation that returns a [DynamiteResponse] with a stable API.
  @experimental
  DynamiteRawResponse<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson, void> getCurrentOutOfOfficeDataRaw({
    required String userId,
    bool? oCSAPIRequest,
  }) {
    final _parameters = <String, dynamic>{};
    final _headers = <String, String>{
      'Accept': 'application/json',
    };

// coverage:ignore-start
    final authentication = _rootClient.authentications.firstWhereOrNull(
      (auth) => switch (auth) {
        DynamiteHttpBearerAuthentication() || DynamiteHttpBasicAuthentication() => true,
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
    final $userId = jsonSerializers.serialize(userId, specifiedType: const FullType(String));
    _parameters['userId'] = $userId;

    var $oCSAPIRequest = jsonSerializers.serialize(oCSAPIRequest, specifiedType: const FullType(bool));
    $oCSAPIRequest ??= true;
    _headers['OCS-APIRequest'] = const dynamite_utils.HeaderEncoder().convert($oCSAPIRequest);

    final _path = UriTemplate('/ocs/v2.php/apps/dav/api/v1/outOfOffice/{userId}/now').expand(_parameters);
    return DynamiteRawResponse<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson, void>(
      response: _rootClient.executeRequest(
        'get',
        _path,
        _headers,
        null,
        const {200},
      ),
      bodyType: const FullType(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson),
      headersType: null,
      serializers: jsonSerializers,
    );
  }

  /// Get the configured out-of-office data of a user.
  ///
  /// Returns a [Future] containing a [DynamiteResponse] with the status code, deserialized body and headers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId] The user id to get out-of-office data for.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Out-of-office data
  ///   * 404: No out-of-office data was found
  ///
  /// See:
  ///  * [getOutOfOfficeRaw] for an experimental operation that returns a [DynamiteRawResponse] that can be serialized.
  Future<DynamiteResponse<OutOfOfficeGetOutOfOfficeResponseApplicationJson, void>> getOutOfOffice({
    required String userId,
    bool? oCSAPIRequest,
  }) async {
    final rawResponse = getOutOfOfficeRaw(
      userId: userId,
      oCSAPIRequest: oCSAPIRequest,
    );

    return rawResponse.future;
  }

  /// Get the configured out-of-office data of a user.
  ///
  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a [DynamiteRawResponse] with the raw [HttpClientResponse] and serialization helpers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId] The user id to get out-of-office data for.
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Out-of-office data
  ///   * 404: No out-of-office data was found
  ///
  /// See:
  ///  * [getOutOfOffice] for an operation that returns a [DynamiteResponse] with a stable API.
  @experimental
  DynamiteRawResponse<OutOfOfficeGetOutOfOfficeResponseApplicationJson, void> getOutOfOfficeRaw({
    required String userId,
    bool? oCSAPIRequest,
  }) {
    final _parameters = <String, dynamic>{};
    final _headers = <String, String>{
      'Accept': 'application/json',
    };

// coverage:ignore-start
    final authentication = _rootClient.authentications.firstWhereOrNull(
      (auth) => switch (auth) {
        DynamiteHttpBearerAuthentication() || DynamiteHttpBasicAuthentication() => true,
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
    final $userId = jsonSerializers.serialize(userId, specifiedType: const FullType(String));
    _parameters['userId'] = $userId;

    var $oCSAPIRequest = jsonSerializers.serialize(oCSAPIRequest, specifiedType: const FullType(bool));
    $oCSAPIRequest ??= true;
    _headers['OCS-APIRequest'] = const dynamite_utils.HeaderEncoder().convert($oCSAPIRequest);

    final _path = UriTemplate('/ocs/v2.php/apps/dav/api/v1/outOfOffice/{userId}').expand(_parameters);
    return DynamiteRawResponse<OutOfOfficeGetOutOfOfficeResponseApplicationJson, void>(
      response: _rootClient.executeRequest(
        'get',
        _path,
        _headers,
        null,
        const {200},
      ),
      bodyType: const FullType(OutOfOfficeGetOutOfOfficeResponseApplicationJson),
      headersType: null,
      serializers: jsonSerializers,
    );
  }

  /// Set out-of-office absence.
  ///
  /// Returns a [Future] containing a [DynamiteResponse] with the status code, deserialized body and headers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [firstDay] First day of the absence in format `YYYY-MM-DD`.
  ///   * [lastDay] Last day of the absence in format `YYYY-MM-DD`.
  ///   * [status] Short text that is set as user status during the absence.
  ///   * [message] Longer multiline message that is shown to others during the absence.
  ///   * [userId]
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Absence data
  ///   * 400: When the first day is not before the last day
  ///   * 401: When the user is not logged in
  ///
  /// See:
  ///  * [setOutOfOfficeRaw] for an experimental operation that returns a [DynamiteRawResponse] that can be serialized.
  Future<DynamiteResponse<OutOfOfficeSetOutOfOfficeResponseApplicationJson, void>> setOutOfOffice({
    required String firstDay,
    required String lastDay,
    required String status,
    required String message,
    required String userId,
    bool? oCSAPIRequest,
  }) async {
    final rawResponse = setOutOfOfficeRaw(
      firstDay: firstDay,
      lastDay: lastDay,
      status: status,
      message: message,
      userId: userId,
      oCSAPIRequest: oCSAPIRequest,
    );

    return rawResponse.future;
  }

  /// Set out-of-office absence.
  ///
  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a [DynamiteRawResponse] with the raw [HttpClientResponse] and serialization helpers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [firstDay] First day of the absence in format `YYYY-MM-DD`.
  ///   * [lastDay] Last day of the absence in format `YYYY-MM-DD`.
  ///   * [status] Short text that is set as user status during the absence.
  ///   * [message] Longer multiline message that is shown to others during the absence.
  ///   * [userId]
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: Absence data
  ///   * 400: When the first day is not before the last day
  ///   * 401: When the user is not logged in
  ///
  /// See:
  ///  * [setOutOfOffice] for an operation that returns a [DynamiteResponse] with a stable API.
  @experimental
  DynamiteRawResponse<OutOfOfficeSetOutOfOfficeResponseApplicationJson, void> setOutOfOfficeRaw({
    required String firstDay,
    required String lastDay,
    required String status,
    required String message,
    required String userId,
    bool? oCSAPIRequest,
  }) {
    final _parameters = <String, dynamic>{};
    final _headers = <String, String>{
      'Accept': 'application/json',
    };

// coverage:ignore-start
    final authentication = _rootClient.authentications.firstWhereOrNull(
      (auth) => switch (auth) {
        DynamiteHttpBearerAuthentication() || DynamiteHttpBasicAuthentication() => true,
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
    final $firstDay = jsonSerializers.serialize(firstDay, specifiedType: const FullType(String));
    _parameters['firstDay'] = $firstDay;

    final $lastDay = jsonSerializers.serialize(lastDay, specifiedType: const FullType(String));
    _parameters['lastDay'] = $lastDay;

    final $status = jsonSerializers.serialize(status, specifiedType: const FullType(String));
    _parameters['status'] = $status;

    final $message = jsonSerializers.serialize(message, specifiedType: const FullType(String));
    _parameters['message'] = $message;

    final $userId = jsonSerializers.serialize(userId, specifiedType: const FullType(String));
    _parameters['userId'] = $userId;

    var $oCSAPIRequest = jsonSerializers.serialize(oCSAPIRequest, specifiedType: const FullType(bool));
    $oCSAPIRequest ??= true;
    _headers['OCS-APIRequest'] = const dynamite_utils.HeaderEncoder().convert($oCSAPIRequest);

    final _path = UriTemplate('/ocs/v2.php/apps/dav/api/v1/outOfOffice/{userId}{?firstDay*,lastDay*,status*,message*}')
        .expand(_parameters);
    return DynamiteRawResponse<OutOfOfficeSetOutOfOfficeResponseApplicationJson, void>(
      response: _rootClient.executeRequest(
        'post',
        _path,
        _headers,
        null,
        const {200},
      ),
      bodyType: const FullType(OutOfOfficeSetOutOfOfficeResponseApplicationJson),
      headersType: null,
      serializers: jsonSerializers,
    );
  }

  /// Clear the out-of-office.
  ///
  /// Returns a [Future] containing a [DynamiteResponse] with the status code, deserialized body and headers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId]
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: When the absence was cleared successfully
  ///   * 401: When the user is not logged in
  ///
  /// See:
  ///  * [clearOutOfOfficeRaw] for an experimental operation that returns a [DynamiteRawResponse] that can be serialized.
  Future<DynamiteResponse<OutOfOfficeClearOutOfOfficeResponseApplicationJson, void>> clearOutOfOffice({
    required String userId,
    bool? oCSAPIRequest,
  }) async {
    final rawResponse = clearOutOfOfficeRaw(
      userId: userId,
      oCSAPIRequest: oCSAPIRequest,
    );

    return rawResponse.future;
  }

  /// Clear the out-of-office.
  ///
  /// This method and the response it returns is experimental. The API might change without a major version bump.
  ///
  /// Returns a [Future] containing a [DynamiteRawResponse] with the raw [HttpClientResponse] and serialization helpers.
  /// Throws a [DynamiteApiException] if the API call does not return an expected status code.
  ///
  /// Parameters:
  ///   * [userId]
  ///   * [oCSAPIRequest] Required to be true for the API request to pass. Defaults to `true`.
  ///
  /// Status codes:
  ///   * 200: When the absence was cleared successfully
  ///   * 401: When the user is not logged in
  ///
  /// See:
  ///  * [clearOutOfOffice] for an operation that returns a [DynamiteResponse] with a stable API.
  @experimental
  DynamiteRawResponse<OutOfOfficeClearOutOfOfficeResponseApplicationJson, void> clearOutOfOfficeRaw({
    required String userId,
    bool? oCSAPIRequest,
  }) {
    final _parameters = <String, dynamic>{};
    final _headers = <String, String>{
      'Accept': 'application/json',
    };

// coverage:ignore-start
    final authentication = _rootClient.authentications.firstWhereOrNull(
      (auth) => switch (auth) {
        DynamiteHttpBearerAuthentication() || DynamiteHttpBasicAuthentication() => true,
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
    final $userId = jsonSerializers.serialize(userId, specifiedType: const FullType(String));
    _parameters['userId'] = $userId;

    var $oCSAPIRequest = jsonSerializers.serialize(oCSAPIRequest, specifiedType: const FullType(bool));
    $oCSAPIRequest ??= true;
    _headers['OCS-APIRequest'] = const dynamite_utils.HeaderEncoder().convert($oCSAPIRequest);

    final _path = UriTemplate('/ocs/v2.php/apps/dav/api/v1/outOfOffice/{userId}').expand(_parameters);
    return DynamiteRawResponse<OutOfOfficeClearOutOfOfficeResponseApplicationJson, void>(
      response: _rootClient.executeRequest(
        'delete',
        _path,
        _headers,
        null,
        const {200, 401},
      ),
      bodyType: const FullType(OutOfOfficeClearOutOfOfficeResponseApplicationJson),
      headersType: null,
      serializers: jsonSerializers,
    );
  }
}

@BuiltValue(instantiable: false)
abstract interface class $OCSMetaInterface {
  String get status;
  int get statuscode;
  String? get message;
  String? get totalitems;
  String? get itemsperpage;
}

abstract class OCSMeta implements $OCSMetaInterface, Built<OCSMeta, OCSMetaBuilder> {
  factory OCSMeta([void Function(OCSMetaBuilder)? b]) = _$OCSMeta;

  // coverage:ignore-start
  const OCSMeta._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OCSMeta.fromJson(Map<String, dynamic> json) => jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OCSMeta> get serializer => _$oCSMetaSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $DirectGetUrlResponseApplicationJson_Ocs_DataInterface {
  String get url;
}

abstract class DirectGetUrlResponseApplicationJson_Ocs_Data
    implements
        $DirectGetUrlResponseApplicationJson_Ocs_DataInterface,
        Built<DirectGetUrlResponseApplicationJson_Ocs_Data, DirectGetUrlResponseApplicationJson_Ocs_DataBuilder> {
  factory DirectGetUrlResponseApplicationJson_Ocs_Data([
    void Function(DirectGetUrlResponseApplicationJson_Ocs_DataBuilder)? b,
  ]) = _$DirectGetUrlResponseApplicationJson_Ocs_Data;

  // coverage:ignore-start
  const DirectGetUrlResponseApplicationJson_Ocs_Data._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory DirectGetUrlResponseApplicationJson_Ocs_Data.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<DirectGetUrlResponseApplicationJson_Ocs_Data> get serializer =>
      _$directGetUrlResponseApplicationJsonOcsDataSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $DirectGetUrlResponseApplicationJson_OcsInterface {
  OCSMeta get meta;
  DirectGetUrlResponseApplicationJson_Ocs_Data get data;
}

abstract class DirectGetUrlResponseApplicationJson_Ocs
    implements
        $DirectGetUrlResponseApplicationJson_OcsInterface,
        Built<DirectGetUrlResponseApplicationJson_Ocs, DirectGetUrlResponseApplicationJson_OcsBuilder> {
  factory DirectGetUrlResponseApplicationJson_Ocs([void Function(DirectGetUrlResponseApplicationJson_OcsBuilder)? b]) =
      _$DirectGetUrlResponseApplicationJson_Ocs;

  // coverage:ignore-start
  const DirectGetUrlResponseApplicationJson_Ocs._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory DirectGetUrlResponseApplicationJson_Ocs.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<DirectGetUrlResponseApplicationJson_Ocs> get serializer =>
      _$directGetUrlResponseApplicationJsonOcsSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $DirectGetUrlResponseApplicationJsonInterface {
  DirectGetUrlResponseApplicationJson_Ocs get ocs;
}

abstract class DirectGetUrlResponseApplicationJson
    implements
        $DirectGetUrlResponseApplicationJsonInterface,
        Built<DirectGetUrlResponseApplicationJson, DirectGetUrlResponseApplicationJsonBuilder> {
  factory DirectGetUrlResponseApplicationJson([void Function(DirectGetUrlResponseApplicationJsonBuilder)? b]) =
      _$DirectGetUrlResponseApplicationJson;

  // coverage:ignore-start
  const DirectGetUrlResponseApplicationJson._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory DirectGetUrlResponseApplicationJson.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<DirectGetUrlResponseApplicationJson> get serializer =>
      _$directGetUrlResponseApplicationJsonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeDataCommonInterface {
  String get userId;
  String get message;
}

abstract class OutOfOfficeDataCommon
    implements $OutOfOfficeDataCommonInterface, Built<OutOfOfficeDataCommon, OutOfOfficeDataCommonBuilder> {
  factory OutOfOfficeDataCommon([void Function(OutOfOfficeDataCommonBuilder)? b]) = _$OutOfOfficeDataCommon;

  // coverage:ignore-start
  const OutOfOfficeDataCommon._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeDataCommon.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeDataCommon> get serializer => _$outOfOfficeDataCommonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $CurrentOutOfOfficeData_1Interface {
  String get id;
  int get startDate;
  int get endDate;
  String get shortMessage;
}

@BuiltValue(instantiable: false)
abstract interface class $CurrentOutOfOfficeDataInterface
    implements $OutOfOfficeDataCommonInterface, $CurrentOutOfOfficeData_1Interface {}

abstract class CurrentOutOfOfficeData
    implements $CurrentOutOfOfficeDataInterface, Built<CurrentOutOfOfficeData, CurrentOutOfOfficeDataBuilder> {
  factory CurrentOutOfOfficeData([void Function(CurrentOutOfOfficeDataBuilder)? b]) = _$CurrentOutOfOfficeData;

  // coverage:ignore-start
  const CurrentOutOfOfficeData._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory CurrentOutOfOfficeData.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<CurrentOutOfOfficeData> get serializer => _$currentOutOfOfficeDataSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_OcsInterface {
  OCSMeta get meta;
  CurrentOutOfOfficeData get data;
}

abstract class OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs
    implements
        $OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_OcsInterface,
        Built<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs,
            OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_OcsBuilder> {
  factory OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs([
    void Function(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_OcsBuilder)? b,
  ]) = _$OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs;

  // coverage:ignore-start
  const OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs> get serializer =>
      _$outOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonOcsSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonInterface {
  OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs get ocs;
}

abstract class OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson
    implements
        $OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonInterface,
        Built<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson,
            OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonBuilder> {
  factory OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson([
    void Function(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonBuilder)? b,
  ]) = _$OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson;

  // coverage:ignore-start
  const OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson> get serializer =>
      _$outOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeData_1Interface {
  int get id;
  String get firstDay;
  String get lastDay;
  String get status;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeDataInterface
    implements $OutOfOfficeDataCommonInterface, $OutOfOfficeData_1Interface {}

abstract class OutOfOfficeData implements $OutOfOfficeDataInterface, Built<OutOfOfficeData, OutOfOfficeDataBuilder> {
  factory OutOfOfficeData([void Function(OutOfOfficeDataBuilder)? b]) = _$OutOfOfficeData;

  // coverage:ignore-start
  const OutOfOfficeData._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeData.fromJson(Map<String, dynamic> json) => jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeData> get serializer => _$outOfOfficeDataSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeGetOutOfOfficeResponseApplicationJson_OcsInterface {
  OCSMeta get meta;
  OutOfOfficeData get data;
}

abstract class OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs
    implements
        $OutOfOfficeGetOutOfOfficeResponseApplicationJson_OcsInterface,
        Built<OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs,
            OutOfOfficeGetOutOfOfficeResponseApplicationJson_OcsBuilder> {
  factory OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs([
    void Function(OutOfOfficeGetOutOfOfficeResponseApplicationJson_OcsBuilder)? b,
  ]) = _$OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs;

  // coverage:ignore-start
  const OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs> get serializer =>
      _$outOfOfficeGetOutOfOfficeResponseApplicationJsonOcsSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeGetOutOfOfficeResponseApplicationJsonInterface {
  OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs get ocs;
}

abstract class OutOfOfficeGetOutOfOfficeResponseApplicationJson
    implements
        $OutOfOfficeGetOutOfOfficeResponseApplicationJsonInterface,
        Built<OutOfOfficeGetOutOfOfficeResponseApplicationJson,
            OutOfOfficeGetOutOfOfficeResponseApplicationJsonBuilder> {
  factory OutOfOfficeGetOutOfOfficeResponseApplicationJson([
    void Function(OutOfOfficeGetOutOfOfficeResponseApplicationJsonBuilder)? b,
  ]) = _$OutOfOfficeGetOutOfOfficeResponseApplicationJson;

  // coverage:ignore-start
  const OutOfOfficeGetOutOfOfficeResponseApplicationJson._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeGetOutOfOfficeResponseApplicationJson.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeGetOutOfOfficeResponseApplicationJson> get serializer =>
      _$outOfOfficeGetOutOfOfficeResponseApplicationJsonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeSetOutOfOfficeResponseApplicationJson_OcsInterface {
  OCSMeta get meta;
  OutOfOfficeData get data;
}

abstract class OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs
    implements
        $OutOfOfficeSetOutOfOfficeResponseApplicationJson_OcsInterface,
        Built<OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs,
            OutOfOfficeSetOutOfOfficeResponseApplicationJson_OcsBuilder> {
  factory OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs([
    void Function(OutOfOfficeSetOutOfOfficeResponseApplicationJson_OcsBuilder)? b,
  ]) = _$OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs;

  // coverage:ignore-start
  const OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs> get serializer =>
      _$outOfOfficeSetOutOfOfficeResponseApplicationJsonOcsSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeSetOutOfOfficeResponseApplicationJsonInterface {
  OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs get ocs;
}

abstract class OutOfOfficeSetOutOfOfficeResponseApplicationJson
    implements
        $OutOfOfficeSetOutOfOfficeResponseApplicationJsonInterface,
        Built<OutOfOfficeSetOutOfOfficeResponseApplicationJson,
            OutOfOfficeSetOutOfOfficeResponseApplicationJsonBuilder> {
  factory OutOfOfficeSetOutOfOfficeResponseApplicationJson([
    void Function(OutOfOfficeSetOutOfOfficeResponseApplicationJsonBuilder)? b,
  ]) = _$OutOfOfficeSetOutOfOfficeResponseApplicationJson;

  // coverage:ignore-start
  const OutOfOfficeSetOutOfOfficeResponseApplicationJson._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeSetOutOfOfficeResponseApplicationJson.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeSetOutOfOfficeResponseApplicationJson> get serializer =>
      _$outOfOfficeSetOutOfOfficeResponseApplicationJsonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeClearOutOfOfficeResponseApplicationJson_OcsInterface {
  OCSMeta get meta;
  JsonObject? get data;
}

abstract class OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs
    implements
        $OutOfOfficeClearOutOfOfficeResponseApplicationJson_OcsInterface,
        Built<OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs,
            OutOfOfficeClearOutOfOfficeResponseApplicationJson_OcsBuilder> {
  factory OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs([
    void Function(OutOfOfficeClearOutOfOfficeResponseApplicationJson_OcsBuilder)? b,
  ]) = _$OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs;

  // coverage:ignore-start
  const OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs> get serializer =>
      _$outOfOfficeClearOutOfOfficeResponseApplicationJsonOcsSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $OutOfOfficeClearOutOfOfficeResponseApplicationJsonInterface {
  OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs get ocs;
}

abstract class OutOfOfficeClearOutOfOfficeResponseApplicationJson
    implements
        $OutOfOfficeClearOutOfOfficeResponseApplicationJsonInterface,
        Built<OutOfOfficeClearOutOfOfficeResponseApplicationJson,
            OutOfOfficeClearOutOfOfficeResponseApplicationJsonBuilder> {
  factory OutOfOfficeClearOutOfOfficeResponseApplicationJson([
    void Function(OutOfOfficeClearOutOfOfficeResponseApplicationJsonBuilder)? b,
  ]) = _$OutOfOfficeClearOutOfOfficeResponseApplicationJson;

  // coverage:ignore-start
  const OutOfOfficeClearOutOfOfficeResponseApplicationJson._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory OutOfOfficeClearOutOfOfficeResponseApplicationJson.fromJson(Map<String, dynamic> json) =>
      jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<OutOfOfficeClearOutOfOfficeResponseApplicationJson> get serializer =>
      _$outOfOfficeClearOutOfOfficeResponseApplicationJsonSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $Capabilities_DavInterface {
  String get chunking;
  String? get bulkupload;
}

abstract class Capabilities_Dav
    implements $Capabilities_DavInterface, Built<Capabilities_Dav, Capabilities_DavBuilder> {
  factory Capabilities_Dav([void Function(Capabilities_DavBuilder)? b]) = _$Capabilities_Dav;

  // coverage:ignore-start
  const Capabilities_Dav._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory Capabilities_Dav.fromJson(Map<String, dynamic> json) => jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<Capabilities_Dav> get serializer => _$capabilitiesDavSerializer;
}

@BuiltValue(instantiable: false)
abstract interface class $CapabilitiesInterface {
  Capabilities_Dav get dav;
}

abstract class Capabilities implements $CapabilitiesInterface, Built<Capabilities, CapabilitiesBuilder> {
  factory Capabilities([void Function(CapabilitiesBuilder)? b]) = _$Capabilities;

  // coverage:ignore-start
  const Capabilities._();
  // coverage:ignore-end

  // coverage:ignore-start
  factory Capabilities.fromJson(Map<String, dynamic> json) => jsonSerializers.deserializeWith(serializer, json)!;
  // coverage:ignore-end

  // coverage:ignore-start
  Map<String, dynamic> toJson() => jsonSerializers.serializeWith(serializer, this)! as Map<String, dynamic>;
  // coverage:ignore-end

  static Serializer<Capabilities> get serializer => _$capabilitiesSerializer;
}

// coverage:ignore-start
@visibleForTesting
final Serializers serializers = (Serializers().toBuilder()
      ..addBuilderFactory(
        const FullType(DirectGetUrlResponseApplicationJson),
        DirectGetUrlResponseApplicationJsonBuilder.new,
      )
      ..add(DirectGetUrlResponseApplicationJson.serializer)
      ..addBuilderFactory(
        const FullType(DirectGetUrlResponseApplicationJson_Ocs),
        DirectGetUrlResponseApplicationJson_OcsBuilder.new,
      )
      ..add(DirectGetUrlResponseApplicationJson_Ocs.serializer)
      ..addBuilderFactory(const FullType(OCSMeta), OCSMetaBuilder.new)
      ..add(OCSMeta.serializer)
      ..addBuilderFactory(
        const FullType(DirectGetUrlResponseApplicationJson_Ocs_Data),
        DirectGetUrlResponseApplicationJson_Ocs_DataBuilder.new,
      )
      ..add(DirectGetUrlResponseApplicationJson_Ocs_Data.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson),
        OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJsonBuilder.new,
      )
      ..add(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs),
        OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_OcsBuilder.new,
      )
      ..add(OutOfOfficeGetCurrentOutOfOfficeDataResponseApplicationJson_Ocs.serializer)
      ..addBuilderFactory(const FullType(CurrentOutOfOfficeData), CurrentOutOfOfficeDataBuilder.new)
      ..add(CurrentOutOfOfficeData.serializer)
      ..addBuilderFactory(const FullType(OutOfOfficeDataCommon), OutOfOfficeDataCommonBuilder.new)
      ..add(OutOfOfficeDataCommon.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeGetOutOfOfficeResponseApplicationJson),
        OutOfOfficeGetOutOfOfficeResponseApplicationJsonBuilder.new,
      )
      ..add(OutOfOfficeGetOutOfOfficeResponseApplicationJson.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs),
        OutOfOfficeGetOutOfOfficeResponseApplicationJson_OcsBuilder.new,
      )
      ..add(OutOfOfficeGetOutOfOfficeResponseApplicationJson_Ocs.serializer)
      ..addBuilderFactory(const FullType(OutOfOfficeData), OutOfOfficeDataBuilder.new)
      ..add(OutOfOfficeData.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeSetOutOfOfficeResponseApplicationJson),
        OutOfOfficeSetOutOfOfficeResponseApplicationJsonBuilder.new,
      )
      ..add(OutOfOfficeSetOutOfOfficeResponseApplicationJson.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs),
        OutOfOfficeSetOutOfOfficeResponseApplicationJson_OcsBuilder.new,
      )
      ..add(OutOfOfficeSetOutOfOfficeResponseApplicationJson_Ocs.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeClearOutOfOfficeResponseApplicationJson),
        OutOfOfficeClearOutOfOfficeResponseApplicationJsonBuilder.new,
      )
      ..add(OutOfOfficeClearOutOfOfficeResponseApplicationJson.serializer)
      ..addBuilderFactory(
        const FullType(OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs),
        OutOfOfficeClearOutOfOfficeResponseApplicationJson_OcsBuilder.new,
      )
      ..add(OutOfOfficeClearOutOfOfficeResponseApplicationJson_Ocs.serializer)
      ..addBuilderFactory(const FullType(Capabilities), CapabilitiesBuilder.new)
      ..add(Capabilities.serializer)
      ..addBuilderFactory(const FullType(Capabilities_Dav), Capabilities_DavBuilder.new)
      ..add(Capabilities_Dav.serializer))
    .build();

@visibleForTesting
final Serializers jsonSerializers = (serializers.toBuilder()
      ..add(DynamiteDoubleSerializer())
      ..addPlugin(StandardJsonPlugin())
      ..addPlugin(const HeaderPlugin())
      ..addPlugin(const ContentStringPlugin()))
    .build();
// coverage:ignore-end
