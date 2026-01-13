import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kebapp_flutter/overview_pages/admin_overview.dart';
import 'package:kebapp_flutter/meals/presentation/meal_input/meal_input.dart';
import 'package:kebapp_flutter/groups/presentation/group_details/group_details.dart';
import 'package:kebapp_flutter/groups/presentation/group_details/group_metadata_input.dart';
import 'package:kebapp_flutter/overview_pages/group_overview.dart';
import 'package:kebapp_flutter/orders/presentation/order_input/order_input.dart';

part 'routes.g.dart';

@TypedGoRoute<GroupOverviewRoute>(
  path: '/',
  routes: [
    TypedGoRoute<AdminOverviewRoute>(
      path: 'adminOverview',
    ),
    TypedGoRoute<AddMealRoute>(
      path: 'adminOverview/meal',
    ),
    TypedGoRoute<EditMealRoute>(
      path: 'adminOverview/meal/:mealId',
    ),
    TypedGoRoute<GroupCreateRoute>(
      path: 'group/create',
    ),
    TypedGoRoute<GroupDetailsRoute>(
      path: 'group/details/:groupId',
    ),
    TypedGoRoute<GroupEditRoute>(
      path: 'group/details/:groupId/edit',
    ),
    TypedGoRoute<EditOrderRoute>(
      path: 'group/details/:groupId/order',
    ),
  ],
)
@immutable
class GroupOverviewRoute extends GoRouteData with $GroupOverviewRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GroupOverview();
  }
}

@immutable
class AdminOverviewRoute extends GoRouteData with $AdminOverviewRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AdminOverview();
  }
}

@immutable
class AddMealRoute extends GoRouteData with $AddMealRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MealInput(
      mealId: null,
    );
  }
}

@immutable
class EditMealRoute extends GoRouteData with $EditMealRoute {
  const EditMealRoute({required this.mealId});

  final int mealId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MealInput(
      mealId: mealId,
    );
  }
}

@immutable
class GroupCreateRoute extends GoRouteData with $GroupCreateRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GroupMetadataInput(
      id: null,
    );
  }
}

@immutable
class GroupDetailsRoute extends GoRouteData with $GroupDetailsRoute {
  final int groupId;

  const GroupDetailsRoute({required this.groupId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GroupDetails(
      id: groupId,
    );
  }
}

@immutable
class GroupEditRoute extends GoRouteData with $GroupEditRoute {
  final int groupId;

  const GroupEditRoute({required this.groupId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GroupMetadataInput(
      id: groupId,
    );
  }
}

@immutable
class EditOrderRoute extends GoRouteData with $EditOrderRoute {
  final int groupId;

  const EditOrderRoute({required this.groupId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrderInput(
      groupId: groupId,
    );
  }
}
