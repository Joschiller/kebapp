import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

class InitialUserSetup extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    session.log('Checking for existing users ...');

    final users = await auth.UserInfo.db.find(session);
    if (users.isEmpty) {
      session.log('No existing user. Creating initial user.');

      final initialUsername = session.serverpod.getPassword('initialUsername')!;
      final initialEmail = session.serverpod.getPassword('initialEmail')!;
      final initialPassword = session.serverpod.getPassword('initialPassword')!;

      final user = await auth.Emails.createUser(
        session,
        initialUsername,
        initialEmail,
        initialPassword,
      );

      if (user != null) {
        await auth.Users.updateUserScopes(session, user.id!, {Scope.admin});
      }
    } else {
      session.log('Initial user already exists.');
    }
  }
}
