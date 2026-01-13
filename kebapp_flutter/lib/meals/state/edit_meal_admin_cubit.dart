import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class EditMealAdminCubitState {}

class EditMealAdminCubitLoading extends EditMealAdminCubitState {}

class EditMealAdminCubitNoPermission extends EditMealAdminCubitState {}

class EditMealAdminCubitLoaded extends EditMealAdminCubitState {
  final MealDto meal;

  EditMealAdminCubitLoaded({required this.meal});
}

class EditMealAdminCubit extends Cubit<EditMealAdminCubitState> {
  EditMealAdminCubit(this.id) : super(EditMealAdminCubitLoading()) {
    load();
  }

  final int? id;

  Future<void> load() async {
    try {
      final meals = await client.mealAdmin.getAll();
      final meal = meals.where((m) => m.id == id).firstOrNull;

      emit(
        EditMealAdminCubitLoaded(
          meal: meal ??
              MealDto(
                id: -1,
                title: '',
                basePrice: 0,
                mealInputs: [],
              ),
        ),
      );
    } catch (e) {
      emit(EditMealAdminCubitNoPermission());
    }
  }

  Future<void> upsertMeal(MealDto meal) async {
    try {
      await client.mealAdmin.upsert(meal).then((_) => load());
    } catch (e) {
      // ignore
    }
  }
}
