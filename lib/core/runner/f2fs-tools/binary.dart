import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

class F2fstoolsBinary extends FilesystemPackage {
  F2fstoolsBinary._i();
  static final F2fstoolsBinary _ = F2fstoolsBinary._i();
  factory F2fstoolsBinary() => _;

  @override
  get binaries => [
    "fsck.f2fs",
    "make_f2fs",
    "f2fslabel",
    "dump.f2fs",
    "resize.f2fs",
  ];

  @override
  create(device, [_, label]) => Job("make_f2fs", [
    ...(label != null ? ["-l", label] : []),
    device.raw,
  ], "Create F2FS on $device");

  @override
  dump(device, [_]) => Job(binaryMap["dump.f2fs"] ?? "dump.f2fs", [
    "-d1",
    device.raw,
  ], "Dump info of $device");

  @override
  label(device, label, [_]) => Job(binaryMap["f2fslabel"] ?? "f2fslabel", [
    device.raw,
    label,
  ], "Assign $device with label '$label'");

  @override
  repair(device, [_]) => Job(binaryMap["fsck.f2fs"] ?? "fsck.f2fs", [
    device.raw,
  ], "Perform filesystem check on $device");

  @override
  resize(device, _, [_, _]) => Job(
    binaryMap["resize.f2fs"] ?? "resize.f2fs",
    [device.raw],
    "Resize $device to fill the partition space",
  );
}
