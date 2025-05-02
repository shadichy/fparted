import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/btrfs-progs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class BtrFS extends FileSystemData {
  const BtrFS._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
  });
  factory BtrFS(Device partition, [Map partedOutput = const {}]) {
    final blkidData = FileSystemData.fromPartition(partition, partedOutput);
    final dumpData = Wrapper.runCmdSync(
      BtrfsprogsBinary().dump(partition),
    ).stdout.toString().split("\n").last.split(" size ").last.split(" used ");
    return BtrFS._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blkidData.blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.parse(dumpData.first),
        used: DataSize.parse(dumpData.last.split(" ").first),
      ),
    );
  }

  @override
  get canGrow => true;

  @override
  get canShink => true;

  @override
  check() async {
    final binary = BtrfsprogsBinary().binaryMap["btrfs"];
    if (binary == null) throw Exception("btrfs toolchain does not exist");
    return await Wrapper.runCmd((binary, ["check", partition.raw]));
  }

  @override
  checkSync() {
    final binary = BtrfsprogsBinary().binaryMap["btrfs"];
    if (binary == null) throw Exception("btrfs toolchain does not exist");
    return Wrapper.runCmdSync((binary, ["check", partition.raw]));
  }

  @override
  label(label) async {
    return await Wrapper.runCmd(BtrfsprogsBinary().label(partition, label));
  }

  @override
  labelSync(label) {
    return Wrapper.runCmdSync(BtrfsprogsBinary().label(partition, label));
  }

  @override
  repair() async {
    return await Wrapper.runCmd(BtrfsprogsBinary().repair(partition));
    // more procedure
  }

  @override
  repairSync() {
    return Wrapper.runCmdSync(BtrfsprogsBinary().repair(partition));
  }

  @override
  resize(size) async {
    final cmd = BtrfsprogsBinary().resize(partition, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(size) {
    final cmd = BtrfsprogsBinary().resize(partition, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  get toolChainAvailable => BtrfsprogsBinary().isAvailable;
}
