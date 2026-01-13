import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.text,
    required this.destructiveAction,
  });

  final String text;
  final bool destructiveAction;

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ok',
              style: destructiveAction
                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      )
                  : null,
            ),
          ),
        ],
      );
}
