import 'dart:io';

import 'package:fparted/core/runner/wrapper.dart';

enum DeviceType {
  // ignore: constant_identifier_names
  Default,
  block,
  loop,
  byIdentity,
  majMin,
}

class Device {
  static final DEVFS_PREFIX = "/dev/";
  static final DEVICE_PREFIX = "/dev/block/";
  static final SYSFS_DEVICE_PREFIX = "/sys/dev/block/";

  final String raw;
  late final DeviceType type;
  Device(final String device) : raw = device {
    final startsWithDevfs = device.startsWith(DEVFS_PREFIX);

    if (device.contains("loop")) {
      type = DeviceType.loop;
    } else if (device.contains("by-")) {
      type = DeviceType.byIdentity;
    } else if (RegExp(r"[0-9]{1,}:[0-9]{1,}").hasMatch(device)) {
      type = DeviceType.majMin;
    } else if (startsWithDevfs) {
      if (device.startsWith(DEVICE_PREFIX)) {
        type = DeviceType.block;
      } else {
        type = DeviceType.Default;
      }
    } else {
      throw Exception("Unknown device $device");
    }

    var path = device;
    if (!startsWithDevfs) {
      path =
          switch (type) {
            DeviceType.majMin => SYSFS_DEVICE_PREFIX,
            _ => DEVICE_PREFIX,
          } +
          device;
    }

    if (!Wrapper.fileExistsSync(path)) {
      throw Exception("Device $device does not exist");
    }
  }

  static Device? tryParse(String device) {
    try {
      return Device(device);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => raw;
}

Future<void> deviceInit() async => await _DeviceInit().init();

Device fallbackDevice() => _DeviceInit().fallback;

class _DeviceInit {
  _DeviceInit._i();
  static final _DeviceInit _ = _DeviceInit._i();
  factory _DeviceInit() => _;

  late final Device fallback;

  Future<void> init() async {
    // read from Hive config
    if (Platform.isAndroid) {
      fallback = Device.tryParse("/dev/block/zram0") ?? Device("/dev/block/ram0");
    } else if (Platform.isLinux) {
      fallback = Device("/dev/zram0");
    } else {
      throw Exception("Unsupported platform");
    }
  }
}

enum _DeviceIdType { ID, UUID }

class DeviceId {
  final _DeviceIdType _type;
  final BigInt id;

  factory DeviceId(dynamic value) {
    if (value is int) {
      return DeviceId.fromInt(value);
    } else if (value is BigInt) {
      return DeviceId.fromBigInt(value);
    } else if (value is String) {
      return DeviceId.fromString(value);
    } else {
      throw Exception("Not a valid type for partition id, uuid or number");
    }
  }

  DeviceId.fromInt(int value) : _type = _DeviceIdType.ID, id = BigInt.from(value);

  DeviceId.fromBigInt(this.id) : _type = _DeviceIdType.UUID;

  factory DeviceId.fromString(String value) {
    if (value.length <= 3) {
      final tryId = int.tryParse(value);
      if (tryId is int) {
        return DeviceId.fromInt(tryId);
      } else {
        return DeviceId(null);
      }
    } else if (value.length <= 4 && RegExp(r"^0[bodx]").hasMatch(value)) {
      final int radix;
      if (value.startsWith("0x")) {
        radix = 2;
      } else if (value.startsWith("0o")) {
        radix = 8;
      } else if (value.startsWith("0d")) {
        radix = 10;
      } else {
        radix = 16;
      }

      final tryId = int.tryParse(value, radix: radix);
      if (tryId is int) {
        return DeviceId.fromInt(tryId);
      } else {
        return DeviceId(null);
      }
    } else {
      final tryId = BigInt.tryParse(value.replaceAll("-", ""), radix: 16);
      if (tryId is BigInt) {
        return DeviceId.fromBigInt(tryId);
      } else {
        return DeviceId(null);
      }
    }
  }

  static DeviceId? tryParse(dynamic value) {
    try {
      return DeviceId(value);
    } catch (_) {
      return null;
    }
  }

  String get type => _type.name;

  String toID() {
    return id.toRadixString(16);
  }

  String toUUID() {
    final splitted = id.toRadixString(16).split("");
    return "${splitted.take(8).join()}-${splitted.take(12).skip(8).join()}-${splitted.take(16).skip(12).join()}-${splitted.take(20).skip(16).join()}-${splitted.skip(20).join()}";
  }

  @override
  String toString() => switch (_type) {
    _DeviceIdType.ID => toID(),
    _DeviceIdType.UUID => toUUID(),
  };

  @override
  bool operator ==(Object other) {
    return other is DeviceId && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
