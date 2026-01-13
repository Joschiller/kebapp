import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class NonMemberCubitState {}

class NonMemberCubitStateLoading extends NonMemberCubitState {}

class NonMemberCubitStateNoPermission extends NonMemberCubitState {}

class NonMemberCubitStateLoaded extends NonMemberCubitState {
  final List<GroupUserInfoDto> users;

  NonMemberCubitStateLoaded({required this.users});
}

class NonMemberCubit extends Cubit<NonMemberCubitState> {
  NonMemberCubit(this.groupId) : super(NonMemberCubitStateLoading()) {
    reload();
  }

  final int groupId;

  Future<void> reload() async {
    try {
      final users = await client.groupRead.getNonMembersByGroupId(groupId);
      emit(
        NonMemberCubitStateLoaded(
          users: users,
        ),
      );
    } catch (e) {
      emit(NonMemberCubitStateNoPermission());
    }
  }

  Future<void> createInvite({
    required int userId,
  }) async {
    try {
      await client.groupWrite.createInvite(
        groupId,
        userId,
      );
    } catch (e) {
      // ignore
    }
  }
}
