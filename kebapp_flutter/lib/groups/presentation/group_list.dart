import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/groups/presentation/group_list_element.dart';
import 'package:kebapp_flutter/groups/state/group_cubit.dart';
import 'package:kebapp_flutter/routes.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().reload();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<GroupCubit, GroupCubitState>(
        builder: (context, groupState) => switch (groupState) {
          GroupCubitStateLoading() => Center(
              child: CircularProgressIndicator(),
            ),
          GroupCubitStateNoPermission() => SizedBox.shrink(),
          GroupCubitStateLoaded(groups: final groups) => ListView.separated(
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => GroupDetailsRoute(groupId: groups[index].id)
                    .push(context)
                    .then((value) {
                  if (!context.mounted) return;
                  context.read<GroupCubit>().reload();
                }),
                child: GroupListElement(
                  group: groups[index],
                ),
              ),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: groups.length,
            ),
        },
      );
}
