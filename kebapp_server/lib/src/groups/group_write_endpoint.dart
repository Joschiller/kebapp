import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/groups/group_endpoint.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:serverpod/serverpod.dart' hide Order;

class GroupWriteEndpoint extends GroupEndpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {CustomScope.userWrite};

  /// Updates a groups metadata.
  Future<void> upsert(Session session, GroupDto group) async {
    final user = await getUserInfo(session);
    final existingGroup = await Group.db.findById(
      session,
      group.id,
    );
    session.log('new: $group');
    session.log('existing: $existingGroup');
    if (existingGroup != null) {
      await Group.db.updateRow(
        session,
        Group(
          id: group.id,
          title: group.title,
          timeOfDay: group.timeOfDay,
          location: group.location,
        ),
      );
    } else {
      final insertedGroup = await Group.db.insertRow(
        session,
        Group(
          title: group.title,
          timeOfDay: group.timeOfDay,
          location: group.location,
        ),
      );
      await Member.db.insertRow(
        session,
        Member(
          groupId: insertedGroup.id!,
          userId: user.id!,
          accepted: true,
        ),
      );
    }
  }

  /// Creates an invite.
  Future<void> createInvite(Session session, int groupId, int userId) async {
    final group = await validateMembership(session, groupId);

    if ((group.members ?? []).any((m) => m.userId == userId)) {
      // is already a member
      return;
    }

    await Member.db.insertRow(
      session,
      Member(
        groupId: groupId,
        userId: userId,
        accepted: false,
      ),
    );
  }

  /// Deletes all invites for a group.
  Future<void> cancelInvites(Session session, int groupId) async {
    await validateMembership(session, groupId);

    await Member.db.deleteWhere(
      session,
      where: (p0) => p0.groupId.equals(groupId) & p0.accepted.equals(false),
    );
  }

  /// Accepts an invite.
  Future<void> acceptInvite(Session session, int groupId) async {
    await validateInvite(session, groupId);

    final user = await getUserInfo(session);

    final existingInvite = (await Member.db.find(
      session,
      where: (p0) => p0.groupId.equals(groupId) & p0.userId.equals(user.id),
    ))
        .firstOrNull;
    if (existingInvite == null) {
      throw ForbiddenException();
    }

    await Member.db.updateRow(
      session,
      Member(
        id: existingInvite.id,
        groupId: groupId,
        userId: user.id!,
        accepted: true,
      ),
    );
  }

  /// Removes a membership.
  Future<void> leave(Session session, int groupId) async {
    await validateInvite(session, groupId);

    final user = await getUserInfo(session);

    await Member.db.deleteWhere(
      session,
      where: (p0) => p0.groupId.equals(groupId) & p0.userId.equals(user.id),
    );

    // delete all groups without active members
    await Group.db.deleteWhere(
      session,
      where: (p0) => p0.members.none(
        (p0) => p0.accepted.equals(true),
      ),
    );
  }

  /// Updates an order for a group.
  Future<void> upsertOrder(Session session, int groupId, OrderDto order) async {
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
      where: (p0) => p0.memberId.equals(member.id),
    ));
    session.log('Existing order: $existingOrder');
    await Order.db.delete(session, existingOrder);
    final insertedOrder = await Order.db.insertRow(
      session,
      Order(
        memberId: member.id!,
        mealId: order.mealId,
        remarks: order.remarks,
      ),
    );
    for (final option in order.mealInputOptionIds) {
      await OrderOption.db.insertRow(
        session,
        OrderOption(
          orderId: insertedOrder.id!,
          mealInputOptionId: option,
        ),
      );
    }
  }

  /// Resets an order for a group.
  Future<void> deleteOrder(Session session, int groupId) async {
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

    await Order.db.deleteWhere(
      session,
      where: (p0) => p0.memberId.equals(member.id),
    );
  }
}
