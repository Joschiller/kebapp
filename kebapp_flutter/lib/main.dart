import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:flutter/material.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/routes.dart';
import 'package:kebapp_flutter/theme.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;
late SessionManager _sessionManager;

late String serverUrl;

final router = GoRouter(routes: $appRoutes);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`
  const serverDomainFromEnv = String.fromEnvironment('SERVER_DOMAIN');
  const serverPortFromEnv = String.fromEnvironment('SERVER_PORT');
  final serverUrl = serverDomainFromEnv.isEmpty || serverPortFromEnv.isEmpty
      ? 'http://$localhost:8080/'
      : 'https://$serverDomainFromEnv:$serverPortFromEnv/';

  client = Client(
    serverUrl,
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  _sessionManager = SessionManager(
    caller: client.modules.auth,
  );

  await _sessionManager.initialize();

  runApp(
    BlocProvider(
      create: (context) => SessionInfoCubit(
        doSignout: _sessionManager.signOutDevice,
        doRefresh: _sessionManager.refreshSession,
      ),
      child: _SessionWrapper(
        child: MaterialApp.router(
          title: 'KebApp',
          theme: theme,
          routerConfig: router,
        ),
      ),
    ),
  );
}

class _SessionWrapper extends StatefulWidget {
  const _SessionWrapper({required this.child});

  final Widget child;

  @override
  State<_SessionWrapper> createState() => __SessionWrapperState();
}

class __SessionWrapperState extends State<_SessionWrapper> {
  void updateSessionInfo() {
    final user = _sessionManager.signedInUser;
    context.read<SessionInfoCubit>().update(
          user != null
              ? SessionInfo(
                  userId: user.id,
                  userName: user.userName,
                  canRead: user.scopeNames.contains('userRead'),
                  canWrite: user.scopeNames.contains('userWrite'),
                  canWriteUserName:
                      user.scopeNames.contains('userWrite.userName'),
                  isAdmin: user.scopeNames.contains('serverpod.admin'),
                  canConfigureMeals: user.scopeNames.contains('admin.meals'),
                  canConfigureRights: user.scopeNames.contains('admin.rights'),
                  canViewPendingVerifications:
                      user.scopeNames.contains('admin.verificationCodes'),
                )
              : null,
        );
  }

  @override
  void initState() {
    super.initState();
    _sessionManager.addListener(updateSessionInfo);
    updateSessionInfo();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
