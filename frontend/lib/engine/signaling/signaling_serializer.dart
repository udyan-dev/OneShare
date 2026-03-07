import 'message/signaling_message.dart';

class SignalingSerializer {
  static List<dynamic> encode(SignalingMessage message) {
    return message.map(
      createRoom: (m) => [
        0,
        m.deviceName,
        m.deviceType,
        m.totalFiles,
        m.totalSize,
      ],
      joinRoom: (m) => [1, m.shareId, m.deviceName, m.deviceType],
      roomCreated: (m) => [2, m.shareId, m.clientId],
      roomInfo: (m) => [
        3,
        m.ownerId,
        m.deviceName,
        m.deviceType,
        m.totalFiles,
        m.totalSize,
      ],
      peerJoined: (m) => [4, m.peerId, m.deviceName, m.deviceType],
      exchangeEndpoints: (m) => [5, m.targetId, m.endpoints, m.certHash],
      endpointsReceived: (m) => [6, m.senderId, m.endpoints, m.certHash],
      roomClosed: (_) => [7],
      error: (m) => [8, m.message],
    );
  }

  static SignalingMessage? decode(dynamic data) {
    if (data is! List || data.isEmpty || data[0] is! int) return null;

    String s(int idx) => idx < data.length ? data[idx]?.toString() ?? '' : '';
    int i(int idx) =>
        idx < data.length && data[idx] is int ? data[idx] as int : 0;
    List<String> l(int idx) {
      if (idx >= data.length || data[idx] is! List) return const [];
      return (data[idx] as List).whereType<String>().toList(growable: false);
    }

    switch (data[0] as int) {
      case 0:
        return SignalingMessage.createRoom(
          deviceName: s(1),
          deviceType: s(2),
          totalFiles: i(3),
          totalSize: i(4),
        );
      case 1:
        return SignalingMessage.joinRoom(
          shareId: s(1),
          deviceName: s(2),
          deviceType: s(3),
        );
      case 2:
        return SignalingMessage.roomCreated(shareId: s(1), clientId: s(2));
      case 3:
        return SignalingMessage.roomInfo(
          ownerId: s(1),
          deviceName: s(2),
          deviceType: s(3),
          totalFiles: i(4),
          totalSize: i(5),
        );
      case 4:
        return SignalingMessage.peerJoined(
          peerId: s(1),
          deviceName: s(2),
          deviceType: s(3),
        );
      case 5:
        return SignalingMessage.exchangeEndpoints(
          targetId: s(1),
          endpoints: l(2),
          certHash: s(3),
        );
      case 6:
        return SignalingMessage.endpointsReceived(
          senderId: s(1),
          endpoints: l(2),
          certHash: s(3),
        );
      case 7:
        return const SignalingMessage.roomClosed();
      case 8:
        return SignalingMessage.error(message: s(1));
      default:
        return null;
    }
  }
}
