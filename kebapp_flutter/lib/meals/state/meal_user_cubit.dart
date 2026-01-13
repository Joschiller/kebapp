import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class MealUserCubitState {}

class MealUserCubitStateLoading extends MealUserCubitState {}

class MealUserCubitStateNoPermission extends MealUserCubitState {}

class MealUserCubitStateLoaded extends MealUserCubitState {
  final List<MealDto> meals;

  MealUserCubitStateLoaded({required this.meals});
}

class MealUserCubit extends Cubit<MealUserCubitState> {
  MealUserCubit() : super(MealUserCubitStateLoading()) {
    reload();
  }

  Future<void> reload() async {
    try {
      final meals = await client.mealUser.getAll();
      emit(
        MealUserCubitStateLoaded(
          meals: meals..sort((a, b) => a.title.compareTo(b.title)),
        ),
      );
    } catch (e) {
      emit(MealUserCubitStateNoPermission());
    }
  }
}
