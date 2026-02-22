// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signaling_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SignalingMessage _$SignalingMessageFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'CreateRoom':
          return _CreateRoom.fromJson(
            json
          );
                case 'JoinRoom':
          return _JoinRoom.fromJson(
            json
          );
                case 'RoomCreated':
          return _RoomCreated.fromJson(
            json
          );
                case 'RoomInfo':
          return _RoomInfo.fromJson(
            json
          );
                case 'PeerJoined':
          return _PeerJoined.fromJson(
            json
          );
                case 'ExchangeEndpoints':
          return _ExchangeEndpoints.fromJson(
            json
          );
                case 'EndpointsReceived':
          return _EndpointsReceived.fromJson(
            json
          );
                case 'RoomClosed':
          return _RoomClosed.fromJson(
            json
          );
                case 'Error':
          return _Error.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'SignalingMessage',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$SignalingMessage {



  /// Serializes this SignalingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignalingMessage);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignalingMessage()';
}


}

/// @nodoc
class $SignalingMessageCopyWith<$Res>  {
$SignalingMessageCopyWith(SignalingMessage _, $Res Function(SignalingMessage) __);
}


/// Adds pattern-matching-related methods to [SignalingMessage].
extension SignalingMessagePatterns on SignalingMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CreateRoom value)?  createRoom,TResult Function( _JoinRoom value)?  joinRoom,TResult Function( _RoomCreated value)?  roomCreated,TResult Function( _RoomInfo value)?  roomInfo,TResult Function( _PeerJoined value)?  peerJoined,TResult Function( _ExchangeEndpoints value)?  exchangeEndpoints,TResult Function( _EndpointsReceived value)?  endpointsReceived,TResult Function( _RoomClosed value)?  roomClosed,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRoom() when createRoom != null:
return createRoom(_that);case _JoinRoom() when joinRoom != null:
return joinRoom(_that);case _RoomCreated() when roomCreated != null:
return roomCreated(_that);case _RoomInfo() when roomInfo != null:
return roomInfo(_that);case _PeerJoined() when peerJoined != null:
return peerJoined(_that);case _ExchangeEndpoints() when exchangeEndpoints != null:
return exchangeEndpoints(_that);case _EndpointsReceived() when endpointsReceived != null:
return endpointsReceived(_that);case _RoomClosed() when roomClosed != null:
return roomClosed(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CreateRoom value)  createRoom,required TResult Function( _JoinRoom value)  joinRoom,required TResult Function( _RoomCreated value)  roomCreated,required TResult Function( _RoomInfo value)  roomInfo,required TResult Function( _PeerJoined value)  peerJoined,required TResult Function( _ExchangeEndpoints value)  exchangeEndpoints,required TResult Function( _EndpointsReceived value)  endpointsReceived,required TResult Function( _RoomClosed value)  roomClosed,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _CreateRoom():
return createRoom(_that);case _JoinRoom():
return joinRoom(_that);case _RoomCreated():
return roomCreated(_that);case _RoomInfo():
return roomInfo(_that);case _PeerJoined():
return peerJoined(_that);case _ExchangeEndpoints():
return exchangeEndpoints(_that);case _EndpointsReceived():
return endpointsReceived(_that);case _RoomClosed():
return roomClosed(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CreateRoom value)?  createRoom,TResult? Function( _JoinRoom value)?  joinRoom,TResult? Function( _RoomCreated value)?  roomCreated,TResult? Function( _RoomInfo value)?  roomInfo,TResult? Function( _PeerJoined value)?  peerJoined,TResult? Function( _ExchangeEndpoints value)?  exchangeEndpoints,TResult? Function( _EndpointsReceived value)?  endpointsReceived,TResult? Function( _RoomClosed value)?  roomClosed,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _CreateRoom() when createRoom != null:
return createRoom(_that);case _JoinRoom() when joinRoom != null:
return joinRoom(_that);case _RoomCreated() when roomCreated != null:
return roomCreated(_that);case _RoomInfo() when roomInfo != null:
return roomInfo(_that);case _PeerJoined() when peerJoined != null:
return peerJoined(_that);case _ExchangeEndpoints() when exchangeEndpoints != null:
return exchangeEndpoints(_that);case _EndpointsReceived() when endpointsReceived != null:
return endpointsReceived(_that);case _RoomClosed() when roomClosed != null:
return roomClosed(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String deviceName,  String deviceType,  int totalFiles,  int totalSize)?  createRoom,TResult Function( String shareId,  String deviceName,  String deviceType)?  joinRoom,TResult Function( String shareId,  String clientId)?  roomCreated,TResult Function( String ownerId,  String deviceName,  String deviceType,  int totalFiles,  int totalSize)?  roomInfo,TResult Function( String peerId,  String deviceName,  String deviceType)?  peerJoined,TResult Function( String targetId,  List<String> endpoints,  String certHash)?  exchangeEndpoints,TResult Function( String senderId,  List<String> endpoints,  String certHash)?  endpointsReceived,TResult Function()?  roomClosed,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRoom() when createRoom != null:
return createRoom(_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _JoinRoom() when joinRoom != null:
return joinRoom(_that.shareId,_that.deviceName,_that.deviceType);case _RoomCreated() when roomCreated != null:
return roomCreated(_that.shareId,_that.clientId);case _RoomInfo() when roomInfo != null:
return roomInfo(_that.ownerId,_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _PeerJoined() when peerJoined != null:
return peerJoined(_that.peerId,_that.deviceName,_that.deviceType);case _ExchangeEndpoints() when exchangeEndpoints != null:
return exchangeEndpoints(_that.targetId,_that.endpoints,_that.certHash);case _EndpointsReceived() when endpointsReceived != null:
return endpointsReceived(_that.senderId,_that.endpoints,_that.certHash);case _RoomClosed() when roomClosed != null:
return roomClosed();case _Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String deviceName,  String deviceType,  int totalFiles,  int totalSize)  createRoom,required TResult Function( String shareId,  String deviceName,  String deviceType)  joinRoom,required TResult Function( String shareId,  String clientId)  roomCreated,required TResult Function( String ownerId,  String deviceName,  String deviceType,  int totalFiles,  int totalSize)  roomInfo,required TResult Function( String peerId,  String deviceName,  String deviceType)  peerJoined,required TResult Function( String targetId,  List<String> endpoints,  String certHash)  exchangeEndpoints,required TResult Function( String senderId,  List<String> endpoints,  String certHash)  endpointsReceived,required TResult Function()  roomClosed,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CreateRoom():
return createRoom(_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _JoinRoom():
return joinRoom(_that.shareId,_that.deviceName,_that.deviceType);case _RoomCreated():
return roomCreated(_that.shareId,_that.clientId);case _RoomInfo():
return roomInfo(_that.ownerId,_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _PeerJoined():
return peerJoined(_that.peerId,_that.deviceName,_that.deviceType);case _ExchangeEndpoints():
return exchangeEndpoints(_that.targetId,_that.endpoints,_that.certHash);case _EndpointsReceived():
return endpointsReceived(_that.senderId,_that.endpoints,_that.certHash);case _RoomClosed():
return roomClosed();case _Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String deviceName,  String deviceType,  int totalFiles,  int totalSize)?  createRoom,TResult? Function( String shareId,  String deviceName,  String deviceType)?  joinRoom,TResult? Function( String shareId,  String clientId)?  roomCreated,TResult? Function( String ownerId,  String deviceName,  String deviceType,  int totalFiles,  int totalSize)?  roomInfo,TResult? Function( String peerId,  String deviceName,  String deviceType)?  peerJoined,TResult? Function( String targetId,  List<String> endpoints,  String certHash)?  exchangeEndpoints,TResult? Function( String senderId,  List<String> endpoints,  String certHash)?  endpointsReceived,TResult? Function()?  roomClosed,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CreateRoom() when createRoom != null:
return createRoom(_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _JoinRoom() when joinRoom != null:
return joinRoom(_that.shareId,_that.deviceName,_that.deviceType);case _RoomCreated() when roomCreated != null:
return roomCreated(_that.shareId,_that.clientId);case _RoomInfo() when roomInfo != null:
return roomInfo(_that.ownerId,_that.deviceName,_that.deviceType,_that.totalFiles,_that.totalSize);case _PeerJoined() when peerJoined != null:
return peerJoined(_that.peerId,_that.deviceName,_that.deviceType);case _ExchangeEndpoints() when exchangeEndpoints != null:
return exchangeEndpoints(_that.targetId,_that.endpoints,_that.certHash);case _EndpointsReceived() when endpointsReceived != null:
return endpointsReceived(_that.senderId,_that.endpoints,_that.certHash);case _RoomClosed() when roomClosed != null:
return roomClosed();case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRoom implements SignalingMessage {
  const _CreateRoom({required this.deviceName, required this.deviceType, required this.totalFiles, required this.totalSize, final  String? $type}): $type = $type ?? 'CreateRoom';
  factory _CreateRoom.fromJson(Map<String, dynamic> json) => _$CreateRoomFromJson(json);

 final  String deviceName;
 final  String deviceType;
 final  int totalFiles;
 final  int totalSize;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRoomCopyWith<_CreateRoom> get copyWith => __$CreateRoomCopyWithImpl<_CreateRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRoom&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceName,deviceType,totalFiles,totalSize);

@override
String toString() {
  return 'SignalingMessage.createRoom(deviceName: $deviceName, deviceType: $deviceType, totalFiles: $totalFiles, totalSize: $totalSize)';
}


}

/// @nodoc
abstract mixin class _$CreateRoomCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$CreateRoomCopyWith(_CreateRoom value, $Res Function(_CreateRoom) _then) = __$CreateRoomCopyWithImpl;
@useResult
$Res call({
 String deviceName, String deviceType, int totalFiles, int totalSize
});




}
/// @nodoc
class __$CreateRoomCopyWithImpl<$Res>
    implements _$CreateRoomCopyWith<$Res> {
  __$CreateRoomCopyWithImpl(this._self, this._then);

  final _CreateRoom _self;
  final $Res Function(_CreateRoom) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? deviceName = null,Object? deviceType = null,Object? totalFiles = null,Object? totalSize = null,}) {
  return _then(_CreateRoom(
deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _JoinRoom implements SignalingMessage {
  const _JoinRoom({required this.shareId, required this.deviceName, required this.deviceType, final  String? $type}): $type = $type ?? 'JoinRoom';
  factory _JoinRoom.fromJson(Map<String, dynamic> json) => _$JoinRoomFromJson(json);

 final  String shareId;
 final  String deviceName;
 final  String deviceType;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRoomCopyWith<_JoinRoom> get copyWith => __$JoinRoomCopyWithImpl<_JoinRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRoom&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareId,deviceName,deviceType);

@override
String toString() {
  return 'SignalingMessage.joinRoom(shareId: $shareId, deviceName: $deviceName, deviceType: $deviceType)';
}


}

/// @nodoc
abstract mixin class _$JoinRoomCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$JoinRoomCopyWith(_JoinRoom value, $Res Function(_JoinRoom) _then) = __$JoinRoomCopyWithImpl;
@useResult
$Res call({
 String shareId, String deviceName, String deviceType
});




}
/// @nodoc
class __$JoinRoomCopyWithImpl<$Res>
    implements _$JoinRoomCopyWith<$Res> {
  __$JoinRoomCopyWithImpl(this._self, this._then);

  final _JoinRoom _self;
  final $Res Function(_JoinRoom) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? shareId = null,Object? deviceName = null,Object? deviceType = null,}) {
  return _then(_JoinRoom(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _RoomCreated implements SignalingMessage {
  const _RoomCreated({required this.shareId, required this.clientId, final  String? $type}): $type = $type ?? 'RoomCreated';
  factory _RoomCreated.fromJson(Map<String, dynamic> json) => _$RoomCreatedFromJson(json);

 final  String shareId;
 final  String clientId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCreatedCopyWith<_RoomCreated> get copyWith => __$RoomCreatedCopyWithImpl<_RoomCreated>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomCreatedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomCreated&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.clientId, clientId) || other.clientId == clientId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareId,clientId);

@override
String toString() {
  return 'SignalingMessage.roomCreated(shareId: $shareId, clientId: $clientId)';
}


}

/// @nodoc
abstract mixin class _$RoomCreatedCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$RoomCreatedCopyWith(_RoomCreated value, $Res Function(_RoomCreated) _then) = __$RoomCreatedCopyWithImpl;
@useResult
$Res call({
 String shareId, String clientId
});




}
/// @nodoc
class __$RoomCreatedCopyWithImpl<$Res>
    implements _$RoomCreatedCopyWith<$Res> {
  __$RoomCreatedCopyWithImpl(this._self, this._then);

  final _RoomCreated _self;
  final $Res Function(_RoomCreated) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? shareId = null,Object? clientId = null,}) {
  return _then(_RoomCreated(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _RoomInfo implements SignalingMessage {
  const _RoomInfo({required this.ownerId, required this.deviceName, required this.deviceType, required this.totalFiles, required this.totalSize, final  String? $type}): $type = $type ?? 'RoomInfo';
  factory _RoomInfo.fromJson(Map<String, dynamic> json) => _$RoomInfoFromJson(json);

 final  String ownerId;
 final  String deviceName;
 final  String deviceType;
 final  int totalFiles;
 final  int totalSize;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomInfoCopyWith<_RoomInfo> get copyWith => __$RoomInfoCopyWithImpl<_RoomInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomInfo&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerId,deviceName,deviceType,totalFiles,totalSize);

@override
String toString() {
  return 'SignalingMessage.roomInfo(ownerId: $ownerId, deviceName: $deviceName, deviceType: $deviceType, totalFiles: $totalFiles, totalSize: $totalSize)';
}


}

/// @nodoc
abstract mixin class _$RoomInfoCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$RoomInfoCopyWith(_RoomInfo value, $Res Function(_RoomInfo) _then) = __$RoomInfoCopyWithImpl;
@useResult
$Res call({
 String ownerId, String deviceName, String deviceType, int totalFiles, int totalSize
});




}
/// @nodoc
class __$RoomInfoCopyWithImpl<$Res>
    implements _$RoomInfoCopyWith<$Res> {
  __$RoomInfoCopyWithImpl(this._self, this._then);

  final _RoomInfo _self;
  final $Res Function(_RoomInfo) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ownerId = null,Object? deviceName = null,Object? deviceType = null,Object? totalFiles = null,Object? totalSize = null,}) {
  return _then(_RoomInfo(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _PeerJoined implements SignalingMessage {
  const _PeerJoined({required this.peerId, required this.deviceName, required this.deviceType, final  String? $type}): $type = $type ?? 'PeerJoined';
  factory _PeerJoined.fromJson(Map<String, dynamic> json) => _$PeerJoinedFromJson(json);

 final  String peerId;
 final  String deviceName;
 final  String deviceType;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeerJoinedCopyWith<_PeerJoined> get copyWith => __$PeerJoinedCopyWithImpl<_PeerJoined>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeerJoinedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeerJoined&&(identical(other.peerId, peerId) || other.peerId == peerId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,peerId,deviceName,deviceType);

@override
String toString() {
  return 'SignalingMessage.peerJoined(peerId: $peerId, deviceName: $deviceName, deviceType: $deviceType)';
}


}

/// @nodoc
abstract mixin class _$PeerJoinedCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$PeerJoinedCopyWith(_PeerJoined value, $Res Function(_PeerJoined) _then) = __$PeerJoinedCopyWithImpl;
@useResult
$Res call({
 String peerId, String deviceName, String deviceType
});




}
/// @nodoc
class __$PeerJoinedCopyWithImpl<$Res>
    implements _$PeerJoinedCopyWith<$Res> {
  __$PeerJoinedCopyWithImpl(this._self, this._then);

  final _PeerJoined _self;
  final $Res Function(_PeerJoined) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? peerId = null,Object? deviceName = null,Object? deviceType = null,}) {
  return _then(_PeerJoined(
peerId: null == peerId ? _self.peerId : peerId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceType: null == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _ExchangeEndpoints implements SignalingMessage {
  const _ExchangeEndpoints({required this.targetId, required final  List<String> endpoints, required this.certHash, final  String? $type}): _endpoints = endpoints,$type = $type ?? 'ExchangeEndpoints';
  factory _ExchangeEndpoints.fromJson(Map<String, dynamic> json) => _$ExchangeEndpointsFromJson(json);

 final  String targetId;
 final  List<String> _endpoints;
 List<String> get endpoints {
  if (_endpoints is EqualUnmodifiableListView) return _endpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_endpoints);
}

 final  String certHash;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeEndpointsCopyWith<_ExchangeEndpoints> get copyWith => __$ExchangeEndpointsCopyWithImpl<_ExchangeEndpoints>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeEndpointsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeEndpoints&&(identical(other.targetId, targetId) || other.targetId == targetId)&&const DeepCollectionEquality().equals(other._endpoints, _endpoints)&&(identical(other.certHash, certHash) || other.certHash == certHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetId,const DeepCollectionEquality().hash(_endpoints),certHash);

@override
String toString() {
  return 'SignalingMessage.exchangeEndpoints(targetId: $targetId, endpoints: $endpoints, certHash: $certHash)';
}


}

/// @nodoc
abstract mixin class _$ExchangeEndpointsCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$ExchangeEndpointsCopyWith(_ExchangeEndpoints value, $Res Function(_ExchangeEndpoints) _then) = __$ExchangeEndpointsCopyWithImpl;
@useResult
$Res call({
 String targetId, List<String> endpoints, String certHash
});




}
/// @nodoc
class __$ExchangeEndpointsCopyWithImpl<$Res>
    implements _$ExchangeEndpointsCopyWith<$Res> {
  __$ExchangeEndpointsCopyWithImpl(this._self, this._then);

  final _ExchangeEndpoints _self;
  final $Res Function(_ExchangeEndpoints) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? endpoints = null,Object? certHash = null,}) {
  return _then(_ExchangeEndpoints(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,endpoints: null == endpoints ? _self._endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<String>,certHash: null == certHash ? _self.certHash : certHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _EndpointsReceived implements SignalingMessage {
  const _EndpointsReceived({required this.senderId, required final  List<String> endpoints, required this.certHash, final  String? $type}): _endpoints = endpoints,$type = $type ?? 'EndpointsReceived';
  factory _EndpointsReceived.fromJson(Map<String, dynamic> json) => _$EndpointsReceivedFromJson(json);

 final  String senderId;
 final  List<String> _endpoints;
 List<String> get endpoints {
  if (_endpoints is EqualUnmodifiableListView) return _endpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_endpoints);
}

 final  String certHash;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EndpointsReceivedCopyWith<_EndpointsReceived> get copyWith => __$EndpointsReceivedCopyWithImpl<_EndpointsReceived>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EndpointsReceivedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EndpointsReceived&&(identical(other.senderId, senderId) || other.senderId == senderId)&&const DeepCollectionEquality().equals(other._endpoints, _endpoints)&&(identical(other.certHash, certHash) || other.certHash == certHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,senderId,const DeepCollectionEquality().hash(_endpoints),certHash);

@override
String toString() {
  return 'SignalingMessage.endpointsReceived(senderId: $senderId, endpoints: $endpoints, certHash: $certHash)';
}


}

/// @nodoc
abstract mixin class _$EndpointsReceivedCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$EndpointsReceivedCopyWith(_EndpointsReceived value, $Res Function(_EndpointsReceived) _then) = __$EndpointsReceivedCopyWithImpl;
@useResult
$Res call({
 String senderId, List<String> endpoints, String certHash
});




}
/// @nodoc
class __$EndpointsReceivedCopyWithImpl<$Res>
    implements _$EndpointsReceivedCopyWith<$Res> {
  __$EndpointsReceivedCopyWithImpl(this._self, this._then);

  final _EndpointsReceived _self;
  final $Res Function(_EndpointsReceived) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? senderId = null,Object? endpoints = null,Object? certHash = null,}) {
  return _then(_EndpointsReceived(
senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,endpoints: null == endpoints ? _self._endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<String>,certHash: null == certHash ? _self.certHash : certHash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class _RoomClosed implements SignalingMessage {
  const _RoomClosed({final  String? $type}): $type = $type ?? 'RoomClosed';
  factory _RoomClosed.fromJson(Map<String, dynamic> json) => _$RoomClosedFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$RoomClosedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomClosed);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignalingMessage.roomClosed()';
}


}




/// @nodoc
@JsonSerializable()

class _Error implements SignalingMessage {
  const _Error({required this.message, final  String? $type}): $type = $type ?? 'Error';
  factory _Error.fromJson(Map<String, dynamic> json) => _$ErrorFromJson(json);

 final  String message;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SignalingMessage.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $SignalingMessageCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of SignalingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
