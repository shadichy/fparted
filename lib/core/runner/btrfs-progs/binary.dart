import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

class BtrfsprogsBinary extends FilesystemPackage {
  BtrfsprogsBinary._i();
  static final BtrfsprogsBinary _ = BtrfsprogsBinary._i();
  factory BtrfsprogsBinary() => _;

  @override
  get binaries => ["mkfs.btrfs", "btrfs"];

  @override
  create(device, [_, label]) => Job("mkfs.btrfs", [
    ...(label != null ? ["-L", label] : []),
    device.raw,
  ], "Create BtrFS on $device");

  @override
  dump(device, [_]) => Job(binaryMap["btrfs"] ?? "btrfs", [
    "filesystem",
    "show",
    "--raw",
    device.raw,
  ], "Dump info of $device");

  @override
  label(device, label, [_]) => Job("btrfs", [
    "filesystem",
    "label",
    device.raw,
    label,
  ], "Assign $device with label '$label'");

  @override
  repair(device, [_]) => Job(binaryMap["btrfs"] ?? "btrfs", [
    "check",
    device.raw,
  ], "Perform filesystem check on $device");

  @override
  resize(device, size, [_, _]) => Job("btrfs", [
    "filesystem",
    "resize",
    "${size.inKiB.toStringAsFixed(0)}k",
    device.raw,
  ], "Resize $device to ${size.humanReadable()}");
}
