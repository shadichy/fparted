import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String message;

  const ConfirmDialog(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AlertDialog(
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            side: BorderSide(color: colors.primary.withAlpha(80)),
          ),
          child: Text('Cancel'),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: Text('Continue'),
        ),
      ],
    );
  }
}

Future<bool> showConfirmDialog(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(message),
  );
  return result ?? false;
}
