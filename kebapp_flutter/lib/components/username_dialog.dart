import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UsernameDialog extends StatefulWidget {
  const UsernameDialog({
    super.key,
    required this.initialValue,
    required this.onSubmit,
  });

  final String initialValue;
  final Future<void> Function(String newUserName) onSubmit;

  @override
  State<UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<UsernameDialog> {
  final _textController = TextEditingController();
  var _isValid = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
    _validate();
  }

  void _validate() {
    setState(() {
      _isValid = _textController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Change Username'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Username:'),
            TextField(
              controller: _textController,
              onChanged: (_) => _validate(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _isValid
                ? () => widget.onSubmit(_textController.text.trim()).then((_) {
                      if (context.mounted) context.pop(true);
                    })
                : null,
            child: Text('Save'),
          ),
        ],
      );
}
