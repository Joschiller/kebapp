import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class UserAdminCubitState {}

class UserAdminCubitStateLoading extends UserAdminCubitState {}

class UserAdminCubitStateNoPermission extends UserAdminCubitState {}

class UserAdminCubitStateLoaded extends UserAdminCubitState {
  final List<CustomUserInfo> users;

  UserAdminCubitStateLoaded({required this.users});
}

class UserAdminCubit extends Cubit<UserAdminCubitState> {
  UserAdminCubit() : super(UserAdminCubitStateLoading()) {
    reload();
  }

  Future<void> reload() async {
    try {
      final users = await client.user.getAllUsers();
      emit(
        UserAdminCubitStateLoaded(
          users: users..sort((a, b) => a.userName.compareTo(b.userName)),
        ),
      );
    } catch (e) {
      emit(UserAdminCubitStateNoPermission());
    }
  }

  Future<void> updateReadScopeByUserId(bool newValue, int userId) async {
    try {
      await client.user
          .updateReadScopeByUserId(newValue, userId)
          .then((_) => reload());
    } catch (e) {
      // ignore
    }
  }

  Future<void> updateWriteScopeByUserId(bool newValue, int userId) async {
    try {
      await client.user
          .updateWriteScopeByUserId(newValue, userId)
          .then((_) => reload());
    } catch (e) {
      // ignore
    }
  }

  Future<void> updateAdminScopeByUserId(bool newValue, int userId) async {
    try {
      await client.user
          .updateAdminScopeByUserId(newValue, userId)
          .then((_) => reload());
    } catch (e) {
      // ignore
    }
  }
}
