import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../serialization/msg_pack_decoder.dart';
import '../serialization/msg_pack_encoder.dart';
import 'message/signaling_message.dart';
import 'signaling_serializer.dart';

enum SignalingStatus { connecting, ready, disconnected }

class SignalingServer {
  final String serverUrl;
  final Duration baseReconnectDelay;
  final Duration maxReconnectDelay;
  final Duration pingInterval;
  final int maxQueueSize;

  WebSocket? _socket;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  final Random _random = Random();

  SignalingStatus _status = SignalingStatus.disconnected;
  int _retryCount = 0;
  bool _shouldReconnect = true;

  final StreamController<SignalingMessage> _messageController =
      StreamController.broadcast(sync: true);
  final StreamController<SignalingStatus> _statusController =
      StreamController.broadcast(sync: true);

  final Queue<SignalingMessage> _offlineQueue = Queue<SignalingMessage>();

  SignalingServer({
    required this.serverUrl,
    this.baseReconnectDelay = const Duration(milliseconds: 500),
    this.maxReconnectDelay = const Duration(seconds: 5),
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
    if (_status == SignalingStatus.ready && _socket != null) {
      _sendBinary(message);
    } else {
      _enqueueMessage(message);
    }
  }

  Future<void> dispose() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _offlineQueue.clear();
    await _cleanupConnection(WebSocketStatus.goingAway);
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

      final timeout = Duration(seconds: (5 + _retryCount).clamp(5, 15));
      _socket = await WebSocket.connect(serverUrl).timeout(timeout);

      if (!_shouldReconnect) {
        await _socket!.close(WebSocketStatus.goingAway);
        return;
      }

      // Explicitly ensures the backend's 60-second idle timeout is constantly refreshed.
      _socket!.pingInterval = pingInterval;
      _subscription = _socket!.listen(
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
      dynamic parsedData;

      if (data is String) {
        parsedData = jsonDecode(data);
      } else if (data is Uint8List) {
        parsedData = MsgPackDecoder.decode(data);
      } else if (data is List<int>) {
        parsedData = MsgPackDecoder.decode(Uint8List.fromList(data));
      } else {
        return;
      }

      final msg = SignalingSerializer.decode(parsedData);
      if (msg != null) {
        _messageController.add(msg);
      }
    } catch (_) {}
  }

  void _sendBinary(SignalingMessage message) {
    try {
      final payload = SignalingSerializer.encode(message);
      _socket?.add(MsgPackEncoder.encode(payload));
    } catch (_) {
      _enqueueMessage(message);
      _scheduleReconnect();
    }
  }

  void _enqueueMessage(SignalingMessage msg) {
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
    await _socket?.close(closeCode);
    _socket = null;
  }

  void _scheduleReconnect() {
    if (_status == SignalingStatus.disconnected &&
        _reconnectTimer?.isActive == true) {
      return;
    }

    _cleanupConnection(WebSocketStatus.abnormalClosure);
    _updateStatus(SignalingStatus.disconnected);

    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _retryCount++;

    final shift = min(_retryCount, 10);
    final delay =
        min(
          maxReconnectDelay.inMilliseconds,
          baseReconnectDelay.inMilliseconds << shift,
        ) +
        _random.nextInt(300);

    _reconnectTimer = Timer(Duration(milliseconds: delay), _connect);
  }

  void _updateStatus(SignalingStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }
}
