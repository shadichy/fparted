import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

enum _DDMode { dd, toybox }

class DDBinary implements RequiredPackage {
  DDBinary._i();
  static final DDBinary _ = DDBinary._i();
  factory DDBinary() => _;

  late final String ddBinary;
  late final _DDMode _mode;

  @override
  // Always required
  get isAvailable => true;

  @override
  init() async {
    var bin = await binaryExists("dd");
    if (bin != null) {
      ddBinary = bin;
      _mode = _DDMode.dd;
      return;
    }
    bin = await binaryExists("toybox");
    if (bin != null) {
      ddBinary = bin;
      _mode = _DDMode.toybox;
      return;
    }
    throw Exception("blkid binary required");
  }

  @override
  toJob(job) {
    final args = ["if=${job.device.raw}", argToArg(job.arguments)];
    return switch (_mode) {
      _DDMode.dd => Job(ddBinary, args, job.label),
      _DDMode.toybox => Job(ddBinary, ["dd", ...args], job.label),
    };
  }

  Job copy({
    required String inFile,
    required String outFile,
    DataSize? blockSize,
    int? count,
    int? seek,
    int? skip,
  }) => Job(
    switch (_mode) {
      _DDMode.dd => ddBinary,
      _DDMode.toybox => ddBinary,
    },
    [
      "if=$inFile",
      "of=$outFile",
      if (blockSize != null) "bs=${blockSize.ddReadable()}",
      if (count != null) "count=$count",
      if (seek != null) "seek=$seek",
      if (skip != null) "skip=$skip",
    ],
    "Dump $inFile to $outFile",
  );
}
