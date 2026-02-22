// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signaling_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateRoom _$CreateRoomFromJson(Map<String, dynamic> json) => _CreateRoom(
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  totalFiles: (json['totalFiles'] as num).toInt(),
  totalSize: (json['totalSize'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CreateRoomToJson(_CreateRoom instance) =>
    <String, dynamic>{
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'totalFiles': instance.totalFiles,
      'totalSize': instance.totalSize,
      'type': instance.$type,
    };

_JoinRoom _$JoinRoomFromJson(Map<String, dynamic> json) => _JoinRoom(
  shareId: json['shareId'] as String,
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$JoinRoomToJson(_JoinRoom instance) => <String, dynamic>{
  'shareId': instance.shareId,
  'deviceName': instance.deviceName,
  'deviceType': instance.deviceType,
  'type': instance.$type,
};

_RoomCreated _$RoomCreatedFromJson(Map<String, dynamic> json) => _RoomCreated(
  shareId: json['shareId'] as String,
  clientId: json['clientId'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$RoomCreatedToJson(_RoomCreated instance) =>
    <String, dynamic>{
      'shareId': instance.shareId,
      'clientId': instance.clientId,
      'type': instance.$type,
    };

_RoomInfo _$RoomInfoFromJson(Map<String, dynamic> json) => _RoomInfo(
  ownerId: json['ownerId'] as String,
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  totalFiles: (json['totalFiles'] as num).toInt(),
  totalSize: (json['totalSize'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$RoomInfoToJson(_RoomInfo instance) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'deviceName': instance.deviceName,
  'deviceType': instance.deviceType,
  'totalFiles': instance.totalFiles,
  'totalSize': instance.totalSize,
  'type': instance.$type,
};

_PeerJoined _$PeerJoinedFromJson(Map<String, dynamic> json) => _PeerJoined(
  peerId: json['peerId'] as String,
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$PeerJoinedToJson(_PeerJoined instance) =>
    <String, dynamic>{
      'peerId': instance.peerId,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'type': instance.$type,
    };

_ExchangeEndpoints _$ExchangeEndpointsFromJson(Map<String, dynamic> json) =>
    _ExchangeEndpoints(
      targetId: json['targetId'] as String,
      endpoints: (json['endpoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      certHash: json['certHash'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$ExchangeEndpointsToJson(_ExchangeEndpoints instance) =>
    <String, dynamic>{
      'targetId': instance.targetId,
      'endpoints': instance.endpoints,
      'certHash': instance.certHash,
      'type': instance.$type,
    };

_EndpointsReceived _$EndpointsReceivedFromJson(Map<String, dynamic> json) =>
    _EndpointsReceived(
      senderId: json['senderId'] as String,
      endpoints: (json['endpoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      certHash: json['certHash'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$EndpointsReceivedToJson(_EndpointsReceived instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'endpoints': instance.endpoints,
      'certHash': instance.certHash,
      'type': instance.$type,
    };

_RoomClosed _$RoomClosedFromJson(Map<String, dynamic> json) =>
    _RoomClosed($type: json['type'] as String?);

Map<String, dynamic> _$RoomClosedToJson(_RoomClosed instance) =>
    <String, dynamic>{'type': instance.$type};

_Error _$ErrorFromJson(Map<String, dynamic> json) =>
    _Error(message: json['message'] as String, $type: json['type'] as String?);

Map<String, dynamic> _$ErrorToJson(_Error instance) => <String, dynamic>{
  'message': instance.message,
  'type': instance.$type,
};
