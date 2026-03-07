import 'package:get_it/get_it.dart';
import 'package:s2n_quic_flutter/s2n_quic_flutter.dart';

import '../engine/signaling/signaling_server.dart';

final di = GetIt.instance;
const _serverUrl = 'wss://oneshare.onrender.com/ws';

Future<void> inject() async {
  di.registerLazySingleton<SignalingServer>(
    () => SignalingServer(serverUrl: _serverUrl),
    onCreated: (server) => server.initialize(),
    dispose: (server) => server.dispose(),
  );

  final engine = S2nQuicEngine();
  engine.initialize();
  di.registerSingleton<S2nQuicEngine>(engine);

  final peerManager = PeerManager();
  peerManager.attachToEventStream(engine.eventStream);
  di.registerSingleton<PeerManager>(peerManager);

  final transferManager = TransferManager();
  transferManager.attachToEventStream(engine.eventStream);
  di.registerSingleton<TransferManager>(transferManager);
}