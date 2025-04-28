import 'package:fparted/core/wrapper/base.dart';

class ExfatprogsBinary implements FilesystemPackage {
  ExfatprogsBinary._i();
  static final ExfatprogsBinary _ = ExfatprogsBinary._i();
  factory ExfatprogsBinary() => _;

  late final String? binary;

  @override
  isAvailable() => binary != null;

  @override
  init() async {
    binary = await binaryExists("mkfs.exfat");
    if (binary == null) {
      print(Exception("dosfstools is missing"));
    }
  }

  @override
  toCmd(_) => null;

  @override
  create(device, [_]) => ("mkfs.vfat", [device.raw]);

  @override
  label(device, label, [_]) => ("exfatlabel", [device.raw, label]);

  @override
  fix(device, [_]) => ("fsck.exfat", [device.raw]);

  @override
  // exfat has no ability to resize
  resize(_, _, [_, _]) => null;
}
