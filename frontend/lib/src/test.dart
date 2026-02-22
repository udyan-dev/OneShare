import 'dart:math';

import 'package:flutter/material.dart';

import '../core/di.dart';
import '../engine/signaling/message/signaling_message.dart';
import '../engine/signaling/signaling_server.dart';

class SignalingTestPage extends StatefulWidget {
  const SignalingTestPage({super.key});

  @override
  State<SignalingTestPage> createState() => _SignalingTestPageState();
}

class _SignalingTestPageState extends State<SignalingTestPage> {
  final _server = di<SignalingServer>();
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addLog("SYSTEM: Initializing OneShare Mesh...");

    _server.messages.listen(_onMessageReceived);
    _server.statusStream.listen((status) {
      _addLog("STATUS: ${status.name.toUpperCase()}");
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageReceived(SignalingMessage msg) {
    _addLog("RX: ${msg.toJson()}");
  }

  void _addLog(String logMsg) {
    if (!mounted) return;
    setState(() => _logs.add(logMsg));

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCreateRoom() {
    final msg = SignalingMessage.createRoom(
      deviceName: "Test Device (Sender)",
      deviceType: "desktop",
      totalFiles: 5,
      totalSize: 157286400,
    );
    _server.send(msg);
    _addLog("TX: ${msg.toJson()}");
  }

  void _sendJoinRoom() {
    final msg = SignalingMessage.joinRoom(
      shareId: (100000 + Random().nextInt(900000)).toString(),
      deviceName: "Test Device (Receiver)",
      deviceType: "mobile",
    );
    _server.send(msg);
    _addLog("TX: ${msg.toJson()}");
  }

  void _sendExchange() {
    final msg = SignalingMessage.exchangeEndpoints(
      targetId: "PEER_${Random().nextInt(999)}",
      endpoints: ["192.168.1.${Random().nextInt(255)}:5000"],
      certHash: "hash_${DateTime.now().millisecondsSinceEpoch}",
    );
    _server.send(msg);
    _addLog("TX: ${msg.toJson()}");
  }

  void _sendCloseRoom() {
    const msg = SignalingMessage.roomClosed();
    _server.send(msg);
    _addLog("TX: ${msg.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneShare Mesh Debugger'),
        actions: [
          StreamBuilder<SignalingStatus>(
            stream: _server.statusStream,
            initialData: _server.status,
            builder: (context, snapshot) {
              final status = snapshot.data!;
              final color = status == SignalingStatus.ready
                  ? Colors.green
                  : status == SignalingStatus.connecting
                  ? Colors.orange
                  : Colors.red;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: color, size: 12),
                    const SizedBox(width: 8),
                    Text(
                      status.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_box),
                  label: const Text('Create Room'),
                  onPressed: _sendCreateRoom,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Join Room'),
                  onPressed: _sendJoinRoom,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('Exchange'),
                  onPressed: _sendExchange,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Close Room'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: _sendCloseRoom,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isTx = log.startsWith("TX");
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isTx
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isTx
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SelectableText(
                    log,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
