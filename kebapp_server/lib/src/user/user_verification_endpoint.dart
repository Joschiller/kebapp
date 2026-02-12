import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:kebapp_server/src/user_info_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

class UserVerificationEndpoint extends UserInfoEndpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {
        Scope.admin,
        CustomScope.adminVerificationCodes,
      };

  Future<List<PendingVerification>> getAllPendingVerifications(
    Session session,
  ) async {
    final users = await auth.UserInfo.db.find(session);
    final verifications = await auth.EmailCreateAccountRequest.db.find(session);
    final resets = await auth.EmailReset.db.find(session);
    return [
      // Existing users
      ...users.map(
        (user) {
          final verificationCode = resets
              .where((r) => r.userId == user.id)
              .firstOrNull
              ?.verificationCode;
          return verificationCode == null
              ? null
              : PendingVerification(
                  userId: user.id!,
                  userName: user.userName!,
                  verificationCode: verificationCode,
                );
        },
      ).nonNulls,
      // New users
      ...verifications.map(
        (verification) => PendingVerification(
          userId: -verification.id!,
          userName: verification.userName,
          verificationCode: verification.verificationCode,
        ),
      ),
    ];
  }
}
