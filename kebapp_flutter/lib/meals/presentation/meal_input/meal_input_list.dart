import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/meals/presentation/meal_input/meal_input_item.dart';

class MealInputList extends StatelessWidget {
  const MealInputList({
    super.key,
    required this.mealInputs,
    required this.onChange,
  });

  final List<MealInputDto> mealInputs;
  final void Function(List<MealInputDto> mealInputs) onChange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: mealInputs.length,
            itemBuilder: (context, index) => MealInputItem(
              key: Key(mealInputs[index].id.toString()),
              mealInput: mealInputs[index],
              onChange: (mealInput) => onChange([
                ...mealInputs.indexed
                    .where((element) => element.$1 != index)
                    .map((e) => e.$2),
                mealInput,
              ]),
              onDelete: () => onChange([
                ...mealInputs.indexed
                    .where((element) => element.$1 != index)
                    .map((e) => e.$2),
              ]),
            ),
          ),
          ElevatedButton(
            onPressed: () => onChange([
              ...mealInputs,
              MealInputDto(
                id: mealInputs.map((e) => e.id).fold(0, min) - 1,
                description: '',
                multipleChoice: false,
                isExclusion: false,
                mealInputOptions: [],
              )
            ]),
            child: Text('Add input'),
          ),
        ],
      );
}
