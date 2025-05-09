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
  create(device, [variant, label]) => Job(
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
  dump(device, [_]) => Job(binaryMap["fsck.fat"] ?? "fsck.fat", ["-n", device.raw]);

  @override
  label(device, label, [_]) => Job(binaryMap["fatlabel"] ?? "fatlabel", [device.raw, label]);

  @override
  repair(device, [_]) => Job(binaryMap["fsck.fat"] ?? "fsck.fat", ["-a", device.raw]);

  @override
  // dosfstools has no ability to resize
  resize(_, _, [_, _]) => null;
}
