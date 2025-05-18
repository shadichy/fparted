import 'package:flutter/material.dart';
import 'package:fparted/layouts/components/disk_plot.dart';
import 'package:fparted/layouts/components/material/enum_text.dart';
import 'package:fparted/layouts/dialogs/partition/edit.dart';
import 'package:fparted/layouts/dialogs/partition/flag.dart';

enum AreaOptions { Create }

enum PartitionOptions { Edit, Format, Check, Flag, Copy, Delete }

enum Options { Dump, Info }

class AreaOptionDialog extends StatelessWidget {
  final AreaPlot plot;
  const AreaOptionDialog(this.plot, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<Enum> options = [];
    options.addAll(
      plot is PartitionPlot ? PartitionOptions.values : AreaOptions.values,
    );
    options.addAll(Options.values);
    return SimpleDialog(
      title: const Text('Operations'),
      children:
          options.map((label) {
            return SimpleDialogOption(
              onPressed: () async => Navigator.pop(context, label),
              child: Text(renderEnum(label)),
            );
          }).toList(),
    );
  }
}

Future<void> showPartitionOptions(BuildContext context, AreaPlot plot) async {
  return await showDialog<Enum>(
    context: context,
    builder: (context) => AreaOptionDialog(plot),
  ).then((e) async {
    if (e == null || !context.mounted) return;
    return await _handlePartitionOption(context, plot, e);
  });
}

Future<void> _handlePartitionOption(
  BuildContext context,
  AreaPlot plot,
  Enum option,
) async {
  return switch (option) {
    AreaOptions.Create => await showPartitionCreateDialog(context, plot),
    PartitionOptions.Edit => await showPartitionEditDialog(
      context,
      plot as PartitionPlot,
    ),
    PartitionOptions.Format => throw UnimplementedError(),
    PartitionOptions.Check => throw UnimplementedError(),
    PartitionOptions.Flag => await showPartitionFlagDialog(
      context,
      plot as PartitionPlot,
    ),
    PartitionOptions.Copy => throw UnimplementedError(),
    PartitionOptions.Delete => throw UnimplementedError(),
    Options.Dump => throw UnimplementedError(),
    Options.Info => throw UnimplementedError(),
    _ => throw UnimplementedError(),
  };
}
