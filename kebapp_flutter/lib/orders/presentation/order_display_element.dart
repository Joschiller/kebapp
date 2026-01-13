import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/models/meal_input_dto_overall_price.dart';
import 'package:kebapp_flutter/models/order_display_information.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';

class OrderDisplayElement extends StatelessWidget {
  const OrderDisplayElement({
    super.key,
    required this.meal,
    required this.order,
    required this.users,
  });

  final MealDto meal;
  final OrderDisplayInformation order;
  final List<String> users;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<SessionInfoCubit, SessionInfo?>(
            builder: (context, sessionInfo) => Row(
              children: [
                Text(
                  '${users.length}x ${meal.title} (${(meal.getPriceWithSelection(order.mealInputOptionIds) / 100).toStringAsFixed(2)} €)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (users.contains(sessionInfo?.userName))
                  Card(
                    color: Colors.grey.shade500,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Your Order',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Text(
            users.join(', '),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          for (final input
              in meal.mealInputs
                ..sort((a, b) => a.description.compareTo(b.description)))
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  input.description,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      if (input.isExclusion)
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.block,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      WidgetSpan(
                        child: Text(
                          (input.mealInputOptions
                                  .where((availableOption) => order
                                      .mealInputOptionIds
                                      .contains(availableOption.id))
                                  .map((e) => e.description)
                                  .toList()
                                ..sort((a, b) => a.compareTo(b)))
                              .join(', ')
                              .orDefault('-'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (order.remarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(order.remarks),
            ),
        ],
      );
}

extension StringOrDefault on String {
  String orDefault(String defaultValue) => isEmpty ? defaultValue : this;
}
