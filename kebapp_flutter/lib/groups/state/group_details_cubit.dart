import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class GroupDetailsCubitState {}

class GroupDetailsCubitLoading extends GroupDetailsCubitState {}

class GroupDetailsCubitNoPermission extends GroupDetailsCubitState {}

class GroupDetailsCubitLoaded extends GroupDetailsCubitState {
  final GroupDto group;

  GroupDetailsCubitLoaded({required this.group});
}

class GroupDetailsCubit extends Cubit<GroupDetailsCubitState> {
  GroupDetailsCubit(this.id) : super(GroupDetailsCubitLoading()) {
    load();
  }

  final int id;

  Future<void> load() async {
    try {
      final group = await client.groupRead.getByGroupId(id);

      emit(
        GroupDetailsCubitLoaded(
          group: group ??
              GroupDto(
                id: id,
                title: '',
                timeOfDay: 12 * 60,
                location: '',
                members: [],
              ),
        ),
      );
    } catch (e) {
      emit(GroupDetailsCubitNoPermission());
    }
  }

  Future<void> acceptInvite() async {
    try {
      await client.groupWrite.acceptInvite(id).then((_) => load());
    } catch (e) {
      // ignore
    }
  }

  Future<void> leave() async {
    try {
      await client.groupWrite.leave(id).then((_) => load());
    } catch (e) {
      // ignore
    }
  }

  Future<void> cancelInvites() async {
    try {
      await client.groupWrite.cancelInvites(id).then((_) => load());
    } catch (e) {
      // ignore
    }
  }
}
