import 'package:fparted/core/wrapper/base.dart';

enum DosFSVariants { dos, fat12, fat16, fat32 }

class DosfstoolsBinary implements FilesystemPackage<DosFSVariants> {
  DosfstoolsBinary._i();
  static final DosfstoolsBinary _ = DosfstoolsBinary._i();
  factory DosfstoolsBinary() => _;

  late final String? binary;

  @override
  isAvailable() => binary != null;

  @override
  init() async {
    binary = await binaryExists("mkfs.vfat");
    if (binary == null) {
      print(Exception("dosfstools is missing"));
    }
  }

  @override
  toCmd(_) => null;

  @override
  create(device, [variant]) {
    final (String eVariant, List<String> eArguments) = switch (variant) {
      DosFSVariants.dos => ("msdos", []),
      DosFSVariants.fat12 => ("vfat", ["-F", "12"]),
      DosFSVariants.fat16 => ("vfat", ["-F", "16"]),
      _ => ("vfat", ["-F", "32"]),
    };
    return ("mkfs.$eVariant", [...eArguments, device.raw]);
  }

  @override
  label(device, label, [variant]) {
    return (
      "${switch (variant) {
        DosFSVariants.dos => "dosfs",
        _ => "fat",
      }}label",
      [device.raw, label],
    );
  }

  @override
  fix(device, [variant]) {
    return (
      "fsck.${switch (variant) {
        DosFSVariants.dos => "msdos",
        _ => "vfat",
      }}",
      [device.raw],
    );
  }

  @override
  // dosfstools has no ability to resize
  resize(_, _, [_, _]) => null;
}
