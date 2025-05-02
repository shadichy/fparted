import 'package:fparted/core/wrapper/base.dart';

class BlkidBinary implements RequiredPackage {
  BlkidBinary._i();
  static final BlkidBinary _ = BlkidBinary._i();
  factory BlkidBinary() => _;

  late final String blkidBinary;

  @override
  // Always required
  get isAvailable => true;

  @override
  init() async {
    final bin = await binaryExists("blkid");
    if (bin != null) {
      blkidBinary = bin;
    } else {
      throw Exception("blkid binary required");
    }
  }

  @override
  (String, List<String>) toCmd(List<String> arguments) => (
    blkidBinary,
    [arguments[0], argToArg(arguments.skip(1))],
  );
}
