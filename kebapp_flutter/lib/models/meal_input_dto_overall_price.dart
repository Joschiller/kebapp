import 'dart:math';

import 'package:kebapp_client/kebapp_client.dart';

extension MealInputDtoOverallPrice on MealDto {
  int get maxPrice =>
      basePrice +
      mealInputs
          .map(((i) =>
              i.mealInputOptions.map((o) => o.additionalPrice).fold(0, max)))
          .fold(0, (a, b) => a + b);

  int getPriceWithSelection(List<int> selectedMealInputOptionIds) =>
      basePrice +
      mealInputs
          // get all selected options
          .map((i) => i.mealInputOptions.where((availableOption) =>
              selectedMealInputOptionIds.contains(availableOption.id)))
          // sum up the options
          .expand((i) => i)
          .map((o) => o.additionalPrice)
          .fold(0, (a, b) => a + b);
}
