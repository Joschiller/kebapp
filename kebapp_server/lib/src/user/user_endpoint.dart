import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:kebapp_server/src/user_info_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

class UserEndpoint extends UserInfoEndpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<List<CustomUserInfo>> getAllUsers(Session session) async {
    final users = await auth.UserInfo.db.find(session);
    final verifications = await auth.EmailCreateAccountRequest.db.find(session);
    final resets = await auth.EmailReset.db.find(session);
    return [
      // Existing users
      ...users.map(
        (user) => CustomUserInfo(
          userId: user.id!,
          userName: user.userName!,
          email: user.email!,
          verificationCode: resets
              .where((r) => r.userId == user.id)
              .firstOrNull
              ?.verificationCode,
          scopes: user.scopeNames,
        ),
      ),
      // New users
      ...verifications.map(
        (verification) => CustomUserInfo(
          userId: -verification.id!,
          userName: verification.userName,
          email: verification.email,
          verificationCode: verification.verificationCode,
          scopes: [],
        ),
      ),
    ];
  }

  Future<void> updateReadScopeByUserId(
    Session session,
    bool setScope,
    int userId,
  ) async {
    await _updateScopeByUserId(
      session,
      setScope,
      CustomScope.userRead,
      userId,
    );
  }

  Future<void> updateWriteScopeByUserId(
    Session session,
    bool setScope,
    int userId,
  ) async {
    await _updateScopeByUserId(
      session,
      setScope,
      CustomScope.userWrite,
      userId,
    );
  }

  Future<void> updateWriteUserNameScopeByUserId(
    Session session,
    bool setScope,
    int userId,
  ) async {
    await _updateScopeByUserId(
      session,
      setScope,
      CustomScope.userWriteUserName,
      userId,
    );
  }

  Future<void> updateAdminScopeByUserId(
    Session session,
    bool setScope,
    int userId,
  ) async {
    await _updateScopeByUserId(session, setScope, Scope.admin, userId);
  }

  Future<void> _updateScopeByUserId(
    Session session,
    bool setScope,
    Scope scope,
    int userId,
  ) async {
    final currentUser = await getUserInfo(session);
    if (currentUser.id == userId) {
      throw ForbiddenException();
    }

    final userToEdit = (await auth.UserInfo.db.find(
      session,
      where: (p0) => p0.id.equals(userId),
    ))
        .firstOrNull;
    if (userToEdit == null) {
      throw ForbiddenException();
    }

    await auth.Users.updateUserScopes(session, userId, {
      // remove scope
      ...userToEdit.scopes.where((s) => s != scope),
      // set scope if requested
      if (setScope) scope,
    });
  }

  Future<void> updateUsernamebyUserId(
    Session session,
    String newUserName,
    int userId,
  ) async {
    final currentUser = await getUserInfo(session);
    if (currentUser.id == userId) {
      // Changing the username of the same user is only allowed via the [UsernameEndpoint].
      throw ForbiddenException();
    }

    final userToEdit = (await auth.UserInfo.db.find(
      session,
      where: (p0) => p0.id.equals(userId),
    ))
        .firstOrNull;
    if (userToEdit == null) {
      throw ForbiddenException();
    }

    await auth.Users.changeUserName(session, userId, newUserName);
  }
}
