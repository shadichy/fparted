import 'package:fparted/core/base.dart';
import 'package:fparted/core/model/device.dart';

final class Cached {
  static final _i = Cached._();
  Cached._();
  factory Cached() => _i;

  late List<Disk> disks;

  Disk findDisk(Device path) =>
      disks.firstWhere((element) => element.device == path);

  // 
}
