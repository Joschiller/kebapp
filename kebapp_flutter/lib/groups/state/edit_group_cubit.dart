import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class EditGroupCubitState {}

class EditGroupCubitLoading extends EditGroupCubitState {}

class EditGroupCubitNoPermission extends EditGroupCubitState {}

class EditGroupCubitLoaded extends EditGroupCubitState {
  final GroupDto group;

  EditGroupCubitLoaded({required this.group});
}

class EditGroupCubit extends Cubit<EditGroupCubitState> {
  EditGroupCubit(this.id) : super(EditGroupCubitLoading()) {
    load();
  }

  final int? id;

  Future<void> load() async {
    try {
      final group =
          id != null ? await client.groupRead.getByGroupId(id!) : null;

      emit(
        EditGroupCubitLoaded(
          group: group ??
              GroupDto(
                id: -1,
                title: '',
                timeOfDay: 12 * 60,
                location: '',
                members: [],
              ),
        ),
      );
    } catch (e) {
      emit(EditGroupCubitNoPermission());
    }
  }

  Future<void> upsertGroup(GroupDto group) async {
    try {
      await client.groupWrite.upsert(group).then((_) => load());
    } catch (e) {
      // ignore
    }
  }
}
