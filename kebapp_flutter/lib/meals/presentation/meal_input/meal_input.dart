import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/meals/presentation/meal_input/meal_input_list.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/meals/state/edit_meal_admin_cubit.dart';

class MealInput extends StatefulWidget {
  const MealInput({
    super.key,
    required this.mealId,
  });

  final int? mealId;

  @override
  State<MealInput> createState() => _MealInputState();
}

class _MealInputState extends State<MealInput> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  var _inputs = <MealInputDto>[];

  var _isValid = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => EditMealAdminCubit(widget.mealId),
        lazy: false,
        child: BlocConsumer<EditMealAdminCubit, EditMealAdminCubitState>(
          listener: (context, state) {
            switch (state) {
              case EditMealAdminCubitLoaded(meal: final meal):
                setState(() {
                  _titleController.text = meal.title;
                  _priceController.text =
                      (meal.basePrice / 100).toStringAsFixed(2);
                  _inputs = meal.mealInputs;
                });
                _validate();
              default:
                break;
            }
          },
          builder: (context, mealState) => PageWrapper(
            pageTitle: widget.mealId == null ? 'Create Meal' : 'Edit Meal',
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: switch (mealState) {
                EditMealAdminCubitLoading() => Center(
                    child: CircularProgressIndicator(),
                  ),
                EditMealAdminCubitNoPermission() => SizedBox.shrink(),
                EditMealAdminCubitLoaded() => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              decoration:
                                  const InputDecoration(hintText: 'Title'),
                              onChanged: (value) => _validate(),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              decoration:
                                  const InputDecoration(hintText: 'Price'),
                              onChanged: (value) => _validate(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MealInputList(
                                mealInputs: _inputs
                                  ..sort((a, b) =>
                                      a.description.compareTo(b.description)),
                                onChange: (mealInputs) => setState(() {
                                  _inputs = mealInputs;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextButton(
                                onPressed: _isValid
                                    ? () async {
                                        await context
                                            .read<EditMealAdminCubit>()
                                            .upsertMeal(
                                              MealDto(
                                                id: widget.mealId ?? -1,
                                                title: _titleController.text,
                                                basePrice: _price,
                                                mealInputs: _inputs,
                                              ),
                                            );
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              },
            ),
          ),
        ),
      );
}
