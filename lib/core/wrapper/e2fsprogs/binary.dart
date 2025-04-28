import 'package:fparted/core/wrapper/base.dart';

enum E2FSVariants { ext2, ext3, ext4 }

class E2fsprogsBinary implements FilesystemPackage<E2FSVariants> {
  E2fsprogsBinary._i();
  static final E2fsprogsBinary _ = E2fsprogsBinary._i();
  factory E2fsprogsBinary() => _;

  late final String? binary;

  @override
  isAvailable() => binary != null;

  @override
  init() async {
    binary = await binaryExists("mkfs.ext4");
    if (binary == null) {
      print(Exception("e2fsprogs is missing"));
    }
  }

  @override
  toCmd(_) => null;

  @override
  create(device, [variant = E2FSVariants.ext4]) => (
    "mkfs.${variant?.name}",
    [device.raw],
  );

  @override
  label(device, label, [_]) => ("e2label", [device.raw, label]);

  @override
  fix(device, [_]) => ("e2fsck", [device.raw]);

  @override
  resize(device, size, [_, _]) => (
    "resize2fs",
    [device.raw, "${size.inKiB.toStringAsFixed(0)}K"],
  );
}
