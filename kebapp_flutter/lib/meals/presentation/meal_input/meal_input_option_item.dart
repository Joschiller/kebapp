import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kebapp_client/kebapp_client.dart';

class MealInputOptionItem extends StatefulWidget {
  const MealInputOptionItem({
    super.key,
    required this.mealInputOption,
    required this.onChange,
    required this.onDelete,
  });

  final MealInputOptionDto mealInputOption;
  final void Function(MealInputOptionDto mealInputOption) onChange;
  final void Function() onDelete;

  @override
  State<MealInputOptionItem> createState() => _MealInputOptionItemState();
}

class _MealInputOptionItemState extends State<MealInputOptionItem> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  var _isValid = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _titleController.text = widget.mealInputOption.description;
      _priceController.text =
          (widget.mealInputOption.additionalPrice / 100).toStringAsFixed(2);
    });
    _validate();
  }

  void _validate() {
    final isValid = _titleController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text) != null &&
        (!_priceController.text.contains('.') ||
            _priceController.text.indexOf('.') >=
                _priceController.text.length - 3);
    setState(() {
      _isValid = isValid;
    });
  }

  int get _price =>
      ((double.tryParse(_priceController.text) ?? 0) * 100).toInt();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Option'),
              onChanged: (value) => _validate(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _priceController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(hintText: 'Price'),
              onChanged: (value) => _validate(),
            ),
          ),
          SizedBox(width: 16),
          IconButton(
            onPressed: _isValid &&
                    (widget.mealInputOption.description !=
                            _titleController.text.trim() ||
                        widget.mealInputOption.additionalPrice != _price)
                ? () => widget.onChange(
                      MealInputOptionDto(
                        id: widget.mealInputOption.id,
                        description: _titleController.text.trim(),
                        additionalPrice: _price,
                      ),
                    )
                : null,
            icon: Icon(Icons.save),
          ),
          SizedBox(height: 16),
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(Icons.delete),
          ),
        ],
      );
}
