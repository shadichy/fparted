import 'package:fparted/core/wrapper/base.dart';

class PartedBinary implements RequiredPackage {
  PartedBinary._i();
  static final PartedBinary _ = PartedBinary._i();
  factory PartedBinary() => _;

  late final String partedBinary;

  @override
  // Always required
  get isAvailable => true;

  @override
  init() async {
    final bin = await binaryExists("parted");
    if (bin != null) {
      partedBinary = bin;
    } else {
      throw Exception("Parted binary required");
    }
  }

  @override
  (String, List<String>) toCmd(List<String> arguments) => (
    partedBinary,
    [arguments[0], "-j", "-s", "unit", "b", argToArg(arguments.skip(1))],
  );
}
