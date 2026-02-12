import 'package:kebapp_server/src/generated/protocol.dart';
import 'package:kebapp_server/src/user/custom_scope.dart';
import 'package:serverpod/serverpod.dart';

class MealAdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin, CustomScope.adminMeals};

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

  Future<void> upsert(Session session, MealDto meal) async {
    final existingMeal = await Meal.db.findById(
      session,
      meal.id,
      include: Meal.include(
        mealInputs: MealInput.includeList(
          include: MealInput.include(
            mealInputOptions: MealInputOption.includeList(),
          ),
        ),
      ),
    );
    session.log('new: $meal');
    session.log('existing: $existingMeal');
    if (existingMeal != null) {
      await Meal.db.updateRow(
        session,
        Meal(
          id: meal.id,
          title: meal.title,
          basePrice: meal.basePrice,
        ),
      );
      final existingInputs =
          existingMeal.mealInputs?.map((e) => e.id).nonNulls.toSet() ?? {};
      final newInputIds = meal.mealInputs.map((e) => e.id).toSet();
      // delete inputs
      await MealInput.db.deleteWhere(
        session,
        where: (p0) =>
            p0.id.notInSet(newInputIds) & p0.id.inSet(existingInputs),
      );
      // update inputs
      for (final input in meal.mealInputs
          .where((element) => existingInputs.contains(element.id))) {
        await MealInput.db.updateRow(
          session,
          MealInput(
            id: input.id,
            mealId: meal.id,
            description: input.description,
            multipleChoice: input.multipleChoice,
            isExclusion: input.isExclusion,
          ),
        );
        final existingInput = await MealInput.db.findById(
          session,
          input.id,
          include: MealInput.include(
            mealInputOptions: MealInputOption.includeList(),
          ),
        );
        final existingOptions = existingInput?.mealInputOptions
                ?.map((e) => e.id)
                .nonNulls
                .toSet() ??
            {};
        final newOptions = input.mealInputOptions.map((e) => e.id).toSet();
        // delete options
        await MealInputOption.db.deleteWhere(
          session,
          where: (p0) =>
              p0.id.notInSet(newOptions) & p0.id.inSet(existingOptions),
        );
        // update options
        for (final option in input.mealInputOptions
            .where((element) => existingOptions.contains(element.id))) {
          await MealInputOption.db.updateRow(
            session,
            MealInputOption(
              id: option.id,
              mealInputId: input.id,
              description: option.description,
              additionalPrice: option.additionalPrice,
            ),
          );
        }
        // insert options
        for (final option in input.mealInputOptions
            .where((element) => !existingOptions.contains(element.id))) {
          await MealInputOption.db.insertRow(
            session,
            MealInputOption(
              mealInputId: input.id,
              description: option.description,
              additionalPrice: option.additionalPrice,
            ),
          );
        }
      }
      // insert inputs
      for (final input in meal.mealInputs
          .where((element) => !existingInputs.contains(element.id))) {
        final insertedInput = await MealInput.db.insertRow(
          session,
          MealInput(
            mealId: meal.id,
            description: input.description,
            multipleChoice: input.multipleChoice,
            isExclusion: input.isExclusion,
          ),
        );
        for (final option in input.mealInputOptions) {
          await MealInputOption.db.insertRow(
            session,
            MealInputOption(
              mealInputId: insertedInput.id!,
              description: option.description,
              additionalPrice: option.additionalPrice,
            ),
          );
        }
      }
    } else {
      final insertedMeal = await Meal.db.insertRow(
        session,
        Meal(
          title: meal.title,
          basePrice: meal.basePrice,
        ),
      );
      for (final input in meal.mealInputs) {
        final insertedInput = await MealInput.db.insertRow(
          session,
          MealInput(
            mealId: insertedMeal.id!,
            description: input.description,
            multipleChoice: input.multipleChoice,
            isExclusion: input.isExclusion,
          ),
        );
        for (final option in input.mealInputOptions) {
          await MealInputOption.db.insertRow(
            session,
            MealInputOption(
              mealInputId: insertedInput.id!,
              description: option.description,
              additionalPrice: option.additionalPrice,
            ),
          );
        }
      }
    }
  }

  Future<void> delete(Session session, int mealId) async {
    await Meal.db.deleteWhere(
      session,
      where: (p0) => p0.id.equals(mealId),
    );
  }
}
