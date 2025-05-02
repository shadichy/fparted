import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/e2fsprogs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

class _E2Data extends FileSystemData {
  const _E2Data({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
    required this.variant,
  });
  factory _E2Data._blkid(
    partition, [
    E2FSVariants variant = E2FSVariants.ext4,
    Map partedOutput = const {},
  ]) {
    final blkidData = FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(Block (size|count)|Free blocks)");
    final dumpData = Wrapper.runCmdSync(E2fsprogsBinary().dump(partition))
        .stdout
        .toString()
        .split("\n")
        .where((l) => dumpRegex.hasMatch(l))
        .map((l) => l.split(":"))
        .map((l) => (l.first, BigInt.parse(l.last.trim())));
    BigInt getData(String str) => dumpData.firstWhere((l) => l.$1 == str).$2;
    final blockSize = DataSize(getData("Block size"));
    return _E2Data(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.fromBlock(getData("Block count"), blockSize),
        used: DataSize.fromBlock(getData("Free blocks"), blockSize),
      ),
      variant: E2FSVariants.ext4,
    );
  }

  final E2FSVariants variant;

  @override
  get canGrow => true;

  @override
  get canShink => true;

  @override
  label(label) async {
    return await Wrapper.runCmd(E2fsprogsBinary().label(partition, label));
  }

  @override
  labelSync(label) {
    return Wrapper.runCmdSync(E2fsprogsBinary().label(partition, label));
  }

  @override
  repair() async {
    return await Wrapper.runCmd(E2fsprogsBinary().repair(partition));
  }

  @override
  repairSync() {
    return Wrapper.runCmdSync(E2fsprogsBinary().repair(partition));
  }

  @override
  resize(size) async {
    final cmd = E2fsprogsBinary().resize(partition, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(size) {
    final cmd = E2fsprogsBinary().resize(partition, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  get toolChainAvailable => E2fsprogsBinary().isAvailable;
}

final class Ext2 extends _E2Data {
  static final _variant = E2FSVariants.ext2;

  Ext2._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Ext2(Device partition, [Map partedOutput = const {}]) {
    final data = _E2Data._blkid(partition, _variant, partedOutput);
    return Ext2._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
    );
  }
}

final class Ext3 extends _E2Data {
  static final _variant = E2FSVariants.ext3;

  Ext3._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Ext3(Device partition, [Map partedOutput = const {}]) {
    final data = _E2Data._blkid(partition, _variant, partedOutput);
    return Ext3._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
    );
  }
}

final class Ext4 extends _E2Data {
  static final _variant = E2FSVariants.ext4;

  Ext4._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Ext4(Device partition, [Map partedOutput = const {}]) {
    final data = _E2Data._blkid(partition, _variant, partedOutput);
    return Ext4._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
    );
  }
}
