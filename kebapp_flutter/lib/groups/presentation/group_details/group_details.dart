import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/components/confirmation_dialog.dart';
import 'package:kebapp_flutter/groups/presentation/group_details/create_invite_dialog.dart';
import 'package:kebapp_flutter/models/session_info.dart';
import 'package:kebapp_flutter/orders/presentation/distinct_order_display.dart';
import 'package:kebapp_flutter/components/page_wrapper.dart';
import 'package:kebapp_flutter/groups/state/group_cubit.dart';
import 'package:kebapp_flutter/groups/state/group_details_cubit.dart';
import 'package:kebapp_flutter/groups/state/non_member_cubit.dart';
import 'package:kebapp_flutter/meals/state/meal_user_cubit.dart';
import 'package:kebapp_flutter/routes.dart';
import 'package:kebapp_flutter/users/state/session_info_cubit.dart';

class GroupDetails extends StatelessWidget {
  const GroupDetails({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GroupDetailsCubit(id),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => MealUserCubit(),
            lazy: false,
          ),
        ],
        child: Builder(
          // make provided cubits available
          builder: (context) => BlocBuilder<SessionInfoCubit, SessionInfo?>(
            builder: (context, sessionInfo) => PageWrapper(
              // TODO: show group title
              pageTitle: 'Group',
              onUsernameChanged: () {
                context.read<MealUserCubit>().reload();
                context.read<GroupCubit>().reload();
                context.read<GroupDetailsCubit>().load();
              },
              onRefresh: () async {
                context.read<MealUserCubit>().reload();
                context.read<GroupCubit>().reload();
                context.read<GroupDetailsCubit>().load();
              },
              builder: (context) =>
                  BlocBuilder<GroupDetailsCubit, GroupDetailsCubitState>(
                builder: (context, groupState) => Padding(
                  padding: EdgeInsetsGeometry.all(8.0),
                  child: switch (groupState) {
                    GroupDetailsCubitLoading() => Center(
                        child: CircularProgressIndicator(),
                      ),
                    GroupDetailsCubitNoPermission() => SizedBox.shrink(),
                    GroupDetailsCubitLoaded(group: final group) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: group.members.any(
                              (m) =>
                                  m.userId == sessionInfo?.userId &&
                                  !m.accepted,
                            )
                                ? _GroupDetailsInvite(
                                    sessionInfo: sessionInfo,
                                  )
                                : _GroupDetailsMember(
                                    sessionInfo: sessionInfo,
                                    group: group,
                                  ),
                          ),
                          if (sessionInfo?.canWrite ?? false)
                            OutlinedButton(
                              style: Theme.of(context)
                                  .outlinedButtonTheme
                                  .style
                                  ?.copyWith(
                                    foregroundColor: WidgetStatePropertyAll(
                                      Colors.red,
                                    ),
                                  ),
                              onPressed: () async {
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (context) => ConfirmationDialog(
                                    text: [
                                      'Do you really want to leave the group "${group.title}"?',
                                      if (group.members.length == 1)
                                        'You are the last member of the group. Leaving will delete the group and cancel all pending invites.'
                                    ].join('\n\n'),
                                    destructiveAction: true,
                                  ),
                                );
                                if (!confirmed) return;
                                if (!context.mounted) return;
                                await context
                                    .read<GroupDetailsCubit>()
                                    .leave()
                                    .then((_) {
                                  if (!context.mounted) return;
                                  context.pop();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  const Text('Leave Group'),
                                ],
                              ),
                            ),
                        ],
                      ),
                  },
                ),
              ),
            ),
          ),
        ),
      );
}

class _GroupDetailsInvite extends StatelessWidget {
  const _GroupDetailsInvite({
    required this.sessionInfo,
  });

  final SessionInfo? sessionInfo;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'You must join the group to see more details.',
                ),
              ),
            ),
          ),
          if (sessionInfo?.canWrite ?? false)
            TextButton(
              onPressed: context.read<GroupDetailsCubit>().acceptInvite,
              child: const Text('Accept Invite'),
            ),
          Spacer(),
        ],
      );
}

class _GroupDetailsMember extends StatelessWidget {
  const _GroupDetailsMember({
    required this.sessionInfo,
    required this.group,
  });

  final SessionInfo? sessionInfo;
  final GroupDto group;

  bool get _anyInvitePending => group.members.any((m) => !m.accepted);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => NonMemberCubit(group.id),
        lazy: false,
        child: BlocSelector<NonMemberCubit, NonMemberCubitState, bool>(
            selector: (state) => switch (state) {
                  NonMemberCubitStateLoaded(users: final nonMembers) =>
                    nonMembers.isNotEmpty,
                  _ => false,
                },
            builder: (context, doesAnyNonMemberExist) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (sessionInfo?.canWrite ?? false)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      EditOrderRoute(groupId: group.id)
                                          .push(context)
                                          .then((_) {
                                    if (!context.mounted) return;
                                    context.read<GroupDetailsCubit>().load();
                                  }),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.fastfood_outlined),
                                      SizedBox(width: 8),
                                      const Text('Edit order'),
                                    ],
                                  ),
                                ),
                              ),
                            if (sessionInfo?.canRead ?? false)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: DistinctOrderDisplay(group: group),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (sessionInfo?.canWrite ?? false)
                          Expanded(
                            child: TextButton(
                              onPressed: doesAnyNonMemberExist
                                  ? () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            CreateInviteDialog(
                                          groupId: group.id,
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      context.read<GroupDetailsCubit>().load();
                                      context.read<NonMemberCubit>().reload();
                                    }
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add),
                                  SizedBox(width: 8),
                                  const Text('Invite'),
                                ],
                              ),
                            ),
                          ),
                        if ((sessionInfo?.canWrite ?? false) &&
                            _anyInvitePending)
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (context) => ConfirmationDialog(
                                    text:
                                        'Do you really want to cancel all pending invites?',
                                    destructiveAction: true,
                                  ),
                                );
                                if (!confirmed) return;
                                if (!context.mounted) return;
                                await context
                                    .read<GroupDetailsCubit>()
                                    .cancelInvites();
                                if (!context.mounted) return;
                                context.read<NonMemberCubit>().reload();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_outlined),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: const Text(
                                      'Cancel Pending Invites',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (sessionInfo?.canWrite ?? false)
                          Expanded(
                            child: TextButton(
                              onPressed: () => GroupEditRoute(groupId: group.id)
                                  .push(context)
                                  .then((_) {
                                if (!context.mounted) return;
                                context.read<GroupDetailsCubit>().load();
                              }),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  const Text('Edit Group'),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                )),
      );
}
