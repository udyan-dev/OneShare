import 'package:freezed_annotation/freezed_annotation.dart';

part 'signaling_message.freezed.dart';

part 'signaling_message.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.pascal)
abstract class SignalingMessage with _$SignalingMessage {
  const factory SignalingMessage.createRoom({
    required String deviceName,
    required String deviceType,
    required int totalFiles,
    required int totalSize,
  }) = _CreateRoom;

  const factory SignalingMessage.joinRoom({
    required String shareId,
    required String deviceName,
    required String deviceType,
  }) = _JoinRoom;

  const factory SignalingMessage.roomCreated({
    required String shareId,
    required String clientId,
  }) = _RoomCreated;

  const factory SignalingMessage.roomInfo({
    required String ownerId,
    required String deviceName,
    required String deviceType,
    required int totalFiles,
    required int totalSize,
  }) = _RoomInfo;

  const factory SignalingMessage.peerJoined({
    required String peerId,
    required String deviceName,
    required String deviceType,
  }) = _PeerJoined;

  const factory SignalingMessage.exchangeEndpoints({
    required String targetId,
    required List<String> endpoints,
    required String certHash,
  }) = _ExchangeEndpoints;

  const factory SignalingMessage.endpointsReceived({
    required String senderId,
    required List<String> endpoints,
    required String certHash,
  }) = _EndpointsReceived;

  const factory SignalingMessage.roomClosed() = _RoomClosed;

  const factory SignalingMessage.error({required String message}) = _Error;

  factory SignalingMessage.fromJson(Map<String, dynamic> json) =>
      _$SignalingMessageFromJson(json);
}