import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/orders/presentation/order_input/multiple_choice_input.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/meals/state/meal_user_cubit.dart';
import 'package:kebapp_flutter/models/meal_input_option_dto_to_string.dart';
import 'package:kebapp_flutter/orders/state/edit_order_cubit.dart';

class OrderInput extends StatefulWidget {
  const OrderInput({super.key, required this.groupId});

  final int groupId;

  @override
  State<OrderInput> createState() => _OrderInputState();
}

class _OrderInputState extends State<OrderInput> {
  var _selectedMealId = null as int?;
  final _remarksController = TextEditingController();
  var _options = <int>[];

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MealUserCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => EditOrderCubit(widget.groupId),
            lazy: false,
          ),
        ],
        child: BlocBuilder<MealUserCubit, MealUserCubitState>(
          builder: (context, mealState) =>
              BlocConsumer<EditOrderCubit, EditOrderCubitState>(
            listener: (context, state) {
              switch (state) {
                case EditOrderCubitLoaded(order: final order):
                  if (order != null) {
                    _selectedMealId = order.mealId;
                    _remarksController.text = order.remarks;
                    _options = order.mealInputOptionIds;
                  }
                default:
                  break;
              }
            },
            builder: (context, orderState) => PageWrapper(
              pageTitle: 'Edit Order',
              builder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: switch (mealState) {
                  MealUserCubitStateLoading() => Center(
                      child: CircularProgressIndicator(),
                    ),
                  MealUserCubitStateNoPermission() => SizedBox.shrink(),
                  MealUserCubitStateLoaded(meals: final meals) => Builder(
                      builder: (context) {
                        final selectedMeal = meals
                            .where((meal) => meal.id == _selectedMealId)
                            .firstOrNull;

                        final mealInputs = selectedMeal?.mealInputs
                          ?..sort(
                              (a, b) => a.description.compareTo(b.description));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('1. Select a meal'),
                            Divider(),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton<int>(
                                        hint: Text('Meal'),
                                        value: _selectedMealId,
                                        items: meals
                                            .map(
                                              (e) => DropdownMenuItem<int>(
                                                value: e.id,
                                                child: Text(
                                                  '${e.title} (${(e.basePrice / 100).toStringAsFixed(2)} €)',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) => setState(() {
                                          if (value != null &&
                                              value != _selectedMealId) {
                                            _selectedMealId = value;
                                            _options = [];
                                          }
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              mealInputs?.isNotEmpty ?? false
                                  ? '2. Select your desired options and enter additional remarks'
                                  : '2. Enter additional remarks',
                            ),
                            Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (mealInputs?.isNotEmpty ?? false)
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              if (_selectedMealId == null)
                                                Text(
                                                    'Select a meal to proceed'),
                                              if (_selectedMealId != null)
                                                for (final input
                                                    in mealInputs ??
                                                        <MealInputDto>[])
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (input.isExclusion)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                          child: Icon(
                                                            Icons.block,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      Expanded(
                                                        child: switch (input
                                                            .multipleChoice) {
                                                          true => Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: [
                                                                Text(input
                                                                    .description),
                                                                MultipleChoiceInput(
                                                                  values: ([
                                                                    ...input
                                                                        .mealInputOptions
                                                                  ]..sort(
                                                                          (a, b) => a
                                                                              .description
                                                                              .toLowerCase()
                                                                              .compareTo(b.description.toLowerCase()),
                                                                        ))
                                                                      .map(
                                                                        (e) =>
                                                                            MultipleChoiceOption(
                                                                          key: e
                                                                              .id,
                                                                          value:
                                                                              e.labelWithPrice,
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                                  selectedValues:
                                                                      _options,
                                                                  select: (key) =>
                                                                      setState(
                                                                          () {
                                                                    _options.add(
                                                                        key);
                                                                  }),
                                                                  deselect: (key) =>
                                                                      setState(
                                                                          () {
                                                                    _options
                                                                        .remove(
                                                                            key);
                                                                  }),
                                                                ),
                                                              ],
                                                            ),
                                                          false =>
                                                            DropdownButton<int>(
                                                              hint: Text(input
                                                                  .description),
                                                              value: _options
                                                                          .where(
                                                                            (selected) => input.mealInputOptions.any((option) =>
                                                                                option.id ==
                                                                                selected),
                                                                          )
                                                                          .length >
                                                                      1
                                                                  ? null
                                                                  : _options
                                                                      .where(
                                                                        (selected) => input.mealInputOptions.any((option) =>
                                                                            option.id ==
                                                                            selected),
                                                                      )
                                                                      .firstOrNull,
                                                              items:
                                                                  ([
                                                                ...input
                                                                    .mealInputOptions
                                                              ]..sort(
                                                                          (a, b) => a
                                                                              .description
                                                                              .toLowerCase()
                                                                              .compareTo(b.description.toLowerCase()),
                                                                        ))
                                                                      .map(
                                                                        (e) => DropdownMenuItem<
                                                                            int>(
                                                                          value:
                                                                              e.id,
                                                                          child:
                                                                              Text(e.labelWithPrice),
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                              onChanged:
                                                                  (value) =>
                                                                      setState(
                                                                          () {
                                                                if (value !=
                                                                    null) {
                                                                  _options = [
                                                                    ..._options
                                                                        .where(
                                                                      (selected) => !input
                                                                          .mealInputOptions
                                                                          .any((option) =>
                                                                              option.id ==
                                                                              selected),
                                                                    ),
                                                                    value,
                                                                  ];
                                                                }
                                                              }),
                                                            ),
                                                        },
                                                      ),
                                                    ],
                                                  )
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (mealInputs?.isNotEmpty ?? false)
                                      SizedBox(height: 16),
                                    TextField(
                                      controller: _remarksController,
                                      decoration: const InputDecoration(
                                          hintText:
                                              'Additional remarks (optional)'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextButton(
                                    onPressed:
                                        orderState is EditOrderCubitLoaded &&
                                                orderState.order != null
                                            ? () => context
                                                    .read<EditOrderCubit>()
                                                    .deleteOrder()
                                                    .then((_) {
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                })
                                            : null,
                                    child: const Text('Delete order'),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextButton(
                                    onPressed: _selectedMealId != null
                                        ? () => context
                                                .read<EditOrderCubit>()
                                                .upsertOrder(
                                                  OrderDto(
                                                    mealId: _selectedMealId!,
                                                    remarks: _remarksController
                                                        .text
                                                        .trim(),
                                                    mealInputOptionIds:
                                                        _options,
                                                  ),
                                                )
                                                .then((_) {
                                              if (!context.mounted) return;
                                              Navigator.pop(context);
                                            })
                                        : null,
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                },
              ),
            ),
          ),
        ),
      );
}
