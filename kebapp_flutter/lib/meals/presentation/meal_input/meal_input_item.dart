import 'package:flutter/material.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/meals/presentation/meal_input/meal_input_option_list.dart';
import 'package:kebapp_flutter/components/confirmable_text_input.dart';

class MealInputItem extends StatelessWidget {
  const MealInputItem({
    super.key,
    required this.mealInput,
    required this.onChange,
    required this.onDelete,
  });

  final MealInputDto mealInput;
  final void Function(MealInputDto mealInput) onChange;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ConfirmableTextInput(
                      label: 'Input Description',
                      initialValue: mealInput.description,
                      onSubmit: (newValue) => onChange(
                        MealInputDto(
                          id: mealInput.id,
                          description: newValue,
                          multipleChoice: mealInput.multipleChoice,
                          isExclusion: mealInput.isExclusion,
                          mealInputOptions: mealInput.mealInputOptions,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: mealInput.multipleChoice,
                    onChanged: (value) => onChange(
                      MealInputDto(
                        id: mealInput.id,
                        description: mealInput.description,
                        multipleChoice: value ?? false,
                        isExclusion: mealInput.isExclusion,
                        mealInputOptions: mealInput.mealInputOptions,
                      ),
                    ),
                  ),
                  Text('Multiple Choice'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: mealInput.isExclusion,
                    onChanged: (value) => onChange(
                      MealInputDto(
                        id: mealInput.id,
                        description: mealInput.description,
                        multipleChoice: mealInput.multipleChoice,
                        isExclusion: value ?? false,
                        mealInputOptions: mealInput.mealInputOptions,
                      ),
                    ),
                  ),
                  Text('Exclusion'),
                ],
              ),
              MealInputOptionList(
                options: (mealInput.mealInputOptions)
                  ..sort((a, b) => a.description.compareTo(b.description)),
                onChange: (mealInputs) => onChange(
                  MealInputDto(
                    id: mealInput.id,
                    description: mealInput.description,
                    multipleChoice: mealInput.multipleChoice,
                    isExclusion: mealInput.isExclusion,
                    mealInputOptions: mealInputs,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
