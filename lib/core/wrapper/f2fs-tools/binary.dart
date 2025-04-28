import 'package:fparted/core/wrapper/base.dart';

class F2fstoolsBinary implements FilesystemPackage {
  F2fstoolsBinary._i();
  static final F2fstoolsBinary _ = F2fstoolsBinary._i();
  factory F2fstoolsBinary() => _;

  late final String? binary;

  @override
  isAvailable() => binary != null;

  @override
  init() async {
    binary = await binaryExists("mkfs.f2fs");
    if (binary == null) {
      print(Exception("f2fs-tools is missing"));
    }
  }

  @override
  toCmd(_) => null;

  @override
  create(device, [_]) => ("mkfs.f2fs", [device.raw]);

  @override
  label(device, label, [_]) => ("f2fslabel", [device.raw, label]);

  @override
  fix(device, [_]) => ("fsck.f2fs", [device.raw]);

  @override
  resize(device, _, [_, _]) => ("resize.f2fs", [device.raw]);
}
