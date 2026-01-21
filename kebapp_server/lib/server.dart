import 'package:kebapp_server/src/initial_user_setup.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'package:kebapp_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  auth.AuthConfig.set(auth.AuthConfig(
    sendValidationEmail: (session, email, validationCode) async {
      // TODO: integrate with mail server
      return true;
    },
    sendPasswordResetEmail: (session, userInfo, validationCode) async {
      // TODO: integrate with mail server
      return true;
    },
    onUserCreated: (session, userInfo) async {
      // Assign default roles to new users.
      // NOTE: This is only viable as long as users do not receive email codes. Currently users must receive a code from an admin - that way, the admin still has full control over the users that receive acccess to the application.
      // TODO: integrate with mail server - Once the email integration is done, this callback should be removed!

      try {
        await auth.Users.updateUserScopes(
          session,
          userInfo.id!,
          {CustomScope.userRead, CustomScope.userWrite},
        );
        print('User ${userInfo.userName} received default roles.');
      } catch (e) {
        print('User ${userInfo.userName} did not receive default roles.');
      }
    },
  ));

  // Start the server.
  await pod.start();

  // After starting the server, you can register future calls. Future calls are
  // tasks that need to happen in the future, or independently of the request/
  // response cycle. For example, you can use future calls to send emails, or to
  // schedule tasks to be executed at a later time. Future calls are executed in
  // the background. Their schedule is persisted to the database, so you will
  // not lose them if the server is restarted.

  pod.registerFutureCall(
    InitialUserSetup(),
    FutureCallNames.initialUserSetup.name,
  );

  // You can schedule future calls for a later time during startup. But you can
  // also schedule them in any endpoint or webroute through the session object.
  // there is also [futureCallAtTime] if you want to schedule a future call at a
  // specific time.
  await pod.futureCallWithDelay(
    FutureCallNames.initialUserSetup.name,
    null,
    Duration.zero,
  );
}

/// Names of all future calls in the server.
///
/// This is better than using a string literal, as it will reduce the risk of
/// typos and make it easier to refactor the code.
enum FutureCallNames { initialUserSetup }
