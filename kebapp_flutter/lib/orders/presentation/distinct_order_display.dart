import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/orders/presentation/order_display_element.dart';
import 'package:kebapp_flutter/meals/state/meal_user_cubit.dart';
import 'package:kebapp_flutter/models/meal_input_dto_overall_price.dart';
import 'package:kebapp_flutter/models/order_display_information.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class DistinctOrderDisplay extends StatefulWidget {
  DistinctOrderDisplay({super.key, required GroupDto group})
      : members = [...group.members]..sort((a, b) =>
            a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));

  final List<MemberDto> members;

  @override
  State<DistinctOrderDisplay> createState() => DistinctOrderDisplayState();
}

class DistinctOrderDisplayState extends State<DistinctOrderDisplay> {
  final _includeUsers = <({int id, String name})>{};
  final _selectController = MultiSelectController<({int id, String name})>();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initControllers();
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  void _initControllers() {
    setState(() {
      if (_includeUsers.isEmpty) {
        _includeUsers.addAll(
          widget.members.map(
            (e) => (
              id: e.userId,
              name: e.userName,
            ),
          ),
        );
      }
    });
    Future.delayed(
      Duration(milliseconds: 100),
      () => _selectController
          .selectWhere((item) => _includeUsers.contains(item.value)),
    );
  }

  var _distinct = true;

  @override
  Widget build(BuildContext context) {
    final selectedMembers = widget.members
        .where((e) => _includeUsers.any((u) => u.id == e.userId))
        .toList();
    final allOrders = selectedMembers
        .map((e) => e.order?.displayInformation)
        .nonNulls
        .toList();
    final distinctOrders = allOrders.toSet().toList();

    return BlocProvider(
      create: (context) => MealUserCubit(),
      lazy: false,
      child: BlocBuilder<MealUserCubit, MealUserCubitState>(
          builder: (context, mealState) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: switch (mealState) {
                    MealUserCubitStateLoading() => Center(
                        child: CircularProgressIndicator(),
                      ),
                    MealUserCubitStateNoPermission() => SizedBox.shrink(),
                    MealUserCubitStateLoaded(meals: final meals) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text('Include users:'),
                              SizedBox(width: 16),
                              Expanded(
                                child: MultiDropdown<({int id, String name})>(
                                  controller: _selectController,
                                  items: widget.members
                                      .map(
                                        (e) => DropdownItem(
                                          label: e.userName,
                                          value: (
                                            id: e.userId,
                                            name: e.userName
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onSelectionChange: (selectedItems) {
                                    setState(() {
                                      _includeUsers.clear();
                                      _includeUsers.addAll(selectedItems);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Sum: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(selectedMembers.map(
                                      (member) =>
                                          meals
                                              .where((element) =>
                                                  element.id ==
                                                  member.order?.mealId)
                                              .firstOrNull
                                              ?.getPriceWithSelection(member
                                                      .order
                                                      ?.mealInputOptionIds ??
                                                  []) ??
                                          0,
                                    ).fold(0, (a, b) => a + b) / 100).toStringAsFixed(2)} €',
                              ),
                              Spacer(),
                              if (distinctOrders.length < allOrders.length)
                                IconButton(
                                  onPressed: () => setState(() {
                                    _distinct = !_distinct;
                                  }),
                                  icon: Icon(_distinct
                                      ? Icons.expand
                                      : Icons.compress),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          meals.isEmpty
                              ? Text(
                                  'Loading ...',
                                )
                              : distinctOrders.length < allOrders.length &&
                                      _distinct
                                  ? _DistinctOrderList(
                                      meals: meals,
                                      selectedMembers: selectedMembers,
                                      distinctOrders: distinctOrders,
                                    )
                                  : distinctOrders.isEmpty
                                      ? Text(
                                          'No order was created yet.',
                                        )
                                      : selectedMembers.isEmpty
                                          ? Text(
                                              'No user was selected.',
                                            )
                                          : _FullOrderList(
                                              meals: meals,
                                              selectedUsernameWithOrder: [
                                                for (final member
                                                    in selectedMembers)
                                                  if (member.order != null)
                                                    (
                                                      userName: member.userName,
                                                      order: member.order!
                                                          .displayInformation,
                                                    )
                                              ],
                                            ),
                        ],
                      ),
                  },
                ),
              )),
    );
  }
}

class _DistinctOrderList extends StatelessWidget {
  const _DistinctOrderList({
    required this.meals,
    required this.selectedMembers,
    required this.distinctOrders,
  });

  final List<MealDto> meals;
  final List<MemberDto> selectedMembers;
  final List<OrderDisplayInformation> distinctOrders;

  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) => OrderDisplayElement(
          meal: meals.firstWhere(
              (element) => element.id == distinctOrders[index].mealId),
          order: distinctOrders[index],
          users: selectedMembers
              .where((member) =>
                  member.order?.displayInformation == distinctOrders[index])
              .map((e) => e.userName)
              .toList(),
        ),
        itemCount: distinctOrders.length,
      );
}

class _FullOrderList extends StatelessWidget {
  const _FullOrderList(
      {required this.meals, required this.selectedUsernameWithOrder});

  final List<MealDto> meals;
  final List<({String userName, OrderDisplayInformation order})>
      selectedUsernameWithOrder;

  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) => OrderDisplayElement(
          meal: meals.firstWhere((element) =>
              element.id == selectedUsernameWithOrder[index].order.mealId),
          order: selectedUsernameWithOrder[index].order,
          users: [selectedUsernameWithOrder[index].userName],
        ),
        itemCount: selectedUsernameWithOrder.length,
      );
}
