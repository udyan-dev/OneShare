import 'dart:convert';
import 'dart:typed_data';

class MsgPackEncoder {
  static Uint8List encode(Map<String, dynamic> message) {
    final builder = BytesBuilder(copy: false);

    final ordered = <String, dynamic>{};
    if (message.containsKey('type')) {
      ordered['type'] = message['type'];
    }
    message.forEach((key, value) {
      if (key != 'type') ordered[key] = value;
    });

    _writeMapHeader(builder, ordered.length);

    ordered.forEach((key, value) {
      _writeString(builder, key);
      _writeValue(builder, value);
    });

    return builder.takeBytes();
  }

  static void _writeValue(BytesBuilder builder, dynamic value) {
    if (value is String) {
      _writeString(builder, value);
    } else if (value is List) {
      _writeArray(builder, value);
    } else if (value is int) {
      _writeInt(builder, value);
    } else if (value is double) {
      builder.addByte(0xcb);
      final bytes = ByteData(8)..setFloat64(0, value);
      builder.add(bytes.buffer.asUint8List());
    } else if (value is bool) {
      builder.addByte(value ? 0xc3 : 0xc2);
    } else if (value == null) {
      builder.addByte(0xc0);
    } else if (value is Map) {
      _writeMapHeader(builder, value.length);
      value.forEach((k, v) {
        if (k is String) _writeString(builder, k);
        _writeValue(builder, v);
      });
    }
  }

  static void _writeMapHeader(BytesBuilder builder, int length) {
    if (length <= 15) {
      builder.addByte(0x80 | length);
    } else if (length <= 65535) {
      builder.addByte(0xde);
      final bytes = ByteData(2)..setUint16(0, length);
      builder.add(bytes.buffer.asUint8List());
    } else {
      builder.addByte(0xdf);
      final bytes = ByteData(4)..setUint32(0, length);
      builder.add(bytes.buffer.asUint8List());
    }
  }

  static void _writeString(BytesBuilder builder, String str) {
    final bytes = utf8.encode(str);
    final length = bytes.length;
    if (length <= 31) {
      builder.addByte(0xa0 | length);
    } else if (length <= 255) {
      builder.addByte(0xd9);
      builder.addByte(length);
    } else if (length <= 65535) {
      builder.addByte(0xda);
      final lenBytes = ByteData(2)..setUint16(0, length);
      builder.add(lenBytes.buffer.asUint8List());
    } else {
      builder.addByte(0xdb);
      final lenBytes = ByteData(4)..setUint32(0, length);
      builder.add(lenBytes.buffer.asUint8List());
    }
    builder.add(bytes);
  }

  static void _writeArray(BytesBuilder builder, List list) {
    final length = list.length;
    if (length <= 15) {
      builder.addByte(0x90 | length);
    } else if (length <= 65535) {
      builder.addByte(0xdc);
      final lenBytes = ByteData(2)..setUint16(0, length);
      builder.add(lenBytes.buffer.asUint8List());
    } else {
      builder.addByte(0xdd);
      final lenBytes = ByteData(4)..setUint32(0, length);
      builder.add(lenBytes.buffer.asUint8List());
    }
    for (var item in list) {
      _writeValue(builder, item);
    }
  }

  static void _writeInt(BytesBuilder builder, int val) {
    if (val >= 0) {
      if (val <= 127) {
        builder.addByte(val);
      } else if (val <= 255) {
        builder.addByte(0xcc);
        builder.addByte(val);
      } else if (val <= 65535) {
        builder.addByte(0xcd);
        final bytes = ByteData(2)..setUint16(0, val);
        builder.add(bytes.buffer.asUint8List());
      } else if (val <= 4294967295) {
        builder.addByte(0xce);
        final bytes = ByteData(4)..setUint32(0, val);
        builder.add(bytes.buffer.asUint8List());
      } else {
        builder.addByte(0xcf);
        final bytes = ByteData(8)..setUint64(0, val);
        builder.add(bytes.buffer.asUint8List());
      }
    } else {
      if (val >= -32) {
        builder.addByte(0xe0 | (val & 0x1f));
      } else if (val >= -128) {
        builder.addByte(0xd0);
        builder.addByte(val & 0xff);
      } else if (val >= -32768) {
        builder.addByte(0xd1);
        final bytes = ByteData(2)..setInt16(0, val);
        builder.add(bytes.buffer.asUint8List());
      } else if (val >= -2147483648) {
        builder.addByte(0xd2);
        final bytes = ByteData(4)..setInt32(0, val);
        builder.add(bytes.buffer.asUint8List());
      } else {
        builder.addByte(0xd3);
        final bytes = ByteData(8)..setInt64(0, val);
        builder.add(bytes.buffer.asUint8List());
      }
    }
  }
}
