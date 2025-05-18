import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/classes.dart';
import 'package:fparted/layouts/components/material/enum_text.dart';
import 'package:fparted/layouts/dialogs/confirm.dart';

class CreateTableDialog extends StatefulWidget {
  final Disk disk;
  const CreateTableDialog(this.disk, {super.key});

  @override
  State<CreateTableDialog> createState() => _CreateTableDialogState();
}

class _CreateTableDialogState extends State<CreateTableDialog> {
  late final Disk disk;
  PartitionTable table = PartitionTable.GPT;

  @override
  void initState() {
    super.initState();
    disk = widget.disk;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit partition flags"),
      content: SizedBox(
        width: 200,
        child: SingleChildScrollView(
          child: Form(
            child: DropdownButtonFormField<PartitionTable>(
              value: table,
              decoration: InputDecoration(labelText: 'File system'),
              items:
                  PartitionTable.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(renderEnum(f)),
                    );
                  }).toList(),
              onChanged: (f) {
                if (f != null) {
                  setState(() => table = f);
                }
              },
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
            showConfirmDialog(
              context,
              "This will erase all data on the disk",
            ).then((b) {
              if (!b || !context.mounted) return;
              Navigator.pop(context, disk.createTable(table));
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

Future<void> showCreateTableDialog(BuildContext context, Disk disk) async {
  return await showDialog<List<Job>>(
    context: context,
    builder: (_) => CreateTableDialog(disk),
  ).then((jobs) {
    if (jobs != null) {
      Jobs.clear();
      Jobs.addAll(jobs);
    }
  });
}
