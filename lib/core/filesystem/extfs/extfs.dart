import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/wrapper/e2fsprogs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

abstract class ExtFSProp extends FileSystemProp {
  E2FSVariants get variant;

  @override
  canGrow() => true;

  @override
  canShink() => true;

  @override
  create(device) async {
    return await Wrapper.runCmd(E2fsprogsBinary().create(device, variant));
  }

  @override
  createSync(device) {
    return Wrapper.runCmdSync(E2fsprogsBinary().create(device, variant));
  }

  @override
  label(device, label) async {
    return await Wrapper.runCmd(E2fsprogsBinary().label(device, label));
  }

  @override
  labelSync(device, label) {
    return Wrapper.runCmdSync(E2fsprogsBinary().label(device, label));
  }

  @override
  repair(device) async {
    return await Wrapper.runCmd(E2fsprogsBinary().fix(device));
  }

  @override
  repairSync(device) {
    return Wrapper.runCmdSync(E2fsprogsBinary().fix(device));
  }

  @override
  resize(device, size) async {
    final cmd = E2fsprogsBinary().resize(device, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(device, size) {
    final cmd = E2fsprogsBinary().resize(device, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  toolChainAvailable() => E2fsprogsBinary().isAvailable();
  
  @override
  blockSize(device) {
    // TODO: implement blockSize
    throw UnimplementedError();
  }

  @override
  getId(device) {
    // TODO: implement getId
    throw UnimplementedError();
  }

  @override
  getName(device) {
    // TODO: implement getName
    return super.getName(device);
  }

  @override
  getSpace(device) {
    // TODO: implement getSpace
    return super.getSpace(device);
  }
}

final class Ext2 extends ExtFSProp {
  static final Ext2 _i = Ext2._();
  Ext2._();
  factory Ext2() => _i;

  @override
  get variant => E2FSVariants.ext2;
}

final class Ext3 extends ExtFSProp {
  static final Ext3 _i = Ext3._();
  Ext3._();
  factory Ext3() => _i;

  @override
  get variant => E2FSVariants.ext3;
}

final class Ext4 extends ExtFSProp {
  static final Ext4 _i = Ext4._();
  Ext4._();
  factory Ext4() => _i;

  @override
  get variant => E2FSVariants.ext4;
}
