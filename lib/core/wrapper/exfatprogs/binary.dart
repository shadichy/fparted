import 'package:fparted/core/wrapper/base.dart';

class ExfatprogsBinary extends FilesystemPackage {
  ExfatprogsBinary._i();
  static final ExfatprogsBinary _ = ExfatprogsBinary._i();
  factory ExfatprogsBinary() => _;

  @override
  get binaries => ["mkfs.exfat", "dump.exfat", "exfatlabel", "fsck.exfat"];

  @override
  create(device, [_, label]) => (
    "mkfs.exfat",
    [
      ...(label != null ? ["-L", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => ("dump.exfat", [device.raw]);

  @override
  label(device, label, [_]) => ("exfatlabel", [device.raw, label]);

  @override
  repair(device, [_]) => ("fsck.exfat", [device.raw]);

  @override
  // exfat has no ability to resize
  resize(_, _, [_, _]) => null;
}
