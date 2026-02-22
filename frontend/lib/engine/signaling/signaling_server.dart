import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../serialization/msg_pack_decoder.dart';
import '../serialization/msg_pack_encoder.dart';
import 'message/signaling_message.dart';

enum SignalingStatus { connecting, ready, disconnected }

class SignalingServer {
  final String serverUrl;
  final Duration baseReconnectDelay;
  final Duration maxReconnectDelay;
  final Duration pingInterval;
  final int maxQueueSize;

  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;

  SignalingStatus _status = SignalingStatus.disconnected;
  int _retryCount = 0;
  bool _shouldReconnect = true;
  Timer? _reconnectTimer;

  final StreamController<SignalingMessage> _messageController =
      StreamController<SignalingMessage>.broadcast(sync: true);
  final StreamController<SignalingStatus> _statusController =
      StreamController<SignalingStatus>.broadcast(sync: true);

  final Queue<Map<String, dynamic>> _offlineQueue = Queue();

  SignalingServer({
    required this.serverUrl,
    this.baseReconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.pingInterval = const Duration(seconds: 15),
    this.maxQueueSize = 100,
  });

  Stream<SignalingMessage> get messages => _messageController.stream;
  Stream<SignalingStatus> get statusStream => _statusController.stream;
  SignalingStatus get status => _status;

  Future<void> initialize() async {
    _shouldReconnect = true;
    _offlineQueue.clear();
    await _connect();
  }

  void send(SignalingMessage message) {
    if (_status == SignalingStatus.ready && _channel != null) {
      _sendBinary(message.toJson());
    } else {
      _enqueueMessage(message.toJson());
    }
  }

  Future<void> dispose() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _offlineQueue.clear();
    await _cleanupConnection(ws_status.goingAway);
    await _messageController.close();
    await _statusController.close();
  }

  Future<void> _connect() async {
    if (_status == SignalingStatus.connecting ||
        _status == SignalingStatus.ready) {
      return;
    }

    try {
      _updateStatus(SignalingStatus.connecting);
      final timeout = Duration(seconds: (8 + _retryCount).clamp(8, 20));

      final ws = await WebSocket.connect(serverUrl).timeout(timeout);

      if (!_shouldReconnect) {
        await ws.close(ws_status.goingAway);
        return;
      }

      ws.pingInterval = pingInterval;
      _channel = IOWebSocketChannel(ws);

      _subscription = _channel!.stream.listen(
        _handleIncomingData,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );

      _retryCount = 0;
      _updateStatus(SignalingStatus.ready);
      _flushQueue();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _handleIncomingData(dynamic data) {
    if (!_messageController.hasListener) return;

    try {
      final Uint8List bytes;
      if (data is Uint8List) {
        bytes = data;
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else {
        return;
      }

      final decoded = MsgPackDecoder.decode(bytes);
      if (decoded is Map) {
        _messageController.add(
          SignalingMessage.fromJson(Map<String, dynamic>.from(decoded)),
        );
      }
    } catch (_) {}
  }

  void _sendBinary(Map<String, dynamic> msg) {
    try {
      final orderedMsg = <String, dynamic>{'type': msg['type'], ...msg};
      final raw = MsgPackEncoder.encode(orderedMsg);
      _channel?.sink.add(raw);
    } catch (_) {
      _enqueueMessage(msg);
      _scheduleReconnect();
    }
  }

  void _enqueueMessage(Map<String, dynamic> msg) {
    if (_offlineQueue.length >= maxQueueSize) _offlineQueue.removeFirst();
    _offlineQueue.add(msg);
  }

  void _flushQueue() {
    while (_offlineQueue.isNotEmpty && _status == SignalingStatus.ready) {
      _sendBinary(_offlineQueue.removeFirst());
    }
  }

  Future<void> _cleanupConnection(int closeCode) async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(closeCode);
    _channel = null;
  }

  void _scheduleReconnect() async {
    if (_status == SignalingStatus.disconnected &&
        _reconnectTimer?.isActive == true) {
      return;
    }

    await _cleanupConnection(ws_status.abnormalClosure);
    _updateStatus(SignalingStatus.disconnected);

    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _retryCount++;

    final delay =
        min(
          maxReconnectDelay.inMilliseconds,
          baseReconnectDelay.inMilliseconds * pow(2, _retryCount).toInt(),
        ) +
        Random().nextInt(1000);

    _reconnectTimer = Timer(Duration(milliseconds: delay), _connect);
  }

  void _updateStatus(SignalingStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }
}
