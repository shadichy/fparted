import 'dart:io';

import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

class SuBinary implements RequiredPackage {
  SuBinary._i();
  static final SuBinary _ = SuBinary._i();
  factory SuBinary() => _;

  late final String suBinary;

  @override
  // Always required
  get isAvailable => true;

  bool initialized = false;

  @override
  init() async {
    if (Platform.isAndroid) {
      suBinary = (await binaryExists("su")) ?? "/system/bin/su";
      if (Process.runSync(suBinary, ["-c", ":"]).exitCode != 0) {
        throw Exception("Root required");
      }
    } else if (Platform.isLinux) {
      suBinary = "su";
    } else {
      throw Exception("Unsupported platform");
    }
    initialized = true;
  }

  @override
  toJob(List<String> arguments) {
    final args = argToArg(arguments);
    if (Platform.isAndroid) {
      return Job(suBinary, ["-c", args]);
    } else if (Platform.isLinux) {
      return Job("pkexec", ["su", "-c", args]);
    } else {
      throw Exception("Unsupported platform");
    }
  }
}
