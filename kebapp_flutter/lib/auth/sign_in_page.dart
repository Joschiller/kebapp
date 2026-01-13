import 'package:flutter/material.dart';
import 'package:kebapp_flutter/main.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Dialog(
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SignInWithEmailButton(
                  caller: client.modules.auth,
                  initPage: InitPage.signIn,
                ),
              ],
            ),
          ),
        ),
      );
}
