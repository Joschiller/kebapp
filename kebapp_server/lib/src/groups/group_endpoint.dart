import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user_info_endpoint.dart';
import 'package:serverpod/serverpod.dart';

class GroupEndpoint extends UserInfoEndpoint {
  /// Checks, if the current user is an active member of the given group.
  @doNotGenerate
  Future<Group> validateMembership(Session session, int groupId) async {
    final user = await getUserInfo(session);

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

    if (!(group.members ?? []).any((m) => m.userId == user.id && m.accepted)) {
      throw ForbiddenException();
    }

    return group;
  }

  /// Checks, if the current user holds a pending invite of the given group OR already is an active member.
  @doNotGenerate
  Future<Group> validateInvite(Session session, int groupId) async {
    final user = await getUserInfo(session);

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

    if (!(group.members ?? []).any((m) => m.userId == user.id)) {
      throw ForbiddenException();
    }

    return group;
  }
}
