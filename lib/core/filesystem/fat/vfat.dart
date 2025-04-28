import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/wrapper/dosfstools/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

abstract class DosFSProp extends FileSystemProp {
  DosFSVariants get variant;

  @override
  canGrow() => true;

  @override
  canShink() => true;

  @override
  create(device) async {
    return await Wrapper.runCmd(DosfstoolsBinary().create(device, variant));
  }

  @override
  createSync(device) {
    return Wrapper.runCmdSync(DosfstoolsBinary().create(device, variant));
  }

  @override
  label(device, label) async {
    return await Wrapper.runCmd(
      DosfstoolsBinary().label(device, label, variant),
    );
  }

  @override
  labelSync(device, label) {
    return Wrapper.runCmdSync(DosfstoolsBinary().label(device, label, variant));
  }

  @override
  repair(device) async {
    return await Wrapper.runCmd(DosfstoolsBinary().fix(device, variant));
  }

  @override
  repairSync(device) {
    return Wrapper.runCmdSync(DosfstoolsBinary().fix(device, variant));
  }

  @override
  resize(device, size) async {
    final cmd = DosfstoolsBinary().resize(device, size, variant);
    if (cmd != null) return await Wrapper.runCmd(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  resizeSync(device, size) {
    final cmd = DosfstoolsBinary().resize(device, size, variant);
    if (cmd != null) return Wrapper.runCmdSync(cmd);
    throw Exception("Cant resize filesystem");
  }

  @override
  toolChainAvailable() => DosfstoolsBinary().isAvailable();

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

final class Msdos extends DosFSProp {
  static final Msdos _i = Msdos._();
  Msdos._();
  factory Msdos() => _i;

  @override
  get variant => DosFSVariants.dos;
}

final class Fat12 extends DosFSProp {
  static final Fat12 _i = Fat12._();
  Fat12._();
  factory Fat12() => _i;

  @override
  get variant => DosFSVariants.fat12;
}

final class Fat16 extends DosFSProp {
  static final Fat16 _i = Fat16._();
  Fat16._();
  factory Fat16() => _i;

  @override
  get variant => DosFSVariants.fat16;
}

final class Fat32 extends DosFSProp {
  static final Fat32 _i = Fat32._();
  Fat32._();
  factory Fat32() => _i;

  @override
  get variant => DosFSVariants.fat32;
}
