import 'package:fparted/core/wrapper/base.dart';

class F2fstoolsBinary extends FilesystemPackage {
  F2fstoolsBinary._i();
  static final F2fstoolsBinary _ = F2fstoolsBinary._i();
  factory F2fstoolsBinary() => _;

  @override
  get binaries => ["fsck.f2fs", "make_f2fs"];

  @override
  create(device, [_, label]) => (
    "make_f2fs",
    [
      ...(label != null ? ["-l", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => ("dump.f2fs", ["-d1", device.raw]);

  @override
  label(device, label, [_]) => ("f2fslabel", [device.raw, label]);

  @override
  repair(device, [_]) => ("fsck.f2fs", [device.raw]);

  @override
  resize(device, _, [_, _]) => ("resize.f2fs", [device.raw]);
}
