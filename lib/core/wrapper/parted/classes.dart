import 'package:fparted/core/filesystem/fs.dart';


enum DiskFlag { CYLINDER_ALIGNMENT, PMBR_BOOT }

extension DiskFlagString on DiskFlag {
  static final strMap = {
    "cylinder_alignment": DiskFlag.CYLINDER_ALIGNMENT,
    "pmbr_boot": DiskFlag.PMBR_BOOT,
  };

  static DiskFlag from(String string) =>
      strMap.entries.firstWhere((f) => f.key == string).value;
  String get str =>
      strMap.entries.firstWhere((f) => f.value.index == index).key;
}

enum PartitionTable { AIX, AMIGA, BSD, DVH, GPT, LOOP, MAC, MSDOS, PC98, SUN }

extension PartitionTableString on PartitionTable {
  static final strMap = {
    "aix": PartitionTable.AIX,
    "amiga": PartitionTable.AMIGA,
    "bsd": PartitionTable.BSD,
    "dvh": PartitionTable.DVH,
    "gpt": PartitionTable.GPT,
    "loop": PartitionTable.LOOP,
    "mac": PartitionTable.MAC,
    "msdos": PartitionTable.MSDOS,
    "mbr": PartitionTable.MSDOS,
    "pc98": PartitionTable.PC98,
    "sun": PartitionTable.SUN,
  };

  static PartitionTable from(String string) =>
      strMap.entries.firstWhere((f) => f.key == string).value;
  String get str =>
      strMap.entries.firstWhere((f) => f.value.index == index).key;
}

enum PartitionType { PRIMARY, LOGICAL, EXTENDED }

extension PartitionTypeString on PartitionType {
  static final strMap = {
    "primary": PartitionType.PRIMARY,
    "logical": PartitionType.LOGICAL,
    "extended": PartitionType.EXTENDED,
  };

  static PartitionType from(String string) =>
      strMap.entries.firstWhere((f) => f.key == string).value;
  String get str =>
      strMap.entries.firstWhere((f) => f.value.index == index).key;
}

enum PartitionFlag {
  BOOT,
  ROOT,
  SWAP,
  HIDDEN,
  RAID,
  LVM,
  LBA,
  HP_SERVICE,
  PALO,
  PREP,
  MSFTRES,
  BIOS_GRUB,
  ATVRECV,
  DIAG,
  LEGACY_BOOT,
  MSFTDATA,
  IRST,
  ESP,
  CHROMEOS_KERNEL,
  BLS_BOOT,
  LINUX_HOME,
  NO_AUTOMOUNT,
}

extension PartitionFlagString on PartitionFlag {
  static final strMap = {
    "boot": PartitionFlag.BOOT,
    "root": PartitionFlag.ROOT,
    "swap": PartitionFlag.SWAP,
    "hidden": PartitionFlag.HIDDEN,
    "raid": PartitionFlag.RAID,
    "lvm": PartitionFlag.LVM,
    "lba": PartitionFlag.LBA,
    "hp-service": PartitionFlag.HP_SERVICE,
    "palo": PartitionFlag.PALO,
    "prep": PartitionFlag.PREP,
    "msftres": PartitionFlag.MSFTRES,
    "bios_grub": PartitionFlag.BIOS_GRUB,
    "atvrecv": PartitionFlag.ATVRECV,
    "diag": PartitionFlag.DIAG,
    "legacy_boot": PartitionFlag.LEGACY_BOOT,
    "msftdata": PartitionFlag.MSFTDATA,
    "irst": PartitionFlag.IRST,
    "esp": PartitionFlag.ESP,
    "chromeos_kernel": PartitionFlag.CHROMEOS_KERNEL,
    "bls_boot": PartitionFlag.BLS_BOOT,
    "linux-home": PartitionFlag.LINUX_HOME,
    "no_automount": PartitionFlag.NO_AUTOMOUNT,
  };

  static PartitionFlag from(String string) =>
      strMap.entries.firstWhere((f) => f.key == string).value;
  String get str =>
      strMap.entries.firstWhere((f) => f.value.index == index).key;
}


enum PartitionFileSystem {
  AFFS0,
  AFFS1,
  AFFS2,
  AFFS3,
  AFFS4,
  AFFS5,
  AFFS6,
  AFFS7,
  AMUFS,
  AMUFS0,
  AMUFS1,
  AMUFS2,
  AMUFS3,
  AMUFS4,
  AMUFS5,
  APFS1,
  APFS2,
  ASFS,
  BCACHEFS,
  BTRFS,
  EXFAT,
  EXT2,
  EXT3,
  EXT4,
  F2FS,
  FAT16,
  FAT32,
  HFS,
  HFS_PLUS,
  HFSX,
  HP_UFS,
  JFS,
  LINUX_SWAP,
  LINUX_SWAP_NEW,
  LINUX_SWAP_OLD,
  LINUX_SWAP_V0,
  LINUX_SWAP_V1,
  NILFS2,
  NTFS,
  REISERFS,
  SUN_UFS,
  SWSUSP,
  UDF,
  XFS,
  LVM2,
}

extension PartitionFileSystemString on PartitionFileSystem {
  static final strMap = {
    "affs0": PartitionFileSystem.AFFS0,
    "affs1": PartitionFileSystem.AFFS1,
    "affs2": PartitionFileSystem.AFFS2,
    "affs3": PartitionFileSystem.AFFS3,
    "affs4": PartitionFileSystem.AFFS4,
    "affs5": PartitionFileSystem.AFFS5,
    "affs6": PartitionFileSystem.AFFS6,
    "affs7": PartitionFileSystem.AFFS7,
    "amufs0": PartitionFileSystem.AMUFS,
    "amufs1": PartitionFileSystem.AMUFS0,
    "amufs2": PartitionFileSystem.AMUFS1,
    "amufs3": PartitionFileSystem.AMUFS2,
    "amufs4": PartitionFileSystem.AMUFS3,
    "amufs5": PartitionFileSystem.AMUFS4,
    "amufs": PartitionFileSystem.AMUFS5,
    "apfs1": PartitionFileSystem.APFS1,
    "apfs2": PartitionFileSystem.APFS2,
    "asfs": PartitionFileSystem.ASFS,
    "bcachefs": PartitionFileSystem.BCACHEFS,
    "btrfs": PartitionFileSystem.BTRFS,
    "exfat": PartitionFileSystem.EXFAT,
    "ext2": PartitionFileSystem.EXT2,
    "ext3": PartitionFileSystem.EXT3,
    "ext4": PartitionFileSystem.EXT4,
    "f2fs": PartitionFileSystem.F2FS,
    "fat16": PartitionFileSystem.FAT16,
    "fat32": PartitionFileSystem.FAT32,
    "hfs+": PartitionFileSystem.HFS,
    "hfs": PartitionFileSystem.HFS_PLUS,
    "hfsx": PartitionFileSystem.HFSX,
    "hp-ufs": PartitionFileSystem.HP_UFS,
    "jfs": PartitionFileSystem.JFS,
    "linux-swap": PartitionFileSystem.LINUX_SWAP,
    "linux-swap(new)": PartitionFileSystem.LINUX_SWAP_NEW,
    "linux-swap(old)": PartitionFileSystem.LINUX_SWAP_OLD,
    "linux-swap(v0)": PartitionFileSystem.LINUX_SWAP_V0,
    "linux-swap(v1)": PartitionFileSystem.LINUX_SWAP_V1,
    "nilfs2": PartitionFileSystem.NILFS2,
    "ntfs": PartitionFileSystem.NTFS,
    "reiserfs": PartitionFileSystem.REISERFS,
    "sun-ufs": PartitionFileSystem.SUN_UFS,
    "swsusp": PartitionFileSystem.SWSUSP,
    "udf": PartitionFileSystem.UDF,
    "xfs": PartitionFileSystem.XFS,
    "lvm": PartitionFileSystem.LVM2,
  };

  static PartitionFileSystem from(String string) {
    return strMap.entries.firstWhere((f) => f.key == string).value;
  }

  static PartitionFileSystem fromFileSysytem(FileSystem fs) {
    String fsType = fs.str;
    if (!strMap.keys.contains(fsType)) {
      switch (fsType) {
        case "swap":
          fsType = "linux-swap(v1)";
          break;
        default:
          throw Exception("Unknown filesystem");
      }
    }
    return strMap.entries.firstWhere((f) => f.key == fsType).value;
  }

  String get str {
    return strMap.entries.firstWhere((f) => f.value.index == index).key;
  }
}
