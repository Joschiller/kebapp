import 'package:flutter/material.dart';

class ConfirmableTextInput extends StatefulWidget {
  const ConfirmableTextInput({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSubmit,
  });

  final String label;
  final String initialValue;
  final void Function(String newValue) onSubmit;

  @override
  State<ConfirmableTextInput> createState() => _ConfirmableTextInputState();
}

class _ConfirmableTextInputState extends State<ConfirmableTextInput> {
  var _editMode = false;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _editMode
      ? Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.label,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _editMode = false;
                });
                widget.onSubmit(_controller.text.trim());
              },
              icon: Icon(Icons.save),
            ),
          ],
        )
      : Row(
          children: [
            Expanded(
              child: Text(_controller.text),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _editMode = true;
                });
              },
              icon: Icon(Icons.edit),
            ),
          ],
        );
}
