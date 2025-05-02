import 'package:fparted/core/wrapper/base.dart';

class BtrfsprogsBinary extends FilesystemPackage {
  BtrfsprogsBinary._i();
  static final BtrfsprogsBinary _ = BtrfsprogsBinary._i();
  factory BtrfsprogsBinary() => _;

  @override
  get binaries => ["mkfs.btrfs", "btrfs"];

  @override
  create(device, [_, label]) => (
    "mkfs.btrfs",
    [
      ...(label != null ? ["-L", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => ("btrfs", ["filesystem", "show", "--raw", device.raw]);

  @override
  label(device, label, [_]) => (
    "btrfs",
    ["filesystem", "label", device.raw, label],
  );

  @override
  repair(device, [_]) => ("btrfs", ["check", device.raw]);

  @override
  resize(device, size, [_, _]) => (
    "btrfs",
    ["filesystem", "resize", "${size.inKiB.toStringAsFixed(0)}k", device.raw],
  );
}
