import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/runner/parted/classes.dart';
import 'package:fparted/layouts/components/material/flex.dart';

Color? fsColorMap(FileSystem fs) => switch (fs) {
  FileSystem.affs => Colors.orange[300],
  FileSystem.apfs => Colors.deepPurple[300],
  FileSystem.bcachefs => Colors.deepOrange,
  FileSystem.btrfs => Colors.deepOrange[300],
  FileSystem.exfat => Colors.green[700],
  FileSystem.ext2 => Colors.blue[100],
  FileSystem.ext3 => Colors.blue[300],
  FileSystem.ext4 => Colors.blue[500],
  FileSystem.f2fs => Colors.red,
  FileSystem.fat12 => Colors.green[100],
  FileSystem.fat16 => Colors.green[300],
  FileSystem.fat32 => Colors.green[500],
  FileSystem.hfs => Colors.purple[300],
  FileSystem.hfs_plus => Colors.purple,
  FileSystem.jfs => Colors.amber,
  FileSystem.ntfs => Colors.teal,
  FileSystem.reiserfs => Colors.indigo[300],
  FileSystem.reiser4 => Colors.indigo,
  FileSystem.xfs => Colors.yellow,
  FileSystem.lvm2 => Colors.brown[300],
  FileSystem.zfs => Colors.pink,
  FileSystem.squashfs => Colors.brown[500],
  FileSystem.erofs => Colors.brown[700],
  FileSystem.none => Colors.black,
  FileSystem.swap => Colors.grey,
};

class AreaPlot {
  final DataSize start;
  final DataSize end;

  const AreaPlot({required this.start, required this.end});

  DataSize get size => end - start;

  PartitionPlot toPartition({
    required String? name,
    required FileSystemData fileSystem,
    required List<String> flags,
  }) => PartitionPlot(
    start: start,
    end: end,
    device: "New partition",
    fileSystem: fileSystem,
    flags: flags,
  );
}

class PartitionPlot extends AreaPlot {
  final String device;
  final String? name;
  final FileSystemData fileSystem;
  final List<String> flags;

  const PartitionPlot({
    required super.start,
    required super.end,
    required this.device,
    required this.fileSystem,
    this.name,
    required this.flags,
  });

  factory PartitionPlot.fromPartition(Partition partition) => PartitionPlot(
    start: partition.start,
    end: partition.end,
    device: partition.device.raw,
    fileSystem: partition.fileSystem,
    name: partition.name,
    flags: partition.flags.map((f) => f.str).toList(),
  );
}

class DiskPlot {
  final List<AreaPlot> areas;
  final DataSize size;

  const DiskPlot({required this.areas, required this.size});
  static final one = DataSize(BigInt.one);
  static final oneMiB = DataSize.miB(BigInt.one);

  factory DiskPlot.fromDisk(Disk disk) {
    final partitions = disk.partitions;
    if (partitions.isEmpty) {
      return DiskPlot(
        areas: [AreaPlot(start: one, end: disk.size)],
        size: disk.size,
      );
    }
    partitions.sort((a, b) => a.number.compareTo(b.number));
    final areas = partitions.fold(<AreaPlot>[], (p, n) {
      final startSector = p.isEmpty ? DataSize.zero : p.last.end;
      if (n.start > startSector + oneMiB) {
        p.add(AreaPlot(start: startSector + one, end: n.start - one));
      }
      p.add(PartitionPlot.fromPartition(n));
      return p;
    });
    if (areas.last.end < disk.size - oneMiB) {
      areas.add(AreaPlot(start: areas.last.end + one, end: disk.size));
    }
    return DiskPlot(areas: areas, size: disk.size);
  }
}

class DiskPlotView extends StatelessWidget {
  final DiskPlot disk;
  DiskPlotView(final Disk disk, {super.key}) : disk = DiskPlot.fromDisk(disk);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    FlexRowComponent componentArea(AreaPlot area) => FlexRowComponent.builder(
      widthPercent: area.size.inB / disk.size.inB,
      builder: (context, size) {
        if (area is PartitionPlot) {
          if (size.width < 16) {
            // display partition color only
            return Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
              color: fsColorMap(area.fileSystem.type),
            );
          } else {
            Widget? content;
            if (size.width > 100) {
              // show name and size
              content = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(area.device), Text(area.size.humanReadable())],
              );
            }
            // filesystem part: show filesystem size/partition size
            // - subplot: show used/total of filesystem
            if (area.fileSystem.space != null) {
              final fsWidth =
                  (size.width - 4) *
                  (area.fileSystem.space!.size.inB / area.size.inB);
              final fsLeftWidth =
                  (fsWidth - 16) *
                  (area.fileSystem.space!.free.inB /
                      area.fileSystem.space!.size.inB);
              return Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
                color: colors.surfaceContainerHighest,
                width: size.width - 4,
                height: size.height - 16,
                child: Container(
                  padding: EdgeInsets.all(4),
                  width: fsWidth,
                  height: size.height - 16,
                  color: fsColorMap(area.fileSystem.type),
                  alignment: Alignment.center,
                  child: Container(
                    width: fsWidth - 8,
                    height: size.height - 24,
                    color: colors.surfaceContainerHigh,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          right: fsLeftWidth,
                          child: ColoredBox(
                            color: colors.tertiary.withAlpha(40),
                          ),
                        ),
                        Positioned.fill(child: Center(child: content)),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
                color: fsColorMap(area.fileSystem.type),
                padding: EdgeInsets.all(4),
                width: size.width - 4,
                height: size.height - 16,
                child: Container(
                  width: size.width - 12,
                  height: size.height - 24,
                  color: colors.surfaceContainerHigh,
                  alignment: Alignment.center,
                  child: content,
                ),
              );
            }
          }
        } else {
          Widget? content;
          if (size.width > 100) {
            content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Free space"), Text(area.size.humanReadable())],
            );
          }
          return Container(
            margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
            alignment: Alignment.center,
            color: colors.surfaceContainerHighest,
            child: content,
          );
        }
      },
    );

    FlexRowComponent componentAreaSmallScreen(AreaPlot area) =>
        FlexRowComponent(
          widthPercent: area.size.inB / disk.size.inB,
          child: Container(
            color:
                area is PartitionPlot
                    ? fsColorMap(area.fileSystem.type)
                    : colors.surfaceContainerHighest,
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 8 * disk.areas.length) {
          return FlexRow(
            minWidth: 8,
            height: 100,
            children: disk.areas.map(componentArea).toList(),
          );
        } else {
          return FlexRow(
            minWidth: 4,
            height: 100,
            children: disk.areas.map(componentAreaSmallScreen).toList(),
          );
        }
      },
    );
  }
}
