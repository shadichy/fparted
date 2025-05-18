import 'package:flutter/material.dart';
import 'package:fparted/core/cached/cached.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/classes.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:fparted/layouts/components/material/enum_text.dart';

class PartitionEditDialog extends StatefulWidget {
  final PartitionPlot data;
  const PartitionEditDialog(this.data, {super.key});

  @override
  State<PartitionEditDialog> createState() => _PartitionEditDialogState();
}

class _PartitionEditDialogState extends State<PartitionEditDialog> {
  late final PartitionPlot data;
  Map<PartitionFlag, bool> flagStates = {};


  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit partition flags"),
      content: SizedBox(
        width: 200,
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children:
                  PartitionFlag.values.map((f) {
                    return Row(
                      children: [
                        Checkbox(
                          value: flagStates[f],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => flagStates[f] = value);
                            }
                          },
                        ),
                        Text(renderEnum(f)),
                      ],
                    );
                  }).toList(),
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
                flags:
                    flagStates.entries
                        .where((f) => f.value)
                        .map((f) => f.key)
                        .toList(),
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

Future<void> showPartitionFlagDialog(
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
