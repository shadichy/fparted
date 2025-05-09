import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

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
  Job toJob(List<String> arguments) => Job(partedBinary, [
    arguments[0],
    "-j",
    "-s",
    "unit",
    "b",
    argToArg(arguments.skip(1)),
  ]);
}
