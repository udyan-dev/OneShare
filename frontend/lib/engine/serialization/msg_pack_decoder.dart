import 'dart:convert';
import 'dart:typed_data';

class MsgPackDecoder {
  static dynamic decode(Uint8List bytes) {
    final byteData = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    int offset = 0;

    dynamic readNext() {
      if (offset >= bytes.length) return null;
      final type = byteData.getUint8(offset++);

      if (type <= 0x7f) return type;
      if (type >= 0x80 && type <= 0x8f) return _readMap(type & 0x0f, readNext);
      if (type >= 0x90 && type <= 0x9f)
        return _readArray(type & 0x0f, readNext);
      if (type >= 0xa0 && type <= 0xbf)
        return _readString(type & 0x1f, bytes, (o) => offset = o, offset);
      if (type >= 0xe0) return type - 256;

      switch (type) {
        case 0xc0:
          return null;
        case 0xc2:
          return false;
        case 0xc3:
          return true;
        case 0xcc:
          final val = byteData.getUint8(offset);
          offset += 1;
          return val;
        case 0xcd:
          final val = byteData.getUint16(offset);
          offset += 2;
          return val;
        case 0xce:
          final val = byteData.getUint32(offset);
          offset += 4;
          return val;
        case 0xcf:
          final val = byteData.getUint64(offset);
          offset += 8;
          return val;
        case 0xd0:
          final val = byteData.getInt8(offset);
          offset += 1;
          return val;
        case 0xd1:
          final val = byteData.getInt16(offset);
          offset += 2;
          return val;
        case 0xd2:
          final val = byteData.getInt32(offset);
          offset += 4;
          return val;
        case 0xd3:
          final val = byteData.getInt64(offset);
          offset += 8;
          return val;
        case 0xca:
          final val = byteData.getFloat32(offset);
          offset += 4;
          return val;
        case 0xcb:
          final val = byteData.getFloat64(offset);
          offset += 8;
          return val;
        case 0xd9:
          final len = byteData.getUint8(offset);
          offset += 1;
          return _readString(len, bytes, (o) => offset = o, offset);
        case 0xda:
          final len = byteData.getUint16(offset);
          offset += 2;
          return _readString(len, bytes, (o) => offset = o, offset);
        case 0xdb:
          final len = byteData.getUint32(offset);
          offset += 4;
          return _readString(len, bytes, (o) => offset = o, offset);
        case 0xdc:
          final len = byteData.getUint16(offset);
          offset += 2;
          return _readArray(len, readNext);
        case 0xdd:
          final len = byteData.getUint32(offset);
          offset += 4;
          return _readArray(len, readNext);
        case 0xde:
          final len = byteData.getUint16(offset);
          offset += 2;
          return _readMap(len, readNext);
        case 0xdf:
          final len = byteData.getUint32(offset);
          offset += 4;
          return _readMap(len, readNext);
      }
      return null;
    }

    final result = readNext();
    return result is Map ? Map<String, dynamic>.from(result) : result;
  }

  static Map _readMap(int length, Function readNext) {
    final map = {};
    for (var i = 0; i < length; i++) {
      final key = readNext();
      map[key] = readNext();
    }
    return map;
  }

  static List _readArray(int length, Function readNext) {
    return List.generate(length, (_) => readNext());
  }

  static String _readString(
    int length,
    Uint8List bytes,
    Function updateOffset,
    int currentOffset,
  ) {
    final end = currentOffset + length;
    final str = utf8.decode(bytes.sublist(currentOffset, end));
    updateOffset(end);
    return str;
  }
}
