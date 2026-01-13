import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/users/presentation/admin_user_list_element.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';
import 'package:kebapp_flutter/users/state/user_admin_cubit.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({super.key});

  @override
  State<AdminUserList> createState() => AdminUserListState();
}

class AdminUserListState extends State<AdminUserList> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<UserAdminCubit, UserAdminCubitState>(
        builder: (context, userState) => switch (userState) {
          UserAdminCubitStateLoading() => Center(
              child: CircularProgressIndicator(),
            ),
          UserAdminCubitStateNoPermission() => SizedBox.shrink(),
          UserAdminCubitStateLoaded(users: final users) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Spacer(),
                            IconButton(
                              onPressed: context.read<UserAdminCubit>().reload,
                              icon: Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        BlocBuilder<SessionInfoCubit, SessionInfo?>(
                          builder: (context, sessionInfo) =>
                              ExpansionPanelList.radio(
                            children: users
                                .map(
                                  (e) => ExpansionPanelRadio(
                                    value: e.userId,
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(title: Text(e.userName)),
                                    body: AdminUserListElement(
                                      user: e,
                                      isCurrentUser:
                                          e.userId == sessionInfo?.userId,
                                    ),
                                    canTapOnHeader: true,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        },
      );
}
