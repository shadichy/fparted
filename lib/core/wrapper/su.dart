import 'package:fparted/core/wrapper/base.dart';

class SuBinary implements Package {
  SuBinary._i();
  static final SuBinary _ = SuBinary._i();
  factory SuBinary() => _;

  late final String suBinary;

  @override
  isAvailable() {
    // Always required
    return true;
  }

  @override
  init() async {
    final su = await binaryExists("su");
    if (su != null) {
      suBinary = su;
    } else {
      throw Exception("Root required");
    }
  }

  @override
  toCmd(List<String> arguments) => (
    suBinary,
    ["-c", argToArg(arguments)],
  );
}
