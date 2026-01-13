import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_flutter/groups/state/non_member_cubit.dart';

class CreateInviteDialog extends StatelessWidget {
  const CreateInviteDialog({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => NonMemberCubit(groupId),
        lazy: false,
        child: BlocBuilder<NonMemberCubit, NonMemberCubitState>(
            builder: (context, nonMemberState) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Select the user you want to invite'),
                        Expanded(
                          child: switch (nonMemberState) {
                            NonMemberCubitStateLoading() => Center(
                                child: CircularProgressIndicator(),
                              ),
                            NonMemberCubitStateNoPermission() =>
                              SizedBox.shrink(),
                            NonMemberCubitStateLoaded(
                              users: final nonMembers
                            ) =>
                              ListView.separated(
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () {
                                    context.read<NonMemberCubit>().createInvite(
                                        userId: nonMembers[index].userId);
                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(nonMembers[index].userName),
                                    ),
                                  ),
                                ),
                                itemCount: nonMembers.length,
                              ),
                          },
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                )),
      );
}
