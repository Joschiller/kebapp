import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/components/confirmation_dialog.dart';
import 'package:kebapp_flutter/users/state/user_admin_cubit.dart';

class AdminUserListElement extends StatelessWidget {
  const AdminUserListElement({
    super.key,
    required this.user,
    required this.isCurrentUser,
  });

  final CustomUserInfo user;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user.verificationCode != null)
            Row(
              children: [
                SizedBox(width: 8),
                Text(
                  user.verificationCode ?? '',
                  style: GoogleFonts.inconsolata(
                    color: Colors.grey.shade500,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          Row(
            children: [
              SizedBox(width: 8),
              Text(user.email),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: user.scopes.contains('userRead'),
                onChanged: isCurrentUser
                    ? null
                    : (value) =>
                        context.read<UserAdminCubit>().updateReadScopeByUserId(
                              value ?? false,
                              user.userId,
                            ),
              ),
              SizedBox(width: 8),
              Text('Read Data'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: user.scopes.contains('userWrite'),
                onChanged: isCurrentUser
                    ? null
                    : (value) =>
                        context.read<UserAdminCubit>().updateWriteScopeByUserId(
                              value ?? false,
                              user.userId,
                            ),
              ),
              SizedBox(width: 8),
              Text('Write Data'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: user.scopes.contains('userWrite.userName'),
                onChanged: isCurrentUser
                    ? null
                    : (value) => context
                        .read<UserAdminCubit>()
                        .updateWriteUserNameScopeByUserId(
                          value ?? false,
                          user.userId,
                        ),
              ),
              SizedBox(width: 8),
              Text('Change Username'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: user.scopes.contains('serverpod.admin'),
                onChanged: isCurrentUser
                    ? null
                    : (value) async {
                        final cubit = context.read<UserAdminCubit>();
                        if (value ?? false) {
                          final confirmed = await showDialog(
                            context: context,
                            builder: (context) => ConfirmationDialog(
                              text:
                                  'Do you really want to make "${user.userName}" an admin?',
                              destructiveAction: true,
                            ),
                          );
                          if (!confirmed) return;
                        }
                        await cubit.updateAdminScopeByUserId(
                          value ?? false,
                          user.userId,
                        );
                      },
              ),
              SizedBox(width: 8),
              Text('Admin'),
            ],
          ),
        ],
      );
}
