import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'core/di.dart' as di;
import 'src/test.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      di.inject();
      runApp(const MainApp());
    },
    (error, stackTrace) {
      dev.log('$error\n$stackTrace');
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SignalingTestPage());
  }
}
