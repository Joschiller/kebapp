import 'package:flutter/material.dart';

class MultipleChoiceOption<K> {
  final K key;
  final String value;

  MultipleChoiceOption({required this.key, required this.value});
}

class MultipleChoiceInput<K> extends StatelessWidget {
  const MultipleChoiceInput({
    super.key,
    required this.values,
    required this.selectedValues,
    required this.select,
    required this.deselect,
  });

  final List<MultipleChoiceOption<K>> values;
  final List<K> selectedValues;
  final void Function(K key) select;
  final void Function(K key) deselect;

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) => Row(
          children: [
            Checkbox(
              value: selectedValues.contains(values[index].key),
              onChanged: (value) {
                if (value ?? false) {
                  select(values[index].key);
                } else {
                  deselect(values[index].key);
                }
              },
            ),
            Expanded(
              child: Text(
                values[index].value,
              ),
            ),
          ],
        ),
        itemCount: values.length,
      );
}
