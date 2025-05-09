import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:fparted/layouts/components/part_list.dart';

class DiskScreen extends StatefulWidget {
  final Disk disk;
  const DiskScreen(this.disk, {super.key});

  @override
  State<DiskScreen> createState() => _DiskScreenState();
}

class _DiskScreenState extends State<DiskScreen> {
  late final Disk disk;
  @override
  void initState() {
    disk = widget.disk;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.undo),
                    tooltip: "Undo",
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.clear_all, color: colors.error),
                    tooltip: "Clear all jobs",
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 1,
                    height: 24,
                    child: ColoredBox(color: colors.outlineVariant),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.new_label),
                    tooltip: "New partition table",
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.help_outline),
                  tooltip: "Help",
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.info_outline),
                  tooltip: "Device properties",
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DiskPlotView(disk),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: PartitionList(disk)),
                      // Container(width: 200),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: colors.primaryContainer.withAlpha(25),
            border: Border(
              top: BorderSide(color: colors.primary.withAlpha(50)),
              left: BorderSide(color: colors.primary.withAlpha(50)),
              right: BorderSide(color: colors.primary.withAlpha(50)),
            ),
          ),
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pending jobs:"),
                    Expanded(child: ListView(children: [ListTile()])),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button and Apply button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      side: BorderSide(color: colors.primary.withAlpha(80)),
                    ),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
