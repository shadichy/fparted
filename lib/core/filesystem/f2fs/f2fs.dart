import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/wrapper/f2fs-tools/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class F2FS extends FileSystemProp {
  static final F2FS _i = F2FS._();
  F2FS._();
  factory F2FS() => _i;

  @override
  canGrow() => true;

  @override
  canShink() => false;

  @override
  create(device) async {
    return await Wrapper.runCmd(F2fstoolsBinary().create(device));
  }

  @override
  createSync(device) {
    return Wrapper.runCmdSync(F2fstoolsBinary().create(device));
  }

  @override
  label(device, label) async {
    return await Wrapper.runCmd(F2fstoolsBinary().label(device, label));
  }

  @override
  labelSync(device, label) {
    return Wrapper.runCmdSync(F2fstoolsBinary().label(device, label));
  }

  @override
  repair(device) async {
    return await Wrapper.runCmd(F2fstoolsBinary().fix(device));
  }

  @override
  repairSync(device) {
    return Wrapper.runCmdSync(F2fstoolsBinary().fix(device));
  }

  @override
  resize(device, size) async {
    final cmd = F2fstoolsBinary().resize(device, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(device, size) {
    final cmd = F2fstoolsBinary().resize(device, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  toolChainAvailable() => F2fstoolsBinary().isAvailable();

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
