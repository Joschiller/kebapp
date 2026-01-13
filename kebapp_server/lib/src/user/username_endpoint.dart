import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user_info_endpoint.dart';
import 'package:serverpod/server.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

class UsernameEndpoint extends UserInfoEndpoint {
  @override
  bool get requireLogin => true;

  Future<void> updateUsername(
    Session session,
    String newUserName,
  ) async {
    final currentUser = await getUserInfo(session);
    final userId = currentUser.id;
    if (userId == null) {
      throw ForbiddenException();
    }

    await auth.Users.changeUserName(session, userId, newUserName);
  }
}
