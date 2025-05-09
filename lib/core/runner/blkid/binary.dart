import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/job.dart';

enum _BlkidMode { blkid, toybox }

class BlkidBinary implements RequiredPackage {
  BlkidBinary._i();
  static final BlkidBinary _ = BlkidBinary._i();
  factory BlkidBinary() => _;

  late final String blkidBinary;
  late final _BlkidMode _mode;

  @override
  // Always required
  get isAvailable => true;

  @override
  init() async {
    var bin = await binaryExists("blkid");
    if (bin != null) {
      blkidBinary = bin;
      _mode = _BlkidMode.blkid;
      return;
    }
    bin = await binaryExists("toybox");
    if (bin != null) {
      blkidBinary = bin;
      _mode = _BlkidMode.toybox;
      return;
    }
    throw Exception("blkid binary required");
  }

  @override
  Job toJob(List<String> arguments) {
    final args = [arguments[0], argToArg(arguments.skip(1))];
    return switch (_mode) {
      _BlkidMode.blkid => Job(blkidBinary, args),
      _BlkidMode.toybox => Job(blkidBinary, ["blkid", ...args]),
    };
  }
}
