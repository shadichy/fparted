import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/f2fs-tools/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class F2FS extends FileSystemData {
  const F2FS._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
  });
  factory F2FS(Device partition, [Map partedOutput = const {}]) {
    final blkidData = FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(user_)?block_count");
    final dumpData = Wrapper.runCmdSync(F2fstoolsBinary().dump(partition))
        .stdout
        .toString()
        .split("\n")
        .where((l) => dumpRegex.hasMatch(l))
        .map((l) => l.split(" "))
        .map((l) => (l.first, BigInt.parse(l.last.replaceFirst("]", ""))));
    BigInt getData(String str) => dumpData.firstWhere((l) => l.$1 == str).$2;
    return F2FS._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blkidData.blockSize,
      space: FileSystemSpace.size_free(
        size: DataSize.fromBlock(getData("block_count"), blkidData.blockSize),
        free: DataSize.fromBlock(
          getData("user_block_count"),
          blkidData.blockSize,
        ),
      ),
    );
  }

  @override
  get canGrow => true;

  @override
  get canShink => false;

  @override
  check() async {
    // TODO: 
    throw UnimplementedError();
  }

  @override
  checkSync() {
    // TODO: 
    throw UnimplementedError();
  }

  @override
  label(label) async {
    return await Wrapper.runCmd(F2fstoolsBinary().label(partition, label));
  }

  @override
  labelSync(label) {
    return Wrapper.runCmdSync(F2fstoolsBinary().label(partition, label));
  }

  @override
  repair() async {
    return await Wrapper.runCmd(F2fstoolsBinary().repair(partition));
    // more procedure
  }

  @override
  repairSync() {
    return Wrapper.runCmdSync(F2fstoolsBinary().repair(partition));
  }

  @override
  resize(size) async {
    final cmd = F2fstoolsBinary().resize(partition, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(size) {
    final cmd = F2fstoolsBinary().resize(partition, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  get toolChainAvailable => F2fstoolsBinary().isAvailable;
}
