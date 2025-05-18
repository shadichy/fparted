import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

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
  create(device, [variant = E2FSVariants.ext4, label]) =>
      Job("mkfs.${variant?.name}", [
        ...(label != null ? ["-L", label] : []),
        device.raw,
      ], "Create ${variant?.name} on $device");

  @override
  dump(device, [_]) => Job(binaryMap["dumpe2fs"] ?? "dumpe2fs", [
    device.raw,
  ], "Dump info of $device");

  @override
  label(device, label, [_]) => Job(binaryMap["e2label"] ?? "e2label", [
    device.raw,
    label,
  ], "Assign $device with label '$label'");

  @override
  repair(device, [_]) => Job(binaryMap["e2fsck"] ?? "e2fsck", [
    device.raw,
  ], "Perform filesystem check on $device");

  @override
  resize(device, size, [_, _]) => Job("resize2fs", [
    device.raw,
    "${size.inKiB.toStringAsFixed(0)}K",
  ], "Resize $device to ${size.humanReadable()}");
}
