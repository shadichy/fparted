import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/dosfstools/binary.dart';
import 'package:fparted/core/runner/wrapper.dart';

class _DosData extends FileSystemData {
  const _DosData({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
    required this.variant,
  });
  factory _DosData._blkid(
    partition, [
    DosFSVariants variant = DosFSVariants.fat32,
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData =
        data ?? FileSystemData.fromPartition(partition, partedOutput);
    final regExp = RegExp(r"[0-9]+ files, [0-9]+/[0-9]+ clusters");
    final dumpData = RegExp(r"[0-9]+/[0-9]+")
        .firstMatch(
          Wrapper.runJobSync(
            DosfstoolsBinary().dump(partition),
          ).stdout.toString().split("\n").firstWhere((l) => regExp.hasMatch(l)),
        )![0]!
        .split("/");
    final blockSize = DataSize(BigInt.from(4096));
    return _DosData(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.fromBlock(BigInt.parse(dumpData.last), blockSize),
        used: DataSize.fromBlock(BigInt.parse(dumpData.first), blockSize),
      ),
      variant: DosFSVariants.fat32,
    );
  }

  final DosFSVariants variant;

  @override
  get canGrow => false;

  @override
  get canShink => false;

  @override
  label(label) => [DosfstoolsBinary().label(partition, label)];

  @override
  repair() => [DosfstoolsBinary().repair(partition)];

  @override
  get toolChainAvailable => DosfstoolsBinary().isAvailable;
}

final class Fat12 extends _DosData {
  static final _variant = DosFSVariants.fat12;

  Fat12._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Fat12(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _DosData._blkid(partition, _variant, data, partedOutput);
    return Fat12._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
    );
  }
}

final class Fat16 extends _DosData {
  static final _variant = DosFSVariants.fat16;

  Fat16._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Fat16(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _DosData._blkid(partition, _variant, data, partedOutput);
    return Fat16._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
    );
  }
}

final class Fat32 extends _DosData {
  static final _variant = DosFSVariants.fat32;

  Fat32._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.space,
    required super.blockSize,
  }) : super(variant: _variant);

  factory Fat32(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData = _DosData._blkid(partition, _variant, data, partedOutput);
    return Fat32._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      space: blkidData.space,
      blockSize: blkidData.blockSize,
    );
  }
}
