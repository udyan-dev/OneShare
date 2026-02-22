import 'package:get_it/get_it.dart';

import '../engine/signaling/signaling_server.dart';

final di = GetIt.instance;
const _serverUrl = 'ws://192.168.1.5:3000/ws';

void inject() {
  di.registerLazySingleton<SignalingServer>(
    () => SignalingServer(serverUrl: _serverUrl),
    onCreated: (server) => server.initialize(),
    dispose: (server) => server.dispose(),
  );
}
