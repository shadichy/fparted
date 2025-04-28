import 'dart:io';

import 'package:fparted/core/wrapper/base.dart';

class SuBinary implements Package {
  SuBinary._i();
  static final SuBinary _ = SuBinary._i();
  factory SuBinary() => _;

  late final String suBinary;

  @override
  // Always required
  isAvailable() => true;

  @override
  init() async {
    suBinary = (await binaryExists("su")) ?? "/system/bin/su";
    if (Process.runSync(suBinary, ["-c", ":"]).exitCode != 0) {
      throw Exception("Root required");
    }
  }

  @override
  (String, List<String>) toCmd(List<String> arguments) => (
    suBinary,
    ["-c", argToArg(arguments)],
  );
}
