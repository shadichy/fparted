import 'package:fparted/core/wrapper/base.dart';

enum DosFSVariants { fat12, fat16, fat32 }

class DosfstoolsBinary extends FilesystemPackage<DosFSVariants> {
  DosfstoolsBinary._i();
  static final DosfstoolsBinary _ = DosfstoolsBinary._i();
  factory DosfstoolsBinary() => _;

  @override
  get binaries => ["fatlabel", "fsck.fat", "mkfs.fat"];

  @override
  create(device, [variant, label]) => (
    "mkfs.fat",
    [
      "-F",
      switch (variant) {
        DosFSVariants.fat12 => "12",
        DosFSVariants.fat16 => "16",
        _ => "32",
      },
      ...(label != null ? ["-n", label] : []),
      device.raw,
    ],
  );

  @override
  dump(device, [_]) => ("fsck.fat", ["-n", device.raw]);

  @override
  label(device, label, [_]) => ("fatlabel", [device.raw, label]);

  @override
  repair(device, [_]) => ("fsck.fat", ["-a", device.raw]);

  @override
  // dosfstools has no ability to resize
  resize(_, _, [_, _]) => null;
}
