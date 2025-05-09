import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

class ExfatprogsBinary extends FilesystemPackage {
  ExfatprogsBinary._i();
  static final ExfatprogsBinary _ = ExfatprogsBinary._i();
  factory ExfatprogsBinary() => _;

  @override
  get binaries => ["mkfs.exfat", "dump.exfat", "exfatlabel", "fsck.exfat"];

  @override
  create(device, [_, label]) => Job(
    "mkfs.exfat",
    [
      ...(label != null ? ["-L", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => Job(binaryMap["dump.exfat"] ?? "dump.exfat", [device.raw]);

  @override
  label(device, label, [_]) => Job(binaryMap["exfatlabel"] ?? "exfatlabel", [device.raw, label]);

  @override
  repair(device, [_]) => Job(binaryMap["fsck.exfat"] ?? "fsck.exfat", [device.raw]);

  @override
  // exfat has no ability to resize
  resize(_, _, [_, _]) => null;
}
