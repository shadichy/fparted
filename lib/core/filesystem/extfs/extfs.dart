import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/e2fsprogs/binary.dart';
import 'package:fparted/core/runner/wrapper.dart';

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
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData =
        data ?? FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(Block (size|count)|Free blocks)");
    final dumpData = Wrapper.runJobSync(E2fsprogsBinary().dump(partition))
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
  label(label) => [E2fsprogsBinary().label(partition, label)];

  @override
  repair() => [E2fsprogsBinary().repair(partition)];

  @override
  resize(size) => [E2fsprogsBinary().resize(partition, size)];

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

  factory Ext2(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _E2Data._blkid(partition, _variant, data, partedOutput);
    return Ext2._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
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

  factory Ext3(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _E2Data._blkid(partition, _variant, data, partedOutput);
    return Ext3._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
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

  factory Ext4(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _E2Data._blkid(partition, _variant, data, partedOutput);
    return Ext4._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
    );
  }
}
