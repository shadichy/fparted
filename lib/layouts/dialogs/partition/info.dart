import 'package:flutter/material.dart';
import 'package:fparted/layouts/components/disk_plot.dart';

class PartitionInfoDialog extends StatelessWidget {
  final PartitionPlot data;
  const PartitionInfoDialog(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit partition flags"),
      content: SizedBox(
        width: 200,
        child: SingleChildScrollView(child: Form(child: Column())),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
      ],
    );
  }
}

Future<void> showPartitionInfoDialog(
  BuildContext context,
  PartitionPlot partition,
) async => await showDialog<void>(
  context: context,
  builder: (_) => PartitionInfoDialog(partition),
);
