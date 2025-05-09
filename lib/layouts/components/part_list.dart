import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class PartitionTile extends StatefulWidget {
  final String device;
  final Widget fileSystem;
  final String size;
  final String used;
  final String free;
  final String name;
  final String fsName;
  final String flags;
  final String mountpoints;
  const PartitionTile({
    super.key,
    required this.device,
    required this.fileSystem,
    required this.size,
    required this.used,
    required this.free,
    required this.name,
    required this.fsName,
    required this.flags,
    required this.mountpoints,
  });

  @override
  State<PartitionTile> createState() => _PartitionTileState();
}

class _PartitionTileState extends State<PartitionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(minHeight: 30),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(widget.device)),
          SizedBox(width: 100, child: widget.fileSystem),
          SizedBox(width: 100, child: Text(widget.size)),
          SizedBox(width: 100, child: Text(widget.used)),
          SizedBox(width: 100, child: Text(widget.free)),
          SizedBox(width: 150, child: Text(widget.name)),
          SizedBox(width: 150, child: Text(widget.fsName)),
          SizedBox(width: 150, child: Text(widget.flags)),
          SizedBox(width: 200, child: Text(widget.mountpoints)),
        ],
      ),
    );
  }
}

class PartitionList extends StatefulWidget {
  final Disk disk;
  const PartitionList(this.disk, {super.key});

  @override
  State<PartitionList> createState() => _PartitionListState();
}

class _PartitionListState extends State<PartitionList> {
  late final DiskPlot disk;
  @override
  void initState() {
    disk = DiskPlot.fromDisk(widget.disk);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final table = Table(
    //   children: [
    //     TableRow(
    //       children: [
    //         Text("Partition"),
    //         Text("Filesystem"),
    //         Text("Size"),
    //         Text("Used"),
    //         Text("Free"),
    //         Text("Name"),
    //         Text("Flags"),
    //         Text("Mountpoints"),
    //       ],
    //     ),
    //     ...disk.partitions.map((part) {
    //       return TableRow(
    //         children: [
    //           Text(part.device.raw.split('/').last),
    //           Text(part.fileSystem.type.name),
    //           Text(part.size.humanReadable()),
    //           Text(part.fileSystem.space?.used.humanReadable() ?? "---"),
    //           Text(part.fileSystem.space?.free.humanReadable() ?? "---"),
    //           Text(part.fileSystem.name),
    //           Text(part.flags.map((f) => f.str).join(', ')),
    //           // Text(part.fileSystem.mountpoints.join(', ')),
    //           Text(""),
    //         ],
    //       );
    //     }),
    //   ],
    // );

    final tableData = [
      PartitionTile(
        device: "Partition",
        fileSystem: Text("Filesystem"),
        size: "Size",
        used: "Used",
        free: "Free",
        name: "Name",
        fsName: "FS label",
        flags: "Flags",
        mountpoints: "Mountpoints",
      ),

      ...disk.areas.map((part) {
        if (part is PartitionPlot) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: PartitionTile(
                device: part.device.split('/').last,
                fileSystem: Text(part.fileSystem.type.name),
                size: part.size.humanReadable(),
                used: part.fileSystem.space?.used.humanReadable() ?? "---",
                free: part.fileSystem.space?.free.humanReadable() ?? "---",
                name: part.name ?? "",
                fsName: part.fileSystem.name,
                flags: part.flags.join(', '),
                mountpoints: "",
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: PartitionTile(
                device: "Free space",
                fileSystem: Text(""),
                size: part.size.humanReadable(),
                used: "",
                free: "",
                name: "",
                fsName: "",
                flags: "",
                mountpoints: "",
              ),
            ),
          );
        }
      }),
    ];
    return TableView.builder(
      columnBuilder: (_) {
        return TableSpan(extent: FixedSpanExtent(1182));
      },
      rowBuilder: (_) {
        return TableSpan(extent: FixedSpanExtent(40));
      },
      cellBuilder: (context, vincinity) {
        return TableViewCell(child: tableData[vincinity.row]);
      },
      rowCount: tableData.length,
      columnCount: 1,
      pinnedRowCount: 1,
    );
  }
}
