import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

enum DosFSVariants { fat12, fat16, fat32 }

class DosfstoolsBinary extends FilesystemPackage<DosFSVariants> {
  DosfstoolsBinary._i();
  static final DosfstoolsBinary _ = DosfstoolsBinary._i();
  factory DosfstoolsBinary() => _;

  @override
  get binaries => ["fatlabel", "fsck.fat", "mkfs.fat"];

  @override
  create(device, [variant = DosFSVariants.fat32, label]) => Job("mkfs.fat", [
    "-F",
    switch (variant) {
      DosFSVariants.fat12 => "12",
      DosFSVariants.fat16 => "16",
      _ => "32",
    },
    ...(label != null ? ["-n", label] : []),
    device.raw,
  ], "Create ${variant?.name} on $device");

  @override
  dump(device, [_]) => Job(binaryMap["fsck.fat"] ?? "fsck.fat", [
    "-n",
    device.raw,
  ], "Dump info of $device");

  @override
  label(device, label, [_]) => Job(binaryMap["fatlabel"] ?? "fatlabel", [
    device.raw,
    label,
  ], "Assign $device with label '$label'");

  @override
  repair(device, [_]) => Job(binaryMap["fsck.fat"] ?? "fsck.fat", [
    "-a",
    device.raw,
  ], "Perform filesystem check on $device");

  @override
  // dosfstools has no ability to resize
  resize(_, _, [_, _]) => null;
}
