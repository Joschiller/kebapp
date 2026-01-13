import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/groups/presentation/group_list.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/groups/state/group_cubit.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/routes.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';

class GroupOverview extends StatelessWidget {
  const GroupOverview({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GroupCubit(),
            lazy: false,
          ),
        ],
        child: Builder(
          // make provided cubits available
          builder: (context) => BlocBuilder<SessionInfoCubit, SessionInfo?>(
            builder: (context, sessionInfo) => PageWrapper(
              pageTitle: 'Groups',
              onUsernameChanged: () {
                context.read<GroupCubit>().reload();
              },
              onRefresh: context.read<GroupCubit>().reload,
              floatingActionButton: sessionInfo?.canWrite ?? false
                  ? FloatingActionButton(
                      child: Icon(Icons.group_add),
                      onPressed: () =>
                          GroupCreateRoute().push(context).then((_) {
                        if (!context.mounted) return;
                        context.read<GroupCubit>().reload();
                      }),
                    )
                  : null,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!(sessionInfo?.isUnlocked ?? false))
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'The user must be unlocked by an administrator.',
                            ),
                          ),
                        ),
                      ),
                    if (sessionInfo?.canRead ?? false)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GroupList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
