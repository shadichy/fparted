import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/dosfstools/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

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
    Map partedOutput = const {},
  ]) {
    final blkidData = FileSystemData.fromPartition(partition, partedOutput);
    final dumpData = Wrapper.runCmdSync(
      DosfstoolsBinary().dump(partition),
    ).stdout.toString().split("\n").last.split("/");
    final blockSize = DataSize(BigInt.from(4096));
    return _DosData(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.fromBlock(
          BigInt.parse(dumpData.last.split(" ").first),
          blockSize,
        ),
        used: DataSize.fromBlock(
          BigInt.parse(dumpData.first.split(" ").last),
          blockSize,
        ),
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
  label(label) async {
    return await Wrapper.runCmd(DosfstoolsBinary().label(partition, label));
  }

  @override
  labelSync(label) {
    return Wrapper.runCmdSync(DosfstoolsBinary().label(partition, label));
  }

  @override
  repair() async {
    return await Wrapper.runCmd(DosfstoolsBinary().repair(partition));
  }

  @override
  repairSync() {
    return Wrapper.runCmdSync(DosfstoolsBinary().repair(partition));
  }

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

  factory Fat12(Device partition, [Map partedOutput = const {}]) {
    final data = _DosData._blkid(partition, _variant, partedOutput);
    return Fat12._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
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

  factory Fat16(Device partition, [Map partedOutput = const {}]) {
    final data = _DosData._blkid(partition, _variant, partedOutput);
    return Fat16._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
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

  factory Fat32(Device partition, [Map partedOutput = const {}]) {
    final data = _DosData._blkid(partition, _variant, partedOutput);
    return Fat32._init(
      partition: partition,
      type: data.type,
      name: data.name,
      id: data.id,
      space: data.space,
      blockSize: data.blockSize,
    );
  }
}
