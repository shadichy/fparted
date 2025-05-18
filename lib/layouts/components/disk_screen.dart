import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/classes.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:fparted/layouts/components/part_list.dart';
import 'package:fparted/layouts/dialogs/dialog.dart';
import 'package:fparted/layouts/dialogs/disk/partition_table.dart';
import 'package:material_symbols_icons/symbols.dart';

class DiskScreen extends StatefulWidget {
  final Disk disk;

  const DiskScreen(this.disk, {super.key});

  @override
  State<DiskScreen> createState() => _DiskScreenState();
}

class _DiskScreenState extends State<DiskScreen> with TickerProviderStateMixin {
  late final Disk disk;

  late final AnimationController _diskInfoController;
  late final Animation<double> _diskInfoSizeAnim;
  late final Animation<double> _diskInfoOpacityAnim;

  late final AnimationController _pendingController;
  late final Animation<double> _pendingSizeAnim;
  late final Animation<double> _pendingOpacityAnim;

  @override
  void dispose() {
    _diskInfoController.dispose();
    _pendingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    disk = widget.disk;
    _diskInfoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _diskInfoSizeAnim = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(
        parent: _diskInfoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _diskInfoOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _diskInfoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _pendingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _pendingSizeAnim = Tween<double>(begin: 0, end: 200).animate(
      CurvedAnimation(
        parent: _pendingController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _pendingOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pendingController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  void updateState(VoidCallback fn) {
    fn();
    if (Jobs.jobs.isEmpty) {
      _pendingController.reverse();
    } else {
      _pendingController.forward();
    }
    setState(() {});
  }

  Widget _e(Widget child) => Expanded(child: child);

  Widget _c([List<Widget> childen = const []]) => Column(children: childen);

  Widget _r([List<Widget> childen = const []]) => Row(children: childen);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boxBorderSide = BorderSide(color: colors.primary.withAlpha(50));
    return _c([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _r([
              IconButton(
                onPressed: () => updateState(() => Jobs.undo()),
                icon: Icon(Icons.undo),
                tooltip: "Undo",
              ),
              IconButton(
                onPressed: () => updateState(() => Jobs.clear()),
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
                onPressed: () {
                  showCreateTableDialog(
                    context,
                    disk,
                  ).then((_) => updateState(() {}));
                },
                icon: Icon(Icons.new_label),
                tooltip: "New partition table",
              ),
            ]),
          ),
          _r([
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.help_outline),
              tooltip: "Help",
            ),
            IconButton(
              onPressed: () {
                _diskInfoController.status == AnimationStatus.completed
                    ? _diskInfoController.reverse()
                    : _diskInfoController.forward();
              },
              icon: Icon(Icons.info_outline),
              tooltip: "Device properties",
            ),
          ]),
        ],
      ),
      _e(
        _c([
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: DiskPlotView(disk),
          ),
          _e(
            _r([
              _e(
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: PartitionList(
                    disk,
                    stateUpdater: () => updateState(() {}),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _diskInfoController,
                builder: (context, child) {
                  return SizedBox(
                    width: _diskInfoSizeAnim.value,
                    child: Opacity(
                      opacity: _diskInfoOpacityAnim.value,
                      child: child,
                    ),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraint) {
                    return Container(
                      width: 250,
                      height: constraint.maxHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        color: colors.primaryContainer.withAlpha(25),
                        border: Border(
                          top: boxBorderSide,
                          left: boxBorderSide,
                          bottom: boxBorderSide,
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ListTile(
                                title: Text("Drive properties"),
                                leading: Icon(Symbols.page_info),
                              ),
                            ),
                            ListTile(
                              title: Text("Model"),
                              subtitle: Text(disk.model),
                            ),
                            ListTile(
                              title: Text("Size"),
                              subtitle: Text(disk.size.humanReadable()),
                            ),
                            ListTile(
                              title: Text("Path"),
                              subtitle: Text(disk.device.raw),
                            ),
                            Divider(color: Colors.transparent, height: 10),
                            if (disk.table != null)
                              ListTile(
                                title: Text("Partition table"),
                                subtitle: Text(disk.table!.str),
                              ),
                            ListTile(
                              title: Text("Sector size"),
                              subtitle: Text("${disk.phyicalSectorSize}"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ]),
      ),
      AnimatedBuilder(
        animation: _pendingController,
        builder: (_, child) {
          return SizedBox(
            height: _pendingSizeAnim.value,
            child: Opacity(opacity: _pendingOpacityAnim.value, child: child),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Container(
              height: 200,
              width: constraint.maxWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: colors.primaryContainer.withAlpha(25),
                border: Border(
                  top: boxBorderSide,
                  left: boxBorderSide,
                  right: boxBorderSide,
                ),
              ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(right: 16, top: 16),
              child: Column(
                children: [
                  _e(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pending jobs:"),
                        _e(
                          ListView(
                            children:
                                Jobs.jobs.map((job) {
                                  return ListTile(
                                    title: Text(job.label),
                                    subtitle: Text(job.toString()),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                        onPressed: () {
                          showConfirmDialog(
                            context,
                            "Warning: This may lead to data loss! Continue?",
                          ).then((b) {
                            if (!b || !mounted) return;
                            // Jobs.runJobsSync();
                          });
                        },
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
            );
          },
        ),
      ),
    ]);
  }
}
