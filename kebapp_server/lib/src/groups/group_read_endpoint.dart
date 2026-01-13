import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/groups/group_endpoint.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:serverpod/serverpod.dart' hide Order;
import 'package:serverpod_auth_server/module.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

class GroupReadEndpoint extends GroupEndpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {CustomScope.userRead};

  /// Retrieves all groups that the current user was invited to or is a member of.
  Future<List<GroupDto>> getAll(Session session) async {
    final user = await getUserInfo(session);

    final groups = await Group.db.find(
      session,
      include: Group.include(
        members: Member.includeList(
          include: Member.include(
            order: Order.include(
              options: OrderOption.includeList(),
            ),
          ),
        ),
      ),
    );

    final usernamesByUserId = {
      for (final user in await UserInfo.db.find(session))
        user.id: user.userName,
    };

    return groups
        // only forward the groups that the current user at least owns an invitation for
        .where((e) => e.members?.any((m) => m.userId == user.id) ?? false)
        .map(
          (group) {
            final id = group.id;
            return id == null
                ? null
                : GroupDto(
                    id: id,
                    title: group.title,
                    timeOfDay: group.timeOfDay,
                    location: group.location,
                    members: group.members
                            ?.map(
                              (e) => MemberDto(
                                userId: e.userId,
                                userName: usernamesByUserId[e.userId] ?? '',
                                accepted: e.accepted,
                                order: e.order == null
                                    ? null
                                    : OrderDto(
                                        mealId: e.order!.mealId,
                                        remarks: e.order!.remarks,
                                        mealInputOptionIds: e.order!.options
                                                ?.map(
                                                  (e) => e.mealInputOptionId,
                                                )
                                                .toList() ??
                                            [],
                                      ),
                              ),
                            )
                            .toList() ??
                        [],
                  );
          },
        )
        .nonNulls
        .toList();
  }

  /// Retrieves a group.
  Future<GroupDto?> getByGroupId(Session session, int groupId) async {
    await validateInvite(session, groupId);

    final group = await Group.db.findById(
      session,
      groupId,
      include: Group.include(
        members: Member.includeList(
          include: Member.include(
            order: Order.include(
              options: OrderOption.includeList(),
            ),
          ),
        ),
      ),
    );
    if (group == null) {
      return null;
    }

    final usernamesByUserId = {
      for (final user in await UserInfo.db.find(session))
        user.id: user.userName,
    };

    return GroupDto(
      id: groupId,
      title: group.title,
      timeOfDay: group.timeOfDay,
      location: group.location,
      members: group.members
              ?.map(
                (e) => MemberDto(
                  userId: e.userId,
                  userName: usernamesByUserId[e.userId] ?? '',
                  accepted: e.accepted,
                  order: e.order == null
                      ? null
                      : OrderDto(
                          mealId: e.order!.mealId,
                          remarks: e.order!.remarks,
                          mealInputOptionIds: e.order!.options
                                  ?.map(
                                    (e) => e.mealInputOptionId,
                                  )
                                  .toList() ??
                              [],
                        ),
                ),
              )
              .toList() ??
          [],
    );
  }

  Future<List<GroupUserInfoDto>> getNonMembersByGroupId(
    Session session,
    int groupId,
  ) async {
    await validateMembership(session, groupId);

    final group = await Group.db.findById(
      session,
      groupId,
      include: Group.include(
        members: Member.includeList(
          include: Member.include(),
        ),
      ),
    );
    if (group == null) {
      throw ForbiddenException();
    }

    final memberUserIds = group.members?.map((m) => m.userId) ?? [];

    final users = await auth.UserInfo.db.find(session);
    return users
        .where((user) => !memberUserIds.contains(user.id))
        .map(
          (user) => GroupUserInfoDto(
            userId: user.id!,
            userName: user.userName!,
          ),
        )
        .toList();
  }

  /// Retrieves the order of the current user of a group.
  Future<OrderDto?> getOrderByGroupId(
    Session session,
    int groupId,
  ) async {
    await validateMembership(session, groupId);

    final user = await getUserInfo(session);
    final member = (await Member.db.find(
      session,
      where: (p0) => p0.groupId.equals(groupId) & p0.userId.equals(user.id),
    ))
        .firstOrNull;
    if (member == null) {
      throw ForbiddenException();
    }

    final existingOrder = (await Order.db.find(
      session,
      include: Order.include(options: OrderOption.includeList()),
      where: (p0) => p0.memberId.equals(member.id),
    ))
        .firstOrNull;

    return existingOrder != null
        ? OrderDto(
            mealId: existingOrder.mealId,
            remarks: existingOrder.remarks,
            mealInputOptionIds: existingOrder.options
                    ?.map((o) => o.mealInputOptionId)
                    .toList() ??
                [],
          )
        : null;
  }
}
