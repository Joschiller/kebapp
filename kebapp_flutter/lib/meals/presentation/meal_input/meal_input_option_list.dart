import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/meals/presentation/meal_input/meal_input_option_item.dart';

class MealInputOptionList extends StatelessWidget {
  const MealInputOptionList({
    super.key,
    required this.options,
    required this.onChange,
  });

  final List<MealInputOptionDto> options;
  final void Function(List<MealInputOptionDto> mealInputs) onChange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Options:'),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) => MealInputOptionItem(
              key: Key(options[index].id.toString()),
              mealInputOption: options[index],
              onChange: (mealInputOption) => onChange([
                ...options.indexed
                    .where((element) => element.$1 != index)
                    .map((e) => e.$2),
                mealInputOption,
              ]),
              onDelete: () => onChange([
                ...options.indexed
                    .where((element) => element.$1 != index)
                    .map((e) => e.$2),
              ]),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => onChange([
              ...options,
              MealInputOptionDto(
                id: options.map((e) => e.id).fold(0, min) - 1,
                description: '',
                additionalPrice: 0,
              )
            ]),
            child: Text('Add option'),
          ),
        ],
      );
}
