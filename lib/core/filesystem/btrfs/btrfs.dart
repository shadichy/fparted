import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/wrapper/btrfs-progs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class BtrFS extends FileSystemProp {
  static final BtrFS _i = BtrFS._();
  BtrFS._();
  factory BtrFS() => _i;

  @override
  canGrow() => true;

  @override
  canShink() => true;

  @override
  check(device) async {
    final binary = BtrfsprogsBinary().binary;
    if (binary == null) throw Exception("btrfs toolchain does not exist");
    return await Wrapper.runCmd((binary, ["check", device.raw]));
  }

  @override
  checkSync(device) {
    final binary = BtrfsprogsBinary().binary;
    if (binary == null) throw Exception("btrfs toolchain does not exist");
    return Wrapper.runCmdSync((binary, ["check", device.raw]));
  }

  @override
  create(device) async {
    return await Wrapper.runCmd(BtrfsprogsBinary().create(device));
  }

  @override
  createSync(device) {
    return Wrapper.runCmdSync(BtrfsprogsBinary().create(device));
  }

  @override
  label(device, label) async {
    return await Wrapper.runCmd(BtrfsprogsBinary().label(device, label));
  }

  @override
  labelSync(device, label) {
    return Wrapper.runCmdSync(BtrfsprogsBinary().label(device, label));
  }

  @override
  repair(device) async {
    return await Wrapper.runCmd(BtrfsprogsBinary().fix(device));
    // more procedure
  }

  @override
  repairSync(device) {
    return Wrapper.runCmdSync(BtrfsprogsBinary().fix(device));
  }

  @override
  resize(device, size) async {
    final cmd = BtrfsprogsBinary().resize(device, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(device, size) {
    final cmd = BtrfsprogsBinary().resize(device, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  toolChainAvailable() => BtrfsprogsBinary().isAvailable();
  
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
