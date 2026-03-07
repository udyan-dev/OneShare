import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

final class CallbackData extends ffi.Struct {
  @ffi.Uint64()
  external int transferId;
  @ffi.Uint8()
  external int status;
  @ffi.Float()
  external double progressPercent;
  @ffi.Float()
  external double speedMbps;
  @ffi.Uint32()
  external int etaSeconds;
}

typedef InitNative =
    ffi.Bool Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(CallbackData)>>,
    );
typedef InitDart =
    bool Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(CallbackData)>>,
    );
typedef SendFileNative =
    ffi.Uint64 Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef SendFileDart = int Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef ControlNative = ffi.Void Function(ffi.Uint64);
typedef ControlDart = void Function(int);

class NativeBindings {
  late final ffi.DynamicLibrary lib;
  late final InitDart init;
  late final SendFileDart sendFile;
  late final ControlDart pause;
  late final ControlDart resume;
  late final ControlDart cancel;

  NativeBindings() {
    lib = _loadLibrary();
    init = lib.lookupFunction<InitNative, InitDart>('init_scheduler');
    sendFile = lib.lookupFunction<SendFileNative, SendFileDart>(
      'enqueue_transfer',
    );
    pause = lib.lookupFunction<ControlNative, ControlDart>(
      'scheduler_pause_transfer',
    );
    resume = lib.lookupFunction<ControlNative, ControlDart>(
      'scheduler_resume_transfer',
    );
    cancel = lib.lookupFunction<ControlNative, ControlDart>(
      'scheduler_cancel_transfer',
    );
  }

  static ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libs2n_quic_transfer_scheduler.so');
    }
    if (Platform.isIOS || Platform.isMacOS) return ffi.DynamicLibrary.process();
    if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('s2n_quic_transfer_scheduler.dll');
    }
    if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('libs2n_quic_transfer_scheduler.so');
    }
    throw UnsupportedError('Unsupported platform');
  }
}
