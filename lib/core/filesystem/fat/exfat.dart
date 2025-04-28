import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/wrapper/exfatprogs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class ExFat extends FileSystemProp {
  static final ExFat _i = ExFat._();
  ExFat._();
  factory ExFat() => _i;

  @override
  canGrow() => true;

  @override
  canShink() => false;

  @override
  create(device) async {
    return await Wrapper.runCmd(ExfatprogsBinary().create(device));
  }

  @override
  createSync(device) {
    return Wrapper.runCmdSync(ExfatprogsBinary().create(device));
  }

  @override
  label(device, label) async {
    return await Wrapper.runCmd(ExfatprogsBinary().label(device, label));
  }

  @override
  labelSync(device, label) {
    return Wrapper.runCmdSync(ExfatprogsBinary().label(device, label));
  }

  @override
  repair(device) async {
    return await Wrapper.runCmd(ExfatprogsBinary().fix(device));
  }

  @override
  repairSync(device) {
    return Wrapper.runCmdSync(ExfatprogsBinary().fix(device));
  }

  @override
  resize(device, size) async {
    final cmd = ExfatprogsBinary().resize(device, size);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(device, size) {
    final cmd = ExfatprogsBinary().resize(device, size);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  toolChainAvailable() => ExfatprogsBinary().isAvailable();

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
