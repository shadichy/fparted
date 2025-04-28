import 'package:fparted/core/wrapper/base.dart';

class BtrfsprogsBinary implements FilesystemPackage {
  BtrfsprogsBinary._i();
  static final BtrfsprogsBinary _ = BtrfsprogsBinary._i();
  factory BtrfsprogsBinary() => _;

  late final String? binary;

  @override
  isAvailable() => binary != null;

  @override
  init() async {
    binary = await binaryExists("btrfs");
    if (binary == null) {
      print(Exception("btrfs-progs is missing"));
    }
  }

  @override
  toCmd(_) => null;

  @override
  create(device, [_]) => ("mkfs.btrfs", [device.raw]);

  @override
  label(device, label, [_]) => ("btrfs", ["filesystem", "label", device.raw, label]);

  @override
  fix(device, [_]) => ("fsck.exfat", [device.raw]);

  @override
  resize(device, size, [_, _]) => (
    "btrfs",
    ["filesystem", "resize", "${size.inKiB.toStringAsFixed(0)}k", device.raw],
  );
}
