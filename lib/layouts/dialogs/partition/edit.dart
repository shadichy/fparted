import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fparted/core/cached/cached.dart';
import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/classes.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:fparted/layouts/components/material/enum_text.dart';

class _SizeEditSpace {
  final DataSize pre;
  final DataSize post;

  const _SizeEditSpace(this.pre, this.post);
}

class _SizeEdit extends StatefulWidget {
  final FutureOr<void> Function(_SizeEditSpace data) callback;
  final AreaPlot data;
  final List<Widget> children;
  final Axis axis;

  const _SizeEdit({
    required this.data,
    required this.callback,
    this.children = const [],
    this.axis = Axis.horizontal,
  });

  @override
  State<_SizeEdit> createState() => _SizeEditState();
}

class _SizeEditState extends State<_SizeEdit> {
  late final FutureOr<void> Function(_SizeEditSpace data) callback;
  DataSize freePre = DataSize.zero;
  DataSize freePost = DataSize.zero;
  DataSize newSize = DataSize.zero;

  final freePreCtrl = TextEditingController(text: "0");
  final freePostCtrl = TextEditingController(text: "0");
  final newSizeCtrl = TextEditingController();
  Unit selectedUnit = Unit.miB;

  late final Flex Function({
    List<Widget> children,
    CrossAxisAlignment crossAxisAlignment,
    Key? key,
    MainAxisAlignment mainAxisAlignment,
    MainAxisSize mainAxisSize,
    double spacing,
    TextBaseline? textBaseline,
    TextDirection? textDirection,
    VerticalDirection verticalDirection,
  })
  axis;

  late final Widget Function({required Widget child}) wrapper;

  @override
  void initState() {
    super.initState();
    callback = widget.callback;
    if (widget.axis == Axis.horizontal) {
      axis = Row.new;
      wrapper = ({required Widget child}) => Expanded(child: child);
    } else {
      axis = Column.new;
      wrapper = ({required Widget child}) => child;
    }
    newSize = widget.data.size;
    newSizeCtrl.text = "${newSize.inUnit(selectedUnit)}";
  }

  void updateSize({DataSize? pre, DataSize? post}) {
    if (pre == null && post == null) return;
    if (pre != null) {
      freePre = pre;
      newSize -= pre;
    }
    if (post != null) {
      freePost = post;
      newSize += post;
    }
    setState(() {
      freePreCtrl.text = "${freePre.inUnit(selectedUnit)}";
      freePostCtrl.text = "${freePost.inUnit(selectedUnit)}";
      newSizeCtrl.text = "${newSize.inUnit(selectedUnit)}";
    });
    callback(_SizeEditSpace(freePre, freePost));
  }

  @override
  Widget build(BuildContext context) {
    final unitName = renderEnum(selectedUnit);
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: freePreCtrl,
          decoration: InputDecoration(
            labelText: 'Free space preceding $unitName',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            updateSize(pre: DataSize.parse(value));
          },
        ),
        TextFormField(
          controller: newSizeCtrl,
          decoration: InputDecoration(labelText: 'New size $unitName'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            updateSize(post: freePre + DataSize.parse(value));
          },
        ),
        TextFormField(
          controller: freePostCtrl,
          decoration: InputDecoration(
            labelText: 'Free space following $unitName',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            updateSize(post: DataSize.parse(value));
          },
        ),
        DropdownButtonFormField<Unit>(
          value: selectedUnit,
          decoration: InputDecoration(labelText: 'Align to (Unit)'),
          items: [
            DropdownMenuItem(
              value: selectedUnit,
              child: Text(renderEnum(selectedUnit)),
            ),
          ],
          onChanged: (u) {
            if (u != null) {
              setState(() {
                selectedUnit = u;
              });
            }
          },
        ),
      ],
    );
    var childrenWrapper = Column(children: widget.children);
    return axis(
      children: [
        wrapper(child: fields),
        SizedBox(width: 16, height: 16),
        wrapper(child: childrenWrapper),
      ],
    );
  }
}

class PartitionCreateDialog extends StatefulWidget {
  final AreaPlot data;
  const PartitionCreateDialog(this.data, {super.key});

  @override
  State<PartitionCreateDialog> createState() => _PartitionCreateDialogState();
}

class _PartitionCreateDialogState extends State<PartitionCreateDialog> {
  late final AreaPlot data;
  PartitionType selectedType = PartitionType.PRIMARY;
  FileSystem selectedFs = FileSystem.ext4;
  _SizeEditSpace space = _SizeEditSpace(DataSize.zero, DataSize.zero);

  final nameCtrl = TextEditingController();
  final labelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create partition"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            child: _SizeEdit(
              data: data,
              callback: (data) => setState(() => space = data),
              children: [
                DropdownButtonFormField<PartitionType>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Create as (type)'),
                  items:
                      PartitionType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(renderEnum(t)),
                        );
                      }).toList(),
                  onChanged: (t) {
                    if (t != null) {
                      setState(() => selectedType = t);
                    }
                  },
                ),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Partition name'),
                ),
                DropdownButtonFormField<FileSystem>(
                  value: selectedFs,
                  decoration: InputDecoration(labelText: 'File system'),
                  items:
                      FileSystemAvailability.availableTypes.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(renderEnum(f)),
                        );
                      }).toList(),
                  onChanged: (f) {
                    if (f != null) {
                      setState(() => selectedFs = f);
                    }
                  },
                ),
                TextFormField(
                  controller: labelCtrl,
                  decoration: InputDecoration(labelText: 'Label'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final disk = Cached().findDisk(data.disk);
            Navigator.pop(
              context,
              disk.create(
                start: data.start + space.pre,
                end: data.end - space.post,
                type: selectedType,
                fileSystem: selectedFs,
                partitionLabel: nameCtrl.text,
                fileSystemLabel: labelCtrl.text,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class PartitionEditDialog extends StatefulWidget {
  final PartitionPlot data;
  const PartitionEditDialog(this.data, {super.key});

  @override
  State<PartitionEditDialog> createState() => _PartitionEditDialogState();
}

class _PartitionEditDialogState extends State<PartitionEditDialog> {
  late final PartitionPlot data;
  PartitionType selectedType = PartitionType.PRIMARY;
  FileSystem selectedFs = FileSystem.ext4;
  _SizeEditSpace space = _SizeEditSpace(DataSize.zero, DataSize.zero);

  final labelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit partition"),
      content: SizedBox(
        width: 200,
        child: SingleChildScrollView(
          child: Form(
            child: _SizeEdit(
              axis: Axis.vertical,
              data: data,
              callback: (data) => setState(() => space = data),
              children: [
                DropdownButtonFormField<FileSystem>(
                  value: selectedFs,
                  decoration: InputDecoration(labelText: 'File system'),
                  items:
                      FileSystemAvailability.availableTypes.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(renderEnum(f)),
                        );
                      }).toList(),
                  onChanged: (f) {
                    if (f != null) {
                      setState(() => selectedFs = f);
                    }
                  },
                ),
                TextFormField(
                  controller: labelCtrl,
                  decoration: InputDecoration(labelText: 'Label'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final part = Cached()
                .findDisk(data.disk)
                .partitions
                .firstWhere((p) => p.device.raw == data.device);
            Navigator.pop(
              context,
              part.edit(
                start: data.start + space.pre,
                end: data.end - space.post,
                fs: selectedFs,
                fsName: labelCtrl.text,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

Future<void> showPartitionCreateDialog(BuildContext context, AreaPlot area) async {
  return await showDialog<List<Job>>(
    context: context,
    builder: (_) => PartitionCreateDialog(area),
  ).then((jobs) {
    if (jobs != null) Jobs.addAll(jobs);
  });
}

Future<void> showPartitionEditDialog(
  BuildContext context,
  PartitionPlot partition,
) async {
  return await showDialog<List<Job>>(
    context: context,
    builder: (_) => PartitionEditDialog(partition),
  ).then((jobs) {
    if (jobs != null) Jobs.addAll(jobs);
  });
}
