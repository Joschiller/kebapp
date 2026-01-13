import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

class UserInfoEndpoint extends Endpoint {
  @doNotGenerate
  Future<UserInfo> getUserInfo(Session session) async {
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      throw UnauthorizedException();
    }
    final user = await UserInfo.db.findById(session, userId);
    if (user == null) {
      throw UnauthorizedException();
    }
    return user;
  }
}
