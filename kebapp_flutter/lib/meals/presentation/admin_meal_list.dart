import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/components/confirmation_dialog.dart';
import 'package:kebapp_flutter/meals/state/meal_admin_cubit.dart';
import 'package:kebapp_flutter/models/meal_input_dto_overall_price.dart';
import 'package:kebapp_flutter/routes.dart';

class AdminMealList extends StatelessWidget {
  const AdminMealList({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MealAdminCubit, MealAdminCubitState>(
        builder: (context, mealState) => switch (mealState) {
          MealAdminCubitStateLoading() => Center(
              child: CircularProgressIndicator(),
            ),
          MealAdminCubitStateNoPermission() => SizedBox.shrink(),
          MealAdminCubitStateLoaded(meals: final meals) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              AddMealRoute().push(context).then((value) {
                            if (!context.mounted) return;
                            context.read<MealAdminCubit>().reload();
                          }),
                          child: Text('Add meal'),
                        ),
                        Row(
                          children: [
                            Expanded(flex: 3, child: Text('Title')),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Price',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Inputs',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            SizedBox(width: 32),
                            Spacer(flex: 2),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: meals.length,
                          itemBuilder: (context, index) => Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(meals[index].title),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '${(meals[index].basePrice / 100).toStringAsFixed(2)} - ${(meals[index].maxPrice / 100).toStringAsFixed(2)} €',
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${meals[index].mealInputs.length}',
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: IconButton(
                                  onPressed: () => EditMealRoute(
                                    mealId: meals[index].id,
                                  ).push(context).then((value) {
                                    if (!context.mounted) return;
                                    context.read<MealAdminCubit>().reload();
                                  }),
                                  icon: Icon(Icons.edit),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: IconButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog(
                                      context: context,
                                      builder: (context) => ConfirmationDialog(
                                        text:
                                            'Do you really want to delete the meal "${meals[index].title}"?',
                                        destructiveAction: true,
                                      ),
                                    );
                                    if (!confirmed) return;
                                    if (!context.mounted) return;
                                    await context
                                        .read<MealAdminCubit>()
                                        .delete(meals[index].id);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        },
      );
}
