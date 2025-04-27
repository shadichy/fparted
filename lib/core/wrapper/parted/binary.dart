import 'package:fparted/core/wrapper/base.dart';

class PartedBinary implements Package {
  PartedBinary._i();
  static final PartedBinary _ = PartedBinary._i();
  factory PartedBinary() => _;

  late final String partedBinary;

  @override
  isAvailable() {
    // Always required
    return true;
  }

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
  toCmd(List<String> arguments) => (
    partedBinary,
    [arguments[0], "--json", argToArg(arguments.skip(1))],
  );
}