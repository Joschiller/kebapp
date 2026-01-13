import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:serverpod/serverpod.dart';

class MealUserEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {CustomScope.userRead};

  Future<List<MealDto>> getAll(Session session) async {
    return (await Meal.db.find(
      session,
      include: Meal.include(
        mealInputs: MealInput.includeList(
          include: MealInput.include(
            mealInputOptions: MealInputOption.includeList(),
          ),
        ),
      ),
    ))
        .map(
          (e) => MealDto(
            id: e.id!,
            title: e.title,
            basePrice: e.basePrice,
            mealInputs: e.mealInputs
                    ?.map(
                      (e) => MealInputDto(
                        id: e.id!,
                        description: e.description,
                        multipleChoice: e.multipleChoice,
                        isExclusion: e.isExclusion,
                        mealInputOptions: e.mealInputOptions
                                ?.map(
                                  (e) => MealInputOptionDto(
                                    id: e.id!,
                                    description: e.description,
                                    additionalPrice: e.additionalPrice,
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    )
                    .toList() ??
                [],
          ),
        )
        .toList();
  }
}
