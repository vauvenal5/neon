// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharebymail.openapi.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract mixin class Capabilities0_FilesSharing_Sharebymail_UploadFilesDropInterfaceBuilder {
  void replace(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropInterface other);
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropInterfaceBuilder) updates);
  bool? get enabled;
  set enabled(bool? enabled);
}

class _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop
    extends Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop {
  @override
  final bool enabled;

  factory _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop(
          [void Function(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder)? updates]) =>
      (Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder()..update(updates))._build();

  _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop._({required this.enabled}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        enabled, r'Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop', 'enabled');
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop rebuild(
          void Function(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder toBuilder() =>
      Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop && enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop')
          ..add('enabled', enabled))
        .toString();
  }
}

class Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder
    implements
        Builder<Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop,
            Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder>,
        Capabilities0_FilesSharing_Sharebymail_UploadFilesDropInterfaceBuilder {
  _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(covariant bool? enabled) => _$this._enabled = enabled;

  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder();

  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop;
  }

  @override
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop build() => _build();

  _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop _build() {
    final _$result = _$v ??
        _$Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop._(
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled, r'Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop', 'enabled'));
    replace(_$result);
    return _$result;
  }
}

abstract mixin class Capabilities0_FilesSharing_Sharebymail_PasswordInterfaceBuilder {
  void replace(Capabilities0_FilesSharing_Sharebymail_PasswordInterface other);
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_PasswordInterfaceBuilder) updates);
  bool? get enabled;
  set enabled(bool? enabled);

  bool? get enforced;
  set enforced(bool? enforced);
}

class _$Capabilities0_FilesSharing_Sharebymail_Password extends Capabilities0_FilesSharing_Sharebymail_Password {
  @override
  final bool enabled;
  @override
  final bool enforced;

  factory _$Capabilities0_FilesSharing_Sharebymail_Password(
          [void Function(Capabilities0_FilesSharing_Sharebymail_PasswordBuilder)? updates]) =>
      (Capabilities0_FilesSharing_Sharebymail_PasswordBuilder()..update(updates))._build();

  _$Capabilities0_FilesSharing_Sharebymail_Password._({required this.enabled, required this.enforced}) : super._() {
    BuiltValueNullFieldError.checkNotNull(enabled, r'Capabilities0_FilesSharing_Sharebymail_Password', 'enabled');
    BuiltValueNullFieldError.checkNotNull(enforced, r'Capabilities0_FilesSharing_Sharebymail_Password', 'enforced');
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_Password rebuild(
          void Function(Capabilities0_FilesSharing_Sharebymail_PasswordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder toBuilder() =>
      Capabilities0_FilesSharing_Sharebymail_PasswordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0_FilesSharing_Sharebymail_Password &&
        enabled == other.enabled &&
        enforced == other.enforced;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, enforced.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0_FilesSharing_Sharebymail_Password')
          ..add('enabled', enabled)
          ..add('enforced', enforced))
        .toString();
  }
}

class Capabilities0_FilesSharing_Sharebymail_PasswordBuilder
    implements
        Builder<Capabilities0_FilesSharing_Sharebymail_Password,
            Capabilities0_FilesSharing_Sharebymail_PasswordBuilder>,
        Capabilities0_FilesSharing_Sharebymail_PasswordInterfaceBuilder {
  _$Capabilities0_FilesSharing_Sharebymail_Password? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(covariant bool? enabled) => _$this._enabled = enabled;

  bool? _enforced;
  bool? get enforced => _$this._enforced;
  set enforced(covariant bool? enforced) => _$this._enforced = enforced;

  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder();

  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _enforced = $v.enforced;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0_FilesSharing_Sharebymail_Password other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0_FilesSharing_Sharebymail_Password;
  }

  @override
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_PasswordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_Password build() => _build();

  _$Capabilities0_FilesSharing_Sharebymail_Password _build() {
    final _$result = _$v ??
        _$Capabilities0_FilesSharing_Sharebymail_Password._(
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled, r'Capabilities0_FilesSharing_Sharebymail_Password', 'enabled'),
            enforced: BuiltValueNullFieldError.checkNotNull(
                enforced, r'Capabilities0_FilesSharing_Sharebymail_Password', 'enforced'));
    replace(_$result);
    return _$result;
  }
}

abstract mixin class Capabilities0_FilesSharing_Sharebymail_ExpireDateInterfaceBuilder {
  void replace(Capabilities0_FilesSharing_Sharebymail_ExpireDateInterface other);
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_ExpireDateInterfaceBuilder) updates);
  bool? get enabled;
  set enabled(bool? enabled);

  bool? get enforced;
  set enforced(bool? enforced);
}

class _$Capabilities0_FilesSharing_Sharebymail_ExpireDate extends Capabilities0_FilesSharing_Sharebymail_ExpireDate {
  @override
  final bool enabled;
  @override
  final bool enforced;

  factory _$Capabilities0_FilesSharing_Sharebymail_ExpireDate(
          [void Function(Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder)? updates]) =>
      (Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder()..update(updates))._build();

  _$Capabilities0_FilesSharing_Sharebymail_ExpireDate._({required this.enabled, required this.enforced}) : super._() {
    BuiltValueNullFieldError.checkNotNull(enabled, r'Capabilities0_FilesSharing_Sharebymail_ExpireDate', 'enabled');
    BuiltValueNullFieldError.checkNotNull(enforced, r'Capabilities0_FilesSharing_Sharebymail_ExpireDate', 'enforced');
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_ExpireDate rebuild(
          void Function(Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder toBuilder() =>
      Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0_FilesSharing_Sharebymail_ExpireDate &&
        enabled == other.enabled &&
        enforced == other.enforced;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, enforced.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0_FilesSharing_Sharebymail_ExpireDate')
          ..add('enabled', enabled)
          ..add('enforced', enforced))
        .toString();
  }
}

class Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder
    implements
        Builder<Capabilities0_FilesSharing_Sharebymail_ExpireDate,
            Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder>,
        Capabilities0_FilesSharing_Sharebymail_ExpireDateInterfaceBuilder {
  _$Capabilities0_FilesSharing_Sharebymail_ExpireDate? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(covariant bool? enabled) => _$this._enabled = enabled;

  bool? _enforced;
  bool? get enforced => _$this._enforced;
  set enforced(covariant bool? enforced) => _$this._enforced = enforced;

  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder();

  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _enforced = $v.enforced;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0_FilesSharing_Sharebymail_ExpireDate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0_FilesSharing_Sharebymail_ExpireDate;
  }

  @override
  void update(void Function(Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0_FilesSharing_Sharebymail_ExpireDate build() => _build();

  _$Capabilities0_FilesSharing_Sharebymail_ExpireDate _build() {
    final _$result = _$v ??
        _$Capabilities0_FilesSharing_Sharebymail_ExpireDate._(
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled, r'Capabilities0_FilesSharing_Sharebymail_ExpireDate', 'enabled'),
            enforced: BuiltValueNullFieldError.checkNotNull(
                enforced, r'Capabilities0_FilesSharing_Sharebymail_ExpireDate', 'enforced'));
    replace(_$result);
    return _$result;
  }
}

abstract mixin class Capabilities0_FilesSharing_SharebymailInterfaceBuilder {
  void replace(Capabilities0_FilesSharing_SharebymailInterface other);
  void update(void Function(Capabilities0_FilesSharing_SharebymailInterfaceBuilder) updates);
  bool? get enabled;
  set enabled(bool? enabled);

  bool? get sendPasswordByMail;
  set sendPasswordByMail(bool? sendPasswordByMail);

  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder get uploadFilesDrop;
  set uploadFilesDrop(Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder? uploadFilesDrop);

  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder get password;
  set password(Capabilities0_FilesSharing_Sharebymail_PasswordBuilder? password);

  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder get expireDate;
  set expireDate(Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder? expireDate);
}

class _$Capabilities0_FilesSharing_Sharebymail extends Capabilities0_FilesSharing_Sharebymail {
  @override
  final bool enabled;
  @override
  final bool sendPasswordByMail;
  @override
  final Capabilities0_FilesSharing_Sharebymail_UploadFilesDrop uploadFilesDrop;
  @override
  final Capabilities0_FilesSharing_Sharebymail_Password password;
  @override
  final Capabilities0_FilesSharing_Sharebymail_ExpireDate expireDate;

  factory _$Capabilities0_FilesSharing_Sharebymail(
          [void Function(Capabilities0_FilesSharing_SharebymailBuilder)? updates]) =>
      (Capabilities0_FilesSharing_SharebymailBuilder()..update(updates))._build();

  _$Capabilities0_FilesSharing_Sharebymail._(
      {required this.enabled,
      required this.sendPasswordByMail,
      required this.uploadFilesDrop,
      required this.password,
      required this.expireDate})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(enabled, r'Capabilities0_FilesSharing_Sharebymail', 'enabled');
    BuiltValueNullFieldError.checkNotNull(
        sendPasswordByMail, r'Capabilities0_FilesSharing_Sharebymail', 'sendPasswordByMail');
    BuiltValueNullFieldError.checkNotNull(
        uploadFilesDrop, r'Capabilities0_FilesSharing_Sharebymail', 'uploadFilesDrop');
    BuiltValueNullFieldError.checkNotNull(password, r'Capabilities0_FilesSharing_Sharebymail', 'password');
    BuiltValueNullFieldError.checkNotNull(expireDate, r'Capabilities0_FilesSharing_Sharebymail', 'expireDate');
  }

  @override
  Capabilities0_FilesSharing_Sharebymail rebuild(
          void Function(Capabilities0_FilesSharing_SharebymailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Capabilities0_FilesSharing_SharebymailBuilder toBuilder() =>
      Capabilities0_FilesSharing_SharebymailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0_FilesSharing_Sharebymail &&
        enabled == other.enabled &&
        sendPasswordByMail == other.sendPasswordByMail &&
        uploadFilesDrop == other.uploadFilesDrop &&
        password == other.password &&
        expireDate == other.expireDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, sendPasswordByMail.hashCode);
    _$hash = $jc(_$hash, uploadFilesDrop.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, expireDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0_FilesSharing_Sharebymail')
          ..add('enabled', enabled)
          ..add('sendPasswordByMail', sendPasswordByMail)
          ..add('uploadFilesDrop', uploadFilesDrop)
          ..add('password', password)
          ..add('expireDate', expireDate))
        .toString();
  }
}

class Capabilities0_FilesSharing_SharebymailBuilder
    implements
        Builder<Capabilities0_FilesSharing_Sharebymail, Capabilities0_FilesSharing_SharebymailBuilder>,
        Capabilities0_FilesSharing_SharebymailInterfaceBuilder {
  _$Capabilities0_FilesSharing_Sharebymail? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(covariant bool? enabled) => _$this._enabled = enabled;

  bool? _sendPasswordByMail;
  bool? get sendPasswordByMail => _$this._sendPasswordByMail;
  set sendPasswordByMail(covariant bool? sendPasswordByMail) => _$this._sendPasswordByMail = sendPasswordByMail;

  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder? _uploadFilesDrop;
  Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder get uploadFilesDrop =>
      _$this._uploadFilesDrop ??= Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder();
  set uploadFilesDrop(covariant Capabilities0_FilesSharing_Sharebymail_UploadFilesDropBuilder? uploadFilesDrop) =>
      _$this._uploadFilesDrop = uploadFilesDrop;

  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder? _password;
  Capabilities0_FilesSharing_Sharebymail_PasswordBuilder get password =>
      _$this._password ??= Capabilities0_FilesSharing_Sharebymail_PasswordBuilder();
  set password(covariant Capabilities0_FilesSharing_Sharebymail_PasswordBuilder? password) =>
      _$this._password = password;

  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder? _expireDate;
  Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder get expireDate =>
      _$this._expireDate ??= Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder();
  set expireDate(covariant Capabilities0_FilesSharing_Sharebymail_ExpireDateBuilder? expireDate) =>
      _$this._expireDate = expireDate;

  Capabilities0_FilesSharing_SharebymailBuilder();

  Capabilities0_FilesSharing_SharebymailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _sendPasswordByMail = $v.sendPasswordByMail;
      _uploadFilesDrop = $v.uploadFilesDrop.toBuilder();
      _password = $v.password.toBuilder();
      _expireDate = $v.expireDate.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0_FilesSharing_Sharebymail other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0_FilesSharing_Sharebymail;
  }

  @override
  void update(void Function(Capabilities0_FilesSharing_SharebymailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0_FilesSharing_Sharebymail build() => _build();

  _$Capabilities0_FilesSharing_Sharebymail _build() {
    _$Capabilities0_FilesSharing_Sharebymail _$result;
    try {
      _$result = _$v ??
          _$Capabilities0_FilesSharing_Sharebymail._(
              enabled:
                  BuiltValueNullFieldError.checkNotNull(enabled, r'Capabilities0_FilesSharing_Sharebymail', 'enabled'),
              sendPasswordByMail: BuiltValueNullFieldError.checkNotNull(
                  sendPasswordByMail, r'Capabilities0_FilesSharing_Sharebymail', 'sendPasswordByMail'),
              uploadFilesDrop: uploadFilesDrop.build(),
              password: password.build(),
              expireDate: expireDate.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'uploadFilesDrop';
        uploadFilesDrop.build();
        _$failedField = 'password';
        password.build();
        _$failedField = 'expireDate';
        expireDate.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Capabilities0_FilesSharing_Sharebymail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

abstract mixin class Capabilities0_FilesSharingInterfaceBuilder {
  void replace(Capabilities0_FilesSharingInterface other);
  void update(void Function(Capabilities0_FilesSharingInterfaceBuilder) updates);
  Capabilities0_FilesSharing_SharebymailBuilder get sharebymail;
  set sharebymail(Capabilities0_FilesSharing_SharebymailBuilder? sharebymail);
}

class _$Capabilities0_FilesSharing extends Capabilities0_FilesSharing {
  @override
  final Capabilities0_FilesSharing_Sharebymail sharebymail;

  factory _$Capabilities0_FilesSharing([void Function(Capabilities0_FilesSharingBuilder)? updates]) =>
      (Capabilities0_FilesSharingBuilder()..update(updates))._build();

  _$Capabilities0_FilesSharing._({required this.sharebymail}) : super._() {
    BuiltValueNullFieldError.checkNotNull(sharebymail, r'Capabilities0_FilesSharing', 'sharebymail');
  }

  @override
  Capabilities0_FilesSharing rebuild(void Function(Capabilities0_FilesSharingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Capabilities0_FilesSharingBuilder toBuilder() => Capabilities0_FilesSharingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0_FilesSharing && sharebymail == other.sharebymail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sharebymail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0_FilesSharing')..add('sharebymail', sharebymail)).toString();
  }
}

class Capabilities0_FilesSharingBuilder
    implements
        Builder<Capabilities0_FilesSharing, Capabilities0_FilesSharingBuilder>,
        Capabilities0_FilesSharingInterfaceBuilder {
  _$Capabilities0_FilesSharing? _$v;

  Capabilities0_FilesSharing_SharebymailBuilder? _sharebymail;
  Capabilities0_FilesSharing_SharebymailBuilder get sharebymail =>
      _$this._sharebymail ??= Capabilities0_FilesSharing_SharebymailBuilder();
  set sharebymail(covariant Capabilities0_FilesSharing_SharebymailBuilder? sharebymail) =>
      _$this._sharebymail = sharebymail;

  Capabilities0_FilesSharingBuilder();

  Capabilities0_FilesSharingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sharebymail = $v.sharebymail.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0_FilesSharing other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0_FilesSharing;
  }

  @override
  void update(void Function(Capabilities0_FilesSharingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0_FilesSharing build() => _build();

  _$Capabilities0_FilesSharing _build() {
    _$Capabilities0_FilesSharing _$result;
    try {
      _$result = _$v ?? _$Capabilities0_FilesSharing._(sharebymail: sharebymail.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sharebymail';
        sharebymail.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Capabilities0_FilesSharing', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

abstract mixin class Capabilities0InterfaceBuilder {
  void replace(Capabilities0Interface other);
  void update(void Function(Capabilities0InterfaceBuilder) updates);
  Capabilities0_FilesSharingBuilder get filesSharing;
  set filesSharing(Capabilities0_FilesSharingBuilder? filesSharing);
}

class _$Capabilities0 extends Capabilities0 {
  @override
  final Capabilities0_FilesSharing filesSharing;

  factory _$Capabilities0([void Function(Capabilities0Builder)? updates]) =>
      (Capabilities0Builder()..update(updates))._build();

  _$Capabilities0._({required this.filesSharing}) : super._() {
    BuiltValueNullFieldError.checkNotNull(filesSharing, r'Capabilities0', 'filesSharing');
  }

  @override
  Capabilities0 rebuild(void Function(Capabilities0Builder) updates) => (toBuilder()..update(updates)).build();

  @override
  Capabilities0Builder toBuilder() => Capabilities0Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities0 && filesSharing == other.filesSharing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, filesSharing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities0')..add('filesSharing', filesSharing)).toString();
  }
}

class Capabilities0Builder implements Builder<Capabilities0, Capabilities0Builder>, Capabilities0InterfaceBuilder {
  _$Capabilities0? _$v;

  Capabilities0_FilesSharingBuilder? _filesSharing;
  Capabilities0_FilesSharingBuilder get filesSharing => _$this._filesSharing ??= Capabilities0_FilesSharingBuilder();
  set filesSharing(covariant Capabilities0_FilesSharingBuilder? filesSharing) => _$this._filesSharing = filesSharing;

  Capabilities0Builder();

  Capabilities0Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filesSharing = $v.filesSharing.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities0 other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities0;
  }

  @override
  void update(void Function(Capabilities0Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities0 build() => _build();

  _$Capabilities0 _build() {
    _$Capabilities0 _$result;
    try {
      _$result = _$v ?? _$Capabilities0._(filesSharing: filesSharing.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'filesSharing';
        filesSharing.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Capabilities0', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

abstract mixin class CapabilitiesInterfaceBuilder {
  void replace(CapabilitiesInterface other);
  void update(void Function(CapabilitiesInterfaceBuilder) updates);
  Capabilities0Builder get capabilities0;
  set capabilities0(Capabilities0Builder? capabilities0);

  ListBuilder<JsonObject> get builtListJsonObject;
  set builtListJsonObject(ListBuilder<JsonObject>? builtListJsonObject);
}

class _$Capabilities extends Capabilities {
  @override
  final JsonObject data;
  @override
  final Capabilities0? capabilities0;
  @override
  final BuiltList<JsonObject>? builtListJsonObject;

  factory _$Capabilities([void Function(CapabilitiesBuilder)? updates]) =>
      (CapabilitiesBuilder()..update(updates))._build();

  _$Capabilities._({required this.data, this.capabilities0, this.builtListJsonObject}) : super._() {
    BuiltValueNullFieldError.checkNotNull(data, r'Capabilities', 'data');
  }

  @override
  Capabilities rebuild(void Function(CapabilitiesBuilder) updates) => (toBuilder()..update(updates)).build();

  @override
  CapabilitiesBuilder toBuilder() => CapabilitiesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Capabilities &&
        data == other.data &&
        capabilities0 == other.capabilities0 &&
        builtListJsonObject == other.builtListJsonObject;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, capabilities0.hashCode);
    _$hash = $jc(_$hash, builtListJsonObject.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Capabilities')
          ..add('data', data)
          ..add('capabilities0', capabilities0)
          ..add('builtListJsonObject', builtListJsonObject))
        .toString();
  }
}

class CapabilitiesBuilder implements Builder<Capabilities, CapabilitiesBuilder>, CapabilitiesInterfaceBuilder {
  _$Capabilities? _$v;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(covariant JsonObject? data) => _$this._data = data;

  Capabilities0Builder? _capabilities0;
  Capabilities0Builder get capabilities0 => _$this._capabilities0 ??= Capabilities0Builder();
  set capabilities0(covariant Capabilities0Builder? capabilities0) => _$this._capabilities0 = capabilities0;

  ListBuilder<JsonObject>? _builtListJsonObject;
  ListBuilder<JsonObject> get builtListJsonObject => _$this._builtListJsonObject ??= ListBuilder<JsonObject>();
  set builtListJsonObject(covariant ListBuilder<JsonObject>? builtListJsonObject) =>
      _$this._builtListJsonObject = builtListJsonObject;

  CapabilitiesBuilder();

  CapabilitiesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data;
      _capabilities0 = $v.capabilities0?.toBuilder();
      _builtListJsonObject = $v.builtListJsonObject?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant Capabilities other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Capabilities;
  }

  @override
  void update(void Function(CapabilitiesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Capabilities build() => _build();

  _$Capabilities _build() {
    Capabilities._validate(this);
    _$Capabilities _$result;
    try {
      _$result = _$v ??
          _$Capabilities._(
              data: BuiltValueNullFieldError.checkNotNull(data, r'Capabilities', 'data'),
              capabilities0: _capabilities0?.build(),
              builtListJsonObject: _builtListJsonObject?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities0';
        _capabilities0?.build();
        _$failedField = 'builtListJsonObject';
        _builtListJsonObject?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Capabilities', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
