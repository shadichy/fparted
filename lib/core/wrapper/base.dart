import 'dart:io';

Future<String?> binaryExists(String binary) async {
  for (final path in String.fromEnvironment(
    'PATH',
    defaultValue: '/system/bin',
  ).split(":")) {
    if (await File("$path/$binary").exists()) {
      return "$path/$binary";
    }
  }
  return null;
}

String argToArg(Iterable<String>? arguments) =>
    arguments
        ?.map((e) => e.replaceAll("\\", "\\\\").replaceAll(" ", "\\ "))
        .join(" ") ??
    "";

abstract interface class Package {
  bool isAvailable();
  Future<void> init();
  (String, List<String>) toCmd(List<String> arguments);
}
