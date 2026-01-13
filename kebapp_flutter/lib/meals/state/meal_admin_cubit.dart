import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class MealAdminCubitState {}

class MealAdminCubitStateLoading extends MealAdminCubitState {}

class MealAdminCubitStateNoPermission extends MealAdminCubitState {}

class MealAdminCubitStateLoaded extends MealAdminCubitState {
  final List<MealDto> meals;

  MealAdminCubitStateLoaded({required this.meals});
}

class MealAdminCubit extends Cubit<MealAdminCubitState> {
  MealAdminCubit() : super(MealAdminCubitStateLoading()) {
    reload();
  }

  Future<void> reload() async {
    try {
      final meals = await client.mealAdmin.getAll();
      emit(
        MealAdminCubitStateLoaded(
          meals: meals..sort((a, b) => a.title.compareTo(b.title)),
        ),
      );
    } catch (e) {
      emit(MealAdminCubitStateNoPermission());
    }
  }

  Future<void> delete(int id) async {
    try {
      await client.mealAdmin.delete(id).then((_) => reload());
    } catch (e) {
      //  ignore
    }
  }
}
