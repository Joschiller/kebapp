import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class GroupCubitState {}

class GroupCubitStateLoading extends GroupCubitState {}

class GroupCubitStateNoPermission extends GroupCubitState {}

class GroupCubitStateLoaded extends GroupCubitState {
  final List<GroupDto> groups;

  GroupCubitStateLoaded({required this.groups});
}

class GroupCubit extends Cubit<GroupCubitState> {
  GroupCubit() : super(GroupCubitStateLoading()) {
    reload();
  }

  Future<void> reload() async {
    try {
      final groups = await client.groupRead.getAll();
      emit(
        GroupCubitStateLoaded(
          groups: groups,
        ),
      );
    } catch (e) {
      emit(GroupCubitStateNoPermission());
    }
  }
}
