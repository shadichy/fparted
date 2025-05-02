import 'package:fparted/core/wrapper/base.dart';

enum E2FSVariants { ext2, ext3, ext4 }

class E2fsprogsBinary extends FilesystemPackage<E2FSVariants> {
  E2fsprogsBinary._i();
  static final E2fsprogsBinary _ = E2fsprogsBinary._i();
  factory E2fsprogsBinary() => _;

  @override
  get binaries => [
    "dumpe2fs",
    "e2label",
    "e2fsck",
    "resize2fs",
    ...E2FSVariants.values.map((v) => "mkfs.${v.name}"),
  ];

  @override
  create(device, [variant = E2FSVariants.ext4, label]) => (
    "mkfs.${variant?.name}",
    [
      ...(label != null ? ["-L", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => ("dumpe2fs", [device.raw]);

  @override
  label(device, label, [_]) => ("e2label", [device.raw, label]);

  @override
  repair(device, [_]) => ("e2fsck", [device.raw]);

  @override
  resize(device, size, [_, _]) => (
    "resize2fs",
    [device.raw, "${size.inKiB.toStringAsFixed(0)}K"],
  );
}
