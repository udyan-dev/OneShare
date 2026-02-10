import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IO.Socket socket;
  bool isConnected = false;
  String status = 'Disconnected';
  String? socketId;
  String? currentShareId;
  bool isSender = false;
  String? targetPeerId;

  // WebRTC
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _iceCandidateQueue = [];

  // File Transfer State
  double transferProgress = 0.0;
  String transferStatus = '';
  int _bytesReceived = 0;
  int _fileSize = 1; // Avoid division by zero
  int _transferStartTime = 0;
  String _speed = '0 MB/s';
  
  final TextEditingController _codeController = TextEditingController();
  final String serverUrl = 'http://192.168.1.2:3000'; // Update as needed

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    setState(() => status = 'Connecting...');

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Socket Connected: ${socket.id}');
      setState(() {
        isConnected = true;
        status = 'Connected';
        socketId = socket.id;
      });
    });

    socket.onDisconnect((_) {
      print('Socket Disconnected');
      setState(() {
        isConnected = false;
        status = 'Disconnected';
        socketId = null;
        currentShareId = null;
        targetPeerId = null;
        _closePeerConnection();
      });
    });

    socket.on('room-created', (data) {
      print('Room Created: $data');
      setState(() {
        currentShareId = data['shareId'];
        isSender = true;
        status = 'Room Created: $currentShareId';
      });
    });

    socket.on('join-success', (data) async {
      print('Join Success: $data');
      setState(() {
        currentShareId = _codeController.text.trim();
        status = 'Joined Room. Connecting P2P...';
        isSender = false;
      });
      await _createPeerConnection();
    });

    socket.on('peer-joined', (data) async {
      print('Peer Joined: $data');
      if (isSender) {
        setState(() {
          status = 'Peer Joined. Connecting P2P...';
          targetPeerId = data['peerSocketId'];
        });
        await _createPeerConnection();
        await _createOffer();
      }
    });

    socket.on('webrtc-offer', (data) async {
      print('Received Offer');
      if (!isSender) {
        setState(() {
          targetPeerId = data['senderSocketId'];
        });
        await _handleOffer(data);
      }
    });

    socket.on('webrtc-answer', (data) async {
      print('Received Answer');
      if (isSender) {
        await _handleAnswer(data);
      }
    });

    socket.on('webrtc-ice-candidate', (data) async {
      await _handleIceCandidate(data);
    });

    socket.on('create-room-error', (err) => _showError('Create Error: $err'));
    socket.on('join-room-error', (err) => _showError('Join Error: $err'));
  }

  // --- WebRTC Logic ---

  Future<void> _createPeerConnection() async {
    _closePeerConnection();
    print('Creating Peer Connection...');
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      if (currentShareId != null && targetPeerId != null) {
        socket.emit('webrtc-ice-candidate', {
          'shareId': currentShareId,
          'targetSocketId': targetPeerId,
          'candidate': candidate.toMap(),
        });
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('P2P Connection State: $state');
      setState(() => status = 'P2P State: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() => status = 'P2P Connected! Ready to transfer.');
        _logConnectionStats();
      }
    };

    if (isSender) {
      // Ordered: true is required for simple file transfer.
      RTCDataChannelInit dataChannelDict = RTCDataChannelInit()..ordered = true;
      _dataChannel = await _peerConnection!.createDataChannel(
        'fileTransfer',
        dataChannelDict,
      );
      _setupDataChannel(_dataChannel!);
    } else {
      _peerConnection!.onDataChannel = (channel) {
        print('Data Channel Received: ${channel.label}');
        _dataChannel = channel;
        _setupDataChannel(channel);
      };
    }
  }

  Future<void> _logConnectionStats() async {
    if (_peerConnection == null) return;
    List<StatsReport> stats = await _peerConnection!.getStats();
    for (var report in stats) {
      if (report.type == 'candidate-pair' && report.values['state'] == 'succeeded') {
        print('Active Candidate Pair: ${report.values}');
      }
    }
  }

  void _setupDataChannel(RTCDataChannel channel) {
    channel.onMessage = (RTCDataChannelMessage message) {
      if (!isSender) {
        if (message.isBinary) {
          _handleBinaryMessage(message.binary);
        } else {
          _handleTextMessage(message.text);
        }
      }
    };

    channel.onDataChannelState = (state) {
      print('Data Channel State: $state');
    };
  }

  Future<void> _createOffer() async {
    if (targetPeerId == null) return;
    print('Creating Offer for $targetPeerId...');
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    socket.emit('webrtc-offer', {
      'shareId': currentShareId,
      'targetSocketId': targetPeerId,
      'sdp': offer.toMap(),
    });
  }

  Future<void> _handleOffer(dynamic data) async {
    print('Handling Offer...');
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']),
    );
    _remoteDescriptionSet = true;
    _processIceCandidateQueue();

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    socket.emit('webrtc-answer', {
      'shareId': currentShareId,
      'targetSocketId': data['senderSocketId'],
      'sdp': answer.toMap(),
    });
  }

  Future<void> _handleAnswer(dynamic data) async {
    print('Handling Answer...');
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']),
    );
    _remoteDescriptionSet = true;
    _processIceCandidateQueue();
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    if (data['senderSocketId'] != null && data['senderSocketId'] == socketId) {
      return;
    }

    final candidate = RTCIceCandidate(
      data['candidate']['candidate'],
      data['candidate']['sdpMid'],
      data['candidate']['sdpMLineIndex'],
    );

    if (_peerConnection != null && _remoteDescriptionSet) {
      await _peerConnection!.addCandidate(candidate);
    } else {
      _iceCandidateQueue.add(candidate);
    }
  }

  void _processIceCandidateQueue() async {
    if (_peerConnection == null) return;
    print('Processing ICE Queue: ${_iceCandidateQueue.length} candidates');
    for (var candidate in _iceCandidateQueue) {
      await _peerConnection!.addCandidate(candidate);
    }
    _iceCandidateQueue.clear();
  }

  // --- File Transfer Logic ---

  void _sendFile() async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      _showError('Data channel is not open');
      return;
    }

    // 100MB file data
    final int fileSize = 100 * 1024 * 1024;
    
    setState(() {
      transferStatus = 'Sending file (100MB)...';
      transferProgress = 0;
      _speed = '0 MB/s';
      _fileSize = fileSize;
    });

    // 1. Send Metadata
    final metadata = jsonEncode({'name': 'large_test_file.bin', 'size': fileSize});
    await _dataChannel!.send(RTCDataChannelMessage(metadata));

    // 2. Send Chunks
    // 64KB is a safe and efficient chunk size for SCTP
    const int chunkSize = 64 * 1024;
    int offset = 0;
    
    final List<int> dummyChunkData = List.filled(chunkSize, 65); // 'A'
    final Uint8List chunkBytes = Uint8List.fromList(dummyChunkData);

    _transferStartTime = DateTime.now().millisecondsSinceEpoch;
    int lastUiUpdate = _transferStartTime;

    // High buffer threshold (8MB) to keep the pipe full
    const int bufferedAmountHighThreshold = 8 * 1024 * 1024; 
    
    // Burst size: Send multiple chunks before yielding to event loop
    const int burstSize = 10;

    while (offset < fileSize) {
      // Backpressure Control
      int buffered = _dataChannel!.bufferedAmount ?? 0;
      if (buffered > bufferedAmountHighThreshold) {
        // Buffer full, wait a bit
        await Future.delayed(const Duration(milliseconds: 1));
        continue;
      }

      // Burst Loop: Send multiple chunks without awaiting
      for (int i = 0; i < burstSize && offset < fileSize; i++) {
        int currentChunkSize = chunkSize;
        if (offset + currentChunkSize > fileSize) {
          currentChunkSize = fileSize - offset;
        }

        Uint8List dataToSend = chunkBytes;
        if (currentChunkSize < chunkSize) {
           dataToSend = chunkBytes.sublist(0, currentChunkSize);
        }

        // Fire and forget (no await) for maximum throughput
        _dataChannel!.send(RTCDataChannelMessage.fromBinary(dataToSend));

        offset += currentChunkSize;
      }
      
      // Yield briefly to allow platform channel to process messages and update bufferedAmount
      await Future.delayed(Duration.zero);

      // Update UI every 200ms
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastUiUpdate > 200) {
         _updateSpeed(offset, now);
         lastUiUpdate = now;
      }
    }

    // Wait for buffer to drain completely
    while ((_dataChannel!.bufferedAmount ?? 0) > 0) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _updateSpeed(fileSize, DateTime.now().millisecondsSinceEpoch);
    setState(() {
      transferProgress = 1.0;
      transferStatus = 'File Sent!';
    });
  }

  void _updateSpeed(int bytesProcessed, int now) {
    final durationSec = (now - _transferStartTime) / 1000.0;
    if (durationSec > 0 && _fileSize > 0) {
      final speedMbps = (bytesProcessed / (1024 * 1024)) / durationSec;
      double progress = bytesProcessed / _fileSize;
      
      if (progress < 0.0) progress = 0.0;
      if (progress > 1.0) progress = 1.0;

      setState(() {
        transferProgress = progress;
        _speed = '${speedMbps.toStringAsFixed(2)} MB/s';
      });
    }
  }

  void _handleTextMessage(String text) {
    try {
      final metadata = jsonDecode(text);
      setState(() {
        _fileSize = metadata['size'] ?? 1;
        _bytesReceived = 0;
        transferStatus = 'Receiving ${metadata['name']}...';
        transferProgress = 0;
        _speed = '0 MB/s';
        _transferStartTime = DateTime.now().millisecondsSinceEpoch;
      });
    } catch (e) {
      print('Error parsing metadata: $e');
    }
  }

  void _handleBinaryMessage(Uint8List chunk) {
    _bytesReceived += chunk.length;

    // Update UI periodically
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - _transferStartTime) > 200 && _bytesReceived % (1024 * 1024) < chunk.length) {
       _updateSpeed(_bytesReceived, now);
    }

    if (_bytesReceived >= _fileSize) {
      _updateSpeed(_bytesReceived, now);
      setState(() {
        transferStatus = 'File Received! (${_bytesReceived} bytes)';
        transferProgress = 1.0;
      });
    }
  }

  void _closePeerConnection() {
    _peerConnection?.close();
    _peerConnection = null;
    _dataChannel = null;
    _remoteDescriptionSet = false;
    _iceCandidateQueue.clear();
  }

  // --- UI Logic ---

  void _createRoom() {
    if (!isConnected) return;
    socket.emit('create-room', {
      'files': [
        {'name': 'test.txt', 'size': 1024, 'mime': 'text/plain'},
      ],
    });
  }

  void _joinRoom() {
    if (!isConnected) return;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showError('Please enter a code');
      return;
    }
    socket.emit('join-room', {'shareId': code});
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _closePeerConnection();
    socket.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OneShare P2P')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Sender Section
            if (currentShareId == null) ...[
              ElevatedButton.icon(
                onPressed: isConnected ? _createRoom : null,
                icon: const Icon(Icons.upload_file),
                label: const Text('Send Files (Create Room)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 30),

              // Receiver Section
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-Digit Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isConnected ? _joinRoom : null,
                icon: const Icon(Icons.login),
                label: const Text('Join Room'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              // Active Room View
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Room Active',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isSender) ...[
                        const Text(
                          'Share this code:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SelectableText(
                          currentShareId!,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _sendFile,
                          child: const Text('Send 100MB File'),
                        ),
                      ],
                      const SizedBox(height: 30),

                      // Transfer Progress
                      if (transferStatus.isNotEmpty) ...[
                        Text(
                          transferStatus,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: transferProgress,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(transferProgress * 100).toStringAsFixed(1)}%'),
                            Text(_speed, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () {
                          socket.emit('leave-room');
                          _closePeerConnection();
                          setState(() {
                            currentShareId = null;
                            status = 'Connected';
                            transferStatus = '';
                            transferProgress = 0;
                            _speed = '0 MB/s';
                          });
                        },
                        child: const Text('Leave Room'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
